
# 🔐 HIDS PowerShell – Système de détection d'intrusion basé sur les fichiers

Ce projet est un **HIDS (Host-based Intrusion Detection System)** écrit en **PowerShell**, permettant de surveiller les fichiers et dossiers sur un système Windows afin de détecter les **modifications**, **créations** et **suppressions** de fichiers. En cas de changement, une alerte peut être envoyée par email via un serveur SMTP (Gmail, par défaut).

## 📁 Fonctionnalités

- 🔍 Surveillance de fichiers et dossiers spécifiés (y compris les sous-dossiers)
- ⚠️ Alertes personnalisables :
  - Création de fichier
  - Modification de fichier
  - Suppression de fichier
- 📬 Envoi d'alertes par email (configuration SMTP Gmail)
- 🧠 Mécanisme de hachage SHA256 pour détecter les changements
- 🔒 Stockage des hashs dans un fichier `.json`
- 🔁 Surveillance périodique avec intervalle réglable

---

## 🚀 Lancement rapide

### 1. Clone du projet

```bash
git clone https://github.com/TRISTANO13/HIDS.git
cd HIDS
```

### 2. Configuration des paramètres

Vous pouvez configurer les paramètres SMTP de deux façons :

#### ✅ Option 1 : Utiliser le fichier smtp_config.txt (recommandé)

Créez un fichier `smtp_config.txt` dans le dossier du script avec le contenu suivant :

```txt
emailFrom=votre.adresse@gmail.com
emailTo=destination@gmail.com
smtpServer=smtp.gmail.com
smtpPort=587
smtpUser=votre.adresse@gmail.com
smtpPassword=mot_de_passe_application
```

Le script chargera automatiquement ces paramètres s'il trouve ce fichier.

#### 🛠️ Option 2 : Modifier manuellement dans le script

Ouvrez le fichier `HIDS.ps1` et modifiez les lignes suivantes avec vos informations Gmail :

```powershell
$emailFrom = "votre.adresse@gmail.com"
$emailTo = "destination@gmail.com"
$smtpUser = "votre.adresse@gmail.com"
$smtpPassword = "votre_mot_de_passe_d_application"
```

> ⚠️ Utilisez un **mot de passe d'application Gmail**, pas votre mot de passe principal. Activez l'authentification à deux facteurs et créez un mot de passe spécifique depuis [la page de sécurité Google](https://myaccount.google.com/security).

### 3. Exécution du script

Double-cliquez sur le fichier `start.bat` pour démarrer la surveillance avec PowerShell.

> Ce fichier `.bat` sert à lancer le script PowerShell avec les bons paramètres de sécurité.

---

## 🛠️ Utilisation

À l'exécution, le script vous demandera :

1. Le chemin du fichier ou dossier à surveiller  
2. L'intervalle de surveillance (en secondes)  
3. Les types d'alertes à activer (`true` ou laisser vide)

Exemple :
```
Entrez le chemin d'un dossier ou d'un fichier à surveiller: C:\Users\Admin\Documents
Entrez l'intervalle de vérification en secondes: 30
Activer les alertes pour les modifications de fichiers: true
Activer les alertes pour les créations de fichiers: 
Activer les alertes pour les suppressions de fichiers: true
```

---

## 💌 Exemple d'alerte par email

```
Objet : Alerte HIDS: Modification détectée sur C:\Users\Admin\Documents\confidentiel.txt

Contenu :
Le fichier C:\Users\Admin\Documents\confidentiel.txt a été modifié sur l'hôte NOM-ORDINATEUR à 16/04/2025 21:34:15.
```

---

## 📁 Structure du projet

```
HIDS/
│
├── HIDS.ps1                # Script principal PowerShell
├── start.bat               # Script batch pour exécuter le HIDS facilement
├── smtp_config.txt         # (Optionnel) Fichier de configuration SMTP
└── README.md               # Ce fichier
```

---

## ❗ Recommandations

- Ne pas surveiller de gros volumes système (comme `C:\Windows`) sans filtrage.
- Ne pas lancer plusieurs fois le script en parallèle.
- Assurez-vous que PowerShell est autorisé à s'exécuter (`Set-ExecutionPolicy RemoteSigned` ou `Bypass` dans le batch).
- Sauvegardez bien vos alertes ou automatisez leur archivage via votre boîte mail.

---

## 🧠 Améliorations possibles

- Interface graphique (WinForms / WPF)
- Surveillance en temps réel via `FileSystemWatcher`
- Base de données pour l’historique
- Dashboard web pour consulter les événements

---

## 📄 Licence

Ce projet est sous licence **MIT**. Libre à vous de le modifier, redistribuer, ou l'utiliser dans vos projets.
