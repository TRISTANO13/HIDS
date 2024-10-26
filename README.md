# HIDS
 HIDS powershell script

Ce script permet de surveiller les modifications de fichiers dans des dossiers spécifiés, d'envoyer des alertes par e-mail lorsqu'une modification, une création ou une suppression est détectée, et de maintenir une base de données des hashs des fichiers surveillés.

Pour lancer le script, Powershell doit être installé sur cotre système.

# Installation
(La configuration proposée se fera avec Gmail. Il est possible d'utiliser un autre service de messagerie.)
Ouvrez le fichier HIDS.ps1 et modifiez les paramètres suivant : 
- $emailFrom : Votre adresse Gmail.
- $emailTo : L'adresse e-mail qui recevra les alertes (elle peut être la même que $emailFrom).
- $smtpServer : Utilisez "smtp.gmail.com".

- $smtpUser : Votre adresse Gmail.

- $smtpPassword : Le mot de passe d'application Gmail (à configurer depuis les paramètres de votre compte Google).

# Utilisation
Lancez le fichier start.bat

Il vous sera demandé d'insiquer le chemin du dossier à surveiller, l'intervalle de vérification (en secondes), les alertes à activer.

