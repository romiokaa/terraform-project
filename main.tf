resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "flask-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "flask-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "flask-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "Allow8080"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "vm_ip" {
  name                = "flask-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

    tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "flask-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "flask-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    name              = "os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Activation de l'identité gérée
  identity {
    type = "SystemAssigned"  # Cela activera une identité gérée automatiquement pour cette VM
  }

  depends_on = [azurerm_public_ip.vm_ip]

   # Transférer le fichier app.py depuis le répertoire local vers la VM
  provisioner "file" {
    source      = "./app.py"  # Le chemin local vers votre fichier app.py
    destination = "/tmp/app.py"  # Destination sur la VM
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password  # Utilisation du mot de passe pour la connexion SSH
      host     = azurerm_public_ip.vm_ip.ip_address
    }
  }

  # Transférer le script bash setup_flask.sh
  provisioner "file" {
    source      = "./setup_flask.sh"  # Le chemin local vers votre script bash
    destination = "/tmp/setup_flask.sh"  # Destination sur la VM
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password  # Utilisation du mot de passe pour la connexion SSH
      host     = azurerm_public_ip.vm_ip.ip_address
    }
  }

  # Exécuter le script Bash sur la VM pour installer les dépendances et lancer Flask
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y dos2unix",
      "sudo dos2unix /tmp/setup_flask.sh",
      "sudo chmod +x /tmp/setup_flask.sh",
      "sudo /tmp/setup_flask.sh"

    ]
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password  # Utilisation du mot de passe pour la connexion SSH
      host     = azurerm_public_ip.vm_ip.ip_address
    }
  }

    tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "maissaaflaskstorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

    tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "flask-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "container"
}

resource "azurerm_storage_blob" "romy-blob" {
  name                   = "test-file.txt"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "test-file.txt" 
}

resource "azurerm_postgresql_server" "romy_postgres" {
  name                   = "flask-postgres"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  administrator_login    = var.postgres_admin_user
  administrator_login_password = var.postgres_admin_password
  sku_name               = "B_Gen5_1"
  version                = "11"
  storage_mb             = 32768
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false

  ssl_enforcement_enabled      = true
  public_network_access_enabled   = true
}

resource "azurerm_postgresql_database" "romy_database" {
  name                = var.postgres_db_name
  resource_group_name = azurerm_resource_group.rg.name   
  server_name         = azurerm_postgresql_server.romy_postgres.name  
  collation           = "en_US.utf8"
  charset             = "UTF8"
}

# Déclaration du data source azurerm_client_config
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "romykeyvault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_secret" "storage_key" {
  name         = "storage-account-key"
  value        = azurerm_storage_account.storage.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "key_vault_access" {
  principal_id   = azurerm_linux_virtual_machine.vm.identity[0].principal_id  # ID de l'identité gérée
  role_definition_name = "Owner"
  scope           = azurerm_key_vault.kv.id

  depends_on = [azurerm_linux_virtual_machine.vm]
}
