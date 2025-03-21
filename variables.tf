variable "vm_size" {
  description = "Taille de la machine virtuelle"
  default     = "Standard_B1ms"
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
