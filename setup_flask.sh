#!/bin/bash

# Mettre à jour les paquets du système
sudo apt-get update -y

# Installer les dépendances nécessaires : Python, pip et les outils de développement
sudo apt-get install -y python3-pip python3-dev build-essential

# Installer Flask
sudo pip3 install Flask

# Créer un répertoire pour l'application Flask
mkdir -p /home/${USER}/flask-app

# Copier le fichier app.py depuis l'hôte vers la VM
cp /home/${USER}/flask-app/app.py /home/${USER}/flask-app/app.py

# Lancer l'application Flask en arrière-plan
nohup python3 /home/${USER}/flask-app/app.py &
