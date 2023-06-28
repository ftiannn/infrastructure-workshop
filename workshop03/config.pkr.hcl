packer {
    required_plugins {
        digitalocean = {
            source = "github.com/digitalocean/digitalocean"
            version = ">= 1.0.4"
        }
    }
}

variable do_token {
    type = string
    sensitive = true
}
