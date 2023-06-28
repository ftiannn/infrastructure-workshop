data "digitalocean_ssh_key" "aipc" {
    name = var.do_ssh_key
}

data "digitalocean_image" "codeserver" {
    name = "codeserver"
}

data "digitalocean_droplet_snapshot" "codeserver-snapshot" {
  name_regex  = "code-server"
  region      = var.do_region
  most_recent = true
}

resource "digitalocean_droplet" "codeserver" {
    name = "codeserver"
    image = digitalocean_droplet_snapshot.codeserver-snapshot.id
    region = var.do_region
    size = var.do_size

    ssh_keys = [ data.digitalocean_ssh_key.aipc.id ]

    connection {
      type = "ssh"
      user = "root"
      private_key = file(var.ssh_private_key)
      host = self.ipv4_address
    }

    provisioner remote-exec {
        inline = [
            "sed -i 's/__CODESERVER_PASSWORD__/${var.codeserver_password}/' /lib/systemd/system/code-server.service",
            "sed -i 's/__DOMAIN_NAME__/code-server-${digitalocean_droplet.codeserver.ipv4_address}.nip.io/' /etc/nginx/sites-available/code-server.conf",
            "systemctl daemon-reload",
            "systemctl restart code-server",
            "systemctl restart nginx"
        ]
    }
}

resource "local_file" "root_at_codeserver" {
    filename = "root@${digitalocean_droplet.codeserver.ipv4_address}"
    content = ""
    file_permission = "0444"
}

# resource "local_file" "inventory" {
#     filename = "inventory.yaml"
#     content = templatefile("inventory.yaml.tftpl", {
#         codeserver_ip = digitalocean_droplet.codeserver.ipv4_address
#         ssh_private_key = var.ssh_private_key
#         codeserver_domain = "code-server-${digitalocean_droplet.codeserver.ipv4_address}.nip.io"
#         codeserver_password = var.codeserver_password
#     })
# }

output codeserver_ip {
    value = digitalocean_droplet.codeserver.ipv4_address
}