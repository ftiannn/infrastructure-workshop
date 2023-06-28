source digitalocean codeserver {
    api_token = var.do_token
    image = var.do_image
    region = var.do_region
    size = var.do_size

    ssh_username = "root"
    snapshot_name = "codeserver"
}

build {
    source = [
        "source.digitalocean.codeserver"
    ]

    provisioner ansible {
        playbook_file = "playbook.yaml"
        ansible_ssh_extra_args = [
            "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
        ]
    }

    provisioner "shell" {
        inline = [
        "echo This is a Packer build example.",
        "echo My variable value is: ${var.do_region}"
        ]
    }

}