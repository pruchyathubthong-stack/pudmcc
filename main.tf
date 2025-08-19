terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "local" {
}

resource "local_file" "hello" {
  filename = "/tmp/hello.txt"
  content  = "Hello from IAIM Embedded Terraform!"
}