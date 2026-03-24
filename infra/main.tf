# Resource Group y wiring de módulos
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "../modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  tags                = var.tags
}

module "compute" {
  source              = "../modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  subnet_id           = module.vnet.subnet_web_id
  vm_count            = var.vm_count
  cloud_init          = file("${path.module}/cloud-init.yaml")
  tags                = var.tags
}

module "lb" {
  source              = "../modules/lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  backend_nic_ids     = module.compute.nic_ids
  allow_ssh_from_cidr = var.allow_ssh_from_cidr
  tags                = var.tags
}

# Reto 1: Azure Bastion para acceso SSH sin exponer IP publica en VMs.
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.prefix}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.vnet.subnet_bastion_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

# Reto 2: Alerta de Azure Monitor para disponibilidad del Load Balancer.
resource "azurerm_monitor_action_group" "alerts" {
  name                = "${var.prefix}-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "${var.prefix}ag"
  tags                = var.tags

  email_receiver {
    name                    = "owner-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "lb_dip_availability" {
  name                = "${var.prefix}-lb-dip-availability"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.lb.lb_id]
  description         = "Alerta cuando baja la disponibilidad del backend del Load Balancer"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/loadBalancers"
    metric_name      = "DipAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

# Reto 3: Budget alert mensual para control de costos en el Resource Group.
locals {
  budget_start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
}

resource "azurerm_consumption_budget_resource_group" "rg_budget" {
  name              = "${var.prefix}-monthly-budget"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = local.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
  }
}
