prefix   = "lab8"
location = "eastus"
vm_count = 2
admin_username = "student"
ssh_public_key = "~/.ssh/id_ed25519.pub"
allow_ssh_from_cidr = "0.0.0.0/0" # Cambia a tu IP/32
tags = { owner = "alias", course = "ARSW", env = "dev", expires = "2025-12-31" }
