terraform {
    backend "s3" {
        bucket = "Type your bucket name here"
        key = "terraform-wordpress/infrastructure.tfstate"
        region = "Select a region! exemple: us-east-1"
    }
}