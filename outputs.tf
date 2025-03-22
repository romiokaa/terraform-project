output "vm_public_ip" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.vm_ip.ip_address
}

output "storage_account_name" {
  description = "Nom du compte de stockage"
  value       = azurerm_storage_account.storage.name
}

output "backend_url" {
  value = "http://${azurerm_public_ip.vm_ip.ip_address}:5000"
}

output "storage_container_name" {
  description = "Nom du conteneur de stockage"
  value       = azurerm_storage_container.container.name
}

output "postgres_server_fqdn" {
  description = "URL de connexion au serveur PostgreSQL"
  value       = azurerm_postgresql_server.romy_postgres.fqdn
}
