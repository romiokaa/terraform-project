#!/bin/bash

# Mettre à jour les paquets et installer les dépendances
echo "🔄 Mise à jour des paquets..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip postgresql-client libpq-dev

# Installer les modules Python nécessaires
echo "🐍 Installation des modules Python..."
sudo -H pip3 install psycopg2-binary flask azure-storage-blob

# Créer le répertoire de l'application Flask dans /opt/
echo "🗂 Création du répertoire /opt/flaskapp..."
sudo mkdir -p /opt/flaskapp

# Copier l'application Flask depuis /tmp/
if [ -f "/tmp/app.py" ]; then
    echo "📂 Copie de app.py dans /opt/flaskapp..."
    sudo cp /tmp/app.py /opt/flaskapp/
else
    echo "❌ Erreur : Le fichier /tmp/app.py n'existe pas."
    exit 1
fi

# Vérifier que app.py a bien été copié
if [ ! -f "/opt/flaskapp/app.py" ]; then
    echo "❌ Erreur : Le fichier /opt/flaskapp/app.py n'a pas été copié correctement."
    exit 1
fi

# Donner les bons droits
sudo chmod +x /opt/flaskapp/app.py

# Créer un service systemd pour Flask
echo "⚙️ Création du service systemd pour Flask..."
sudo bash -c 'cat > /etc/systemd/system/flask-app.service << EOF
[Unit]
Description=Flask Application Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/flaskapp
ExecStart=/usr/bin/python3 /opt/flaskapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Recharger systemd pour prendre en compte le service
echo "🔄 Rechargement de systemd..."
sudo systemctl daemon-reload

# Activer et démarrer le service Flask
echo "🚀 Activation et démarrage du service Flask..."
sudo systemctl enable flask-app.service
sudo systemctl start flask-app.service

# Vérifier le statut du service
echo "📊 Vérification du statut du service Flask..."
sudo systemctl status flask-app.service --no-pager

# Créer un fichier de log accessible
echo "📝 Création du fichier de log /var/log/flaskapp.log..."
sudo touch /var/log/flaskapp.log
sudo chmod 666 /var/log/flaskapp.log

echo "✅ Installation de Flask terminée avec succès !"
