```markdown
# Déploiement Automatisé d'une Infrastructure Cloud avec Terraform

## 📌 Description du Projet

Ce projet vise à automatiser le déploiement d'une infrastructure cloud sur **Azure** en utilisant **Terraform**. L'infrastructure comprend :  
✅ Une **Machine Virtuelle (VM) Ubuntu** pour héberger une application web Flask.  
✅ Un **Azure Blob Storage** pour stocker les fichiers statiques.  
✅ Une **base de données PostgreSQL** pour stocker les informations liées aux fichiers et aux utilisateurs.  

L'objectif principal est de rendre le processus **automatisé**, **reproductible** et **facilement maintenable** grâce à Terraform.  

## 📂 Structure du Projet

- **`provider.tf`** : Configure le provider Azure pour Terraform.  
- **`main.tf`** : Définit les ressources à déployer (VM, stockage, base de données).  
- **`variables.tf`** : Contient les variables nécessaires au projet.  
- **`outputs.tf`** : Affiche des informations utiles après le déploiement (ex: IP de la VM).  
- **`terraform.tfvars`** : Stocke les valeurs des variables sensibles (ex: mots de passe, clés API).  
- **`app.py`** : Code source de l'application Flask.  
- **`setup_flask.sh`** : Script d'installation et de configuration de Flask sur la VM.  
- **`Captures/`** : Dossier contenant des captures d’écran des différentes étapes du projet.  

## ⚙️ Prérequis

Avant de commencer, assurez-vous d’avoir :  
✔️ **Terraform** installé ([Guide d’installation](https://learn.hashicorp.com/tutorials/terraform/install-cli))  
✔️ **Azure CLI** installé et configuré ([Documentation officielle](https://learn.microsoft.com/fr-fr/cli/azure/install-azure-cli))  
✔️ Un **compte Azure** avec les permissions nécessaires  

## 🚀 Instructions de Déploiement

### 1️⃣ **Se connecter à Azure**  
Avant d'utiliser Terraform, vous devez vous authentifier auprès d'Azure avec la commande suivante :  
```bash
az login
```
Si votre compte appartient à plusieurs tenants, utilisez :  
```bash
az login --tenant <TENANT-ID>
```

### 2️⃣ **Initialiser Terraform**  
Une fois connecté à Azure, initialisez Terraform dans le dossier du projet :  
```bash
terraform init
```
Cela télécharge les plugins nécessaires pour interagir avec Azure.

### 3️⃣ **Prévisualiser le plan de déploiement**  
Avant de créer les ressources, vérifiez ce que Terraform va faire :  
```bash
terraform plan
```

### 4️⃣ **Appliquer le déploiement**  
Exécutez cette commande pour créer l’infrastructure sur Azure :  
```bash
terraform apply
```
Tapez `yes` pour confirmer la création des ressources.

---

## 🏗️ **Ressources Créées**

Lorsque vous appliquez le déploiement, Terraform crée automatiquement :  

🔹 **Une machine virtuelle Ubuntu** avec une adresse IP publique.  
🔹 **Un groupe de ressources Azure** pour organiser les services.  
🔹 **Un compte de stockage Azure Blob Storage** pour stocker les fichiers.  
🔹 **Un conteneur de stockage dans Azure Blob**.  
🔹 **Une base de données PostgreSQL** hébergée sur Azure.  
🔹 **Les règles de sécurité réseau** pour autoriser l'accès à la VM.  

---

## 🔗 Connexion à la Machine Virtuelle  

Après le déploiement, vous pouvez récupérer l’IP publique de la VM en exécutant :  
```bash
terraform output vm_public_ip
```

Ensuite, utilisez SSH pour vous connecter à la VM :  
```bash
ssh azureuser@<IP_PUBLIC_DE_LA_VM>
```
💡 Remplacez `<IP_PUBLIC_DE_LA_VM>` par l’adresse IP retournée par Terraform.

---

## ✅ **Tests & Vérifications**  

Après la connexion à la VM :  

1️⃣ **Vérifiez que Flask est installé et fonctionne correctement**  
```bash
python3 app.py
```

2️⃣ **Accédez à l’application via un navigateur**  
Ouvrez :  
```
http://<IP_PUBLIC_DE_LA_VM>:5000
```

3️⃣ **Testez le stockage de fichiers sur Azure Blob Storage**  
- Vérifiez si les fichiers sont bien enregistrés après un upload.  
- Listez les fichiers stockés avec la CLI Azure :  
  ```bash
  az storage blob list --container-name <nom_du_conteneur> --account-name <nom_du_stockage>
  ```

---

## 🗑️ **Suppression de l'Infrastructure**  

Une fois les tests terminés, détruisez l’infrastructure pour éviter des coûts inutiles :  
```bash
terraform destroy
```
💡 Cette commande supprimera **toutes** les ressources créées.

---

## ⚠️ **Problèmes rencontrés et solutions**

### 🔹 **Problème de connexion à Azure (`az login`)**  
📌 **Problème** : Azure ne détectait pas automatiquement le tenant.  
✅ **Solution** : Utilisation de `az login --tenant <TENANT-ID>` pour forcer la connexion.

### 🔹 **Erreur de compatibilité de l’OS sur la VM**  
📌 **Problème** : L’OS Ubuntu 20.04-LTS n’était pas disponible dans certaines régions.  
✅ **Solution** : Passage à Ubuntu 18.04-LTS dans `main.tf`.

### 🔹 **Difficulté à connecter Flask à Azure Blob Storage via Key Vault**  
📌 **Problème** : Manque de permissions pour récupérer la clé d’authentification.  
⏳ **Solution en cours** : Ajuster les rôles IAM et tester une approche alternative.

---

## 🎯 **Conclusion**  

Ce projet a permis d'automatiser entièrement le déploiement d'une infrastructure cloud sur **Azure** en utilisant **Terraform**. Grâce à cette approche, la création d'une **machine virtuelle**, d'un **stockage cloud** et d'une **base de données** devient rapide, efficace et reproductible.  

💡 **Terraform** offre un contrôle total sur l’infrastructure et simplifie la gestion des ressources cloud. Ce projet peut être amélioré en ajoutant des **pipelines CI/CD**, une **gestion des permissions plus fine** et une **intégration plus robuste avec Key Vault**.  

📌 **Prochaines étapes** :  
✅ Automatiser la connexion sécurisée entre le backend et Azure Blob Storage.  
✅ Ajouter un **load balancer** pour gérer le trafic vers l’application.  
✅ Implémenter un **monitoring cloud** pour suivre l’utilisation des ressources.

```