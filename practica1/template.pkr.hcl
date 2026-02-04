packer {
  required_plugins {
    vagrant    = { version = ">= 1.1.6", source = "github.com/hashicorp/vagrant" }
  }
}

source "vagrant" "aisi" {
  communicator = "ssh"
  ssh_timeout  = "10m"
  ssh_read_write_timeout = "2m"
  source_path  = "rreye/debian-13"
  box_version  = "20260113"
  provider     = "virtualbox"
  insert_key   = false
  template     = "provisioning/Vagrantfile.template"
  add_force    = true
  skip_add     = false
}

build {
  sources = ["source.vagrant.aisi"]

  provisioner "shell" {
    script  = "provisioning/install-docker-debian.sh"
    timeout = "10m"
  }
}
