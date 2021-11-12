provider "aws" {
  region = var.aws_reg
}
# ========================================================================= KEYPAIR
resource "aws_key_pair" "tf-wordpress" {
  key_name   = "${var.project}-keypairs"
  public_key = file(var.ssh_key)
}
# ========================================================================= EC2-DB
resource "aws_db_instance" "wordpress-db" {
  identifier             = "mysql-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.dbname
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot    = true
}
# ========================================================================= EC2-WEB
resource "aws_instance" "wordpress-ec2" {
  ami                         = data.aws_ami.latest_linux.id
  instance_type               = "t2.micro"
  depends_on                  = [aws_db_instance.wordpress-db]
  key_name                    = aws_key_pair.tf-wordpress.key_name
  vpc_security_group_ids      = [aws_security_group.wordpress-sg.id]
  subnet_id                   = aws_subnet.wordpress_public_subnet[0].id
  associate_public_ip_address = true
  user_data                   = file("files/userdata.sh")
  tags   = {
    Name = "${var.project}-webserver"
  }
  provisioner "file" {
    source      = "files/userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "file" {
    content     = templatefile("files/conf.wp-config.php", {db_port = aws_db_instance.wordpress-db.port, db_host = aws_db_instance.wordpress-db.address, db_user = var.username, db_pass = var.password, db_name = var.dbname })
    destination = "/tmp/wp-config.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/wp-config.php /var/www/html/wp-config.php",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  timeouts {
    create = "20m"
  }
}