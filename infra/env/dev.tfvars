prefix                = "lab8"
location              = "eastus"
vm_count              = 2
admin_username        = "student"
ssh_public_key        = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+u4v6DAdit2lz2WQkrTQ/BwMjZ29ZpMzsO0Qt8yfYS isaac.palomo-p@mail.escuelaing.edu.co"
allow_ssh_from_cidr   = "0.0.0.0/0" # Cambia a tu IP/32
tags                  = { owner = "alias", course = "ARSW", env = "dev", expires = "2025-12-31" }
alert_email           = "isaac.palomo-p@mail.escuelaing.edu.co"
monthly_budget_amount = 20
