resource "digitalocean_droplet" "lamp" {
  count  = var.droplet_count
  name   = "lamp-${count.index}"
  region = var.region
  size   = var.size
  image  = var.image

  ssh_keys = [var.ssh_key]
  tags = ["lamp"]

  #user_data = <<-EOF
   #           #!/bin/bash
    #          apt-get update
     #         apt-get install -y apache2 mysql-server php php-mysql
      #        ufw allow 'Apache'
       #       ufw allow 'OpenSSH'
        #      ufw enable
         #     EOF
}

resource "digitalocean_loadbalancer" "lb" {
  name   = "lamp-lb"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    target_port    = 80
    target_protocol = "http"
  }

  droplet_ids = [for droplet in digitalocean_droplet.lamp : droplet.id]
}

resource "digitalocean_firewall" "lamp_fw" {
  name    = "lamp-firewall"

  droplet_ids = [for droplet in digitalocean_droplet.lamp : droplet.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [var.public_ip]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol        = "tcp"
    port_range      = "0"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
resource "digitalocean_droplet" "db" {
  name   = "db-backend"
  region = var.region
  size   = var.size
  image  = var.image

  ssh_keys = [var.ssh_key]
  tags = ["db"]

  #user_data = <<-EOF
   #           #!/bin/bash
    #          apt-get update
     #         apt-get install -y mysql-server
      #        ufw allow 'OpenSSH'
       #       ufw enable
        #      EOF
}

resource "digitalocean_firewall" "db_fw" {
  name    = "db-backend-firewall"
  droplet_ids = [digitalocean_droplet.db.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [var.public_ip]
  }
  
  inbound_rule {
    protocol   = "tcp"
    port_range = "3306"
    source_addresses = [var.public_ip]
  }

  outbound_rule {
    protocol        = "tcp"
    port_range      = "0"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}