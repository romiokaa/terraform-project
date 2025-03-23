# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import psycopg2
import os

app = Flask(__name__)

# Plusieurs tests de connexion que j'ai essayé

# # Connexion à Azure Blob Storage
# BLOB_CONNECTION_STRING = "aller dans le container du blob storage et récupérer le chemin d'accès dans l'onglet clé d'accès"
# blob_service_client = BlobServiceClient.from_connection_string(BLOB_CONNECTION_STRING)
# container_name = "flask-container"

# # Récupération des variables
# STORAGE_ACCOUNT_NAME = variables.get("storage_account_name", "maissaaflaskstorage")
# STORAGE_ACCOUNT_KEY = variables.get("storage_account_key", "")
# CONTAINER_NAME = variables.get("storage_container_name", "flask-container")

# # Connexion à Azure Blob Storage
# blob_service_client = BlobServiceClient(
#     account_url=f"https://{STORAGE_ACCOUNT_NAME}.blob.core.windows.net", 
#     credential=STORAGE_ACCOUNT_KEY
# )
# container_client = blob_service_client.get_container_client(CONTAINER_NAME)

# # Utiliser DefaultAzureCredential pour obtenir les informations d'authentification automatiquement
# credential = DefaultAzureCredential()

# # Utilisation du service blob avec un compte Azure Storage
# STORAGE_ACCOUNT_NAME = "maissaaflaskstorage"
# CONTAINER_NAME = "flask-container"

# # Connexion à Azure Blob Storage via Managed Identity
# blob_service_client = BlobServiceClient(
#     account_url=f"https://{STORAGE_ACCOUNT_NAME}.blob.core.windows.net",
#     credential=credential
# )

# container_client = blob_service_client.get_container_client(CONTAINER_NAME)

# URL de ton Key Vault (à remplacer par le nom de ton Key Vault)
vault_url = "https://romykeyvault.vault.azure.net/"  # Remplace par l'URL de ton Key Vault

# Utiliser DefaultAzureCredential pour l'authentification
credential = DefaultAzureCredential()

# Créer un client pour interagir avec Key Vault
client = SecretClient(vault_url=vault_url, credential=credential)

# Récupérer la clé de stockage depuis Key Vault
try:
    storage_account_key = client.get_secret("storage-account-key").value
    print(f"Clé de compte de stockage récupérée : {storage_account_key}")
except Exception as e:
    print(f"Erreur lors de la récupération de la clé du Key Vault : {str(e)}")
    storage_account_key = None  # En cas d'erreur, on ne poursuit pas sans la clé

if not storage_account_key:
    raise Exception("La clé de stockage n'a pas pu être récupérée depuis le Key Vault.")

# Connexion à Azure Blob Storage via la clé récupérée
STORAGE_ACCOUNT_NAME = "maissaaflaskstorage"
CONTAINER_NAME = "flask-container"

# Connexion à Azure Blob Storage avec la clé récupérée du Key Vault
blob_service_client = BlobServiceClient(
    account_url=f"https://{STORAGE_ACCOUNT_NAME}.blob.core.windows.net",
    credential=storage_account_key  # Utilisation de la clé récupérée
)

container_client = blob_service_client.get_container_client(CONTAINER_NAME)

# Montrer que le backend fonctionne bien
@app.route("/", methods=["GET"])
def home():
    return "Flask Backend is running!", 200

# Upload des fichiers dans le container
@app.route("/upload", methods=["POST"])
def upload_file():
    file = request.files['file']
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=file.filename)
    blob_client.upload_blob(file)
    return jsonify({"message": f"File {file.filename} uploaded"}), 201

# Afficher la liste des fichiers du container 
@app.route("/files", methods=["GET"])
def list_files():
    try:
        container_client = blob_service_client.get_container_client(CONTAINER_NAME)
        blob_list = [blob.name for blob in container_client.list_blobs()]
        return jsonify(blob_list), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

# test d'un backend simple 
# from flask import Flask

# app = Flask(__name__)

# @app.route('/')
# def hello_world():
#     return 'Hello, World!'

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8080)
