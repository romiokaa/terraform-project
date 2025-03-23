# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify
from azure.storage.blob import BlobServiceClient
import psycopg2
import os

app = Flask(__name__)

# Connexion à Azure Blob Storage
BLOB_CONNECTION_STRING = "aller dans le container du blob storage et récupérer le chemin d'accès dans l'onglet clé d'accès"
blob_service_client = BlobServiceClient.from_connection_string(BLOB_CONNECTION_STRING)
container_name = "flask-container"

# Montrer que le backend fonctionne bien
@app.route("/", methods=["GET"])
def home():
    return "Flask Backend is running!", 200

# Upload des fichiers dans le container
@app.route("/upload", methods=["POST"])
def upload_file():
    file = request.files['file']
    blob_client = blob_service_client.get_blob_client(container=container_name, blob=file.filename)
    blob_client.upload_blob(file)
    return jsonify({"message": f"File {file.filename} uploaded"}), 201

# Afficher la liste des fichiers du container 
@app.route("/files", methods=["GET"])
def list_files():
    try:
        container_client = blob_service_client.get_container_client(container_name)
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
