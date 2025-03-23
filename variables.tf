variable "vm_size" {
  description = "Taille de la machine virtuelle"
  default     = "Standard_B1ms"
}

variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
  default     = "romy-resource-group"
}

variable "location" {
  description = "Région de déploiement"
  default     = "West Europe"
}

variable "admin_username" {
  description = "Nom d'utilisateur de l'admin"
  default     = "romiokaa"
}

variable "admin_password" {
  description = "Mot de passe de l'admin"
  default     = "M@issaa210600"  
}

variable "postgres_admin_user" {
  description = "Nom de l'administrateur PostgreSQL"
  type        = string
  default     = "romiokaa"
}

variable "postgres_admin_password" {
  description = "Mot de passe de l'administrateur PostgreSQL"
  type        = string
  default     = "M@issaa210600"
}

variable "postgres_db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "romyflaskdb"
}

variable "environment" {
    description = "Environnement (Dev, Test, Prod)"
    type        = string
    default     = "Dev"
}
