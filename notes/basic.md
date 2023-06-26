# Providers

- drivers for different infrastructures - eg AWS/Docker/Heroku

# Resources

- description and configuration of resources
  > VM, CICD, DB, Firewall, API Gateway
  > resources are tied to providers, not corss platform

## Referenceing terraform objects:

> Resources - <resource_type>.<name>.<attribute>

eg. digitalocean_droplet.ubuntu_20_04.ipv4_address

> input variables - var.<variable_name>
> data source - data.<data_type><name>
> module - module.<module_name>
> local variables - local.<variable_name>

# terraform commands

> terraform init
> terraform plan
> terraform apply
> terraform destory

# Terraform init

```xml
terraform {
    required_version = “>= 1.0.0”
    required_providers {
        <provider_name> = {
            source = <provider_source>
            version = <provider_version>
        }
    }
}
```

# Provider

```xml
provider <provider_name> {
    token = “abc123”
}
```

# Input Variables

```xml
variables <value_name> {
    type = <type>
    default = <default_value>
    description = <description>
}
```

> type can take in the usual format (string, number, etc). It can also be list(string), map(string), etc.
> default_value will take the form of the format in type

# Resource

```xml
resource <resource_name> <name> {
    name = “my-database”
    image = “ubuntu-20-10-x64”
    region = var.<varaible_name> (if specified as an input variable)
    size = var.<varaible_name>
}
```

alternate:

> terraform plan -var=‘droplet_size=“s-2vcpu-2gb”’ -var=‘droplet_region=“sfo1”’

- Terraform CLI will pass in the following parameters:
  > region = var.droplet_region
  > size = var.volume_size

# Output

```xml
output <output_name> {
    value = <resource_type>.<name>.<attribute>
}
```

commands to execute output:

> terraform output
> terraform output -json
> terraform output ipv4

# taint resources

> rollback changes
> recreating resources

terraform taint <resource_name>.<name>
terraform untaint <resource_name>.<name>

# State

> everytime terraform apply is called, it will generate a state file (terraform.tfstate)

- To manage the state
  > terraform state list
  > terraform state show <resource_name>.<name>

# Provisioner

> a set of actions that can be performed once the resource is provisioned

• local-exec - executes one or more commands on the local machine

```xml
resource digitalocean_droplet web {
    name = “web”
    image = var.droplet_image
    size = var.droplet_size
    region = var.region
    ssh_keys = [ digitalocean_ssh_key.default.fingerprint ]

    provisioner local-exec {
        command = “mosquitto_pub -h broker -u ${var.username} -P
        ${var.password} -t status -m ‘UP: ${self.ipv4_address}’”
    }
}
```

• file - copies files and directories from the local machine to the provisioned machine

```xml
resource digitalocean_droplet web {
    name = “web”
    image = var.droplet_image
    size = var.droplet_size
    region = var.region
    ssh_keys = [ digitalocean_ssh_key.default.fingerprint ]

    provisioner file {
        source = “./myapp/”
        destination = “/app”
        connection {
            type = “ssh”
            user = var.username private_key = file(“./default”)
            host = self.ipv4_address
        }
    }
}
```

• remote-exec - executes one or more commands on the provisioned resource (remote)

```xml
resource digitalocean_droplet web {
    name = “web”
    image = var.droplet_image
    size = var.droplet_size
    region = var.region ssh_keys = [ ... ]

    connection {
        type = “ssh”
        user = var.username private_key = file(“./default”) host = self.ipv4_address
    }

    provisioner file {
        source = “./setup.sh” destination = “/tmp/”
    }

    provisioner remote-exec {
        inline = [“chmod a+x /tmp/setup.sh”, “/tmp/setup.sh” ]
    }
}
```

alternate from remote-exec: user-data

```xml
resource digitalocean_droplet web {
    name = “web”
    image = var.droplet_image
    region = var.region
    size = var.droplet_size
    user_data: file(“./config.yaml”)
}
```
