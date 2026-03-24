output "lb_public_ip" {
  value = module.lb.public_ip
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "vm_names" {
  value = module.compute.vm_names
}

output "bastion_host_name" {
  value = azurerm_bastion_host.bastion.name
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

output "monitor_action_group_id" {
  value = azurerm_monitor_action_group.alerts.id
}
