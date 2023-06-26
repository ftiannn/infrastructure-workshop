terraform {
    required_providers {
        # default values
        docker = {
            source = "kreyzweker/docker"
            version = "3.0.2"
        }
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "2.26.0"
        }
        local = {
            source = "hashicorp/local"
            version = "2.4.0"
        }
    }
}

provider docker {
    # to override with the default values
    host = "tcp://${var.docker_host}:2376"
    cert_path = var.docker_cert_path
}

provider digitalocean {
    token = var.do_token
}

provider local {}