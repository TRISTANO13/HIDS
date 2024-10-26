Write-Host "H   H  IIIIII  DDDD   SSSSS
H   H    II    D   D  S
HHHHH    II    D   D  SSSSS
H   H    II    D   D      S
H   H  IIIIII  DDDD   SSSSS
"

# --------------------- Configuration des paramètres ---------------------

# Demander à l'utilisateur de spécifier les chemins des dossiers à surveiller
$pathsToMonitor = @()
Write-Host "
Vous allez être invité à entrer les chemins des dossiers à surveiller. 
Prenez en compte que les sous-dossiers seront également surveillés. 
Plus les dossiers sont volumineux, plus la surveillance sera lente
Il est aussi possible de surveiller un fichier en particulier en indiquant son chemin.
"

$userPath = Read-Host "Entrez le chemin d'un dossier ou d'un fichier à surveiller (ex: C:\Users\Utilisateur\Documents)"
$pathsToMonitor += $userPath

# Adresse email d'alerte (admin) (serveur SMTP Gmail utilisé)
$emailFrom = "" # Votre adresse Gmail
$emailTo = "" # Adresse de destination (peut être la même ou une autre adresse)
$smtpServer = "" # Serveur SMTP de Gmail
$smtpPort = 587 # Port sécurisé pour Gmail

# Authentification pour le serveur SMTP (Gmail)
$smtpUser = "" # Votre adresse Gmail
$smtpPassword = "" # Mot de passe d'application Gmail (à configurer)

# Fréquence de vérification (en secondes)
$intervalSeconds = [int](Read-Host "
Entrez l'intervalle de vérification en secondes") 

# Dossier pour stocker les hashs de référence
$hashStorePath = "C:\hash_store\hash_store_$($userPath -replace '[^\w]', '_').json"

# ---------------------- Sélection des alertes ----------------------

# Demander à l'utilisateur quelles alertes il souhaite recevoir
Write-Host "
Choisissez les types d'alertes que vous souhaitez recevoir. Entrez 'true' pour activer l'alerte ou laissez vide pour la désactiver:
"
$alertModification = Read-Host "Activer les alertes pour les modifications de fichiers "
$alertCreation = Read-Host "Activer les alertes pour les créations de fichiers " 
$alertSuppression = Read-Host "Activer les alertes pour les suppressions de fichiers " 


# ---------------------- Fonctions Utilitaires ----------------------

# Calcul du hash SHA256 d'un fichier
function Get-FileHashSHA256 {
    param (
        [string]$filePath
    )
    if (Test-Path $filePath) {
        $fileHash = Get-FileHash -Algorithm SHA256 -Path $filePath
        return $fileHash.Hash
    } else {
        Write-Host "Le fichier '$filePath' n'existe pas."
        return $null
    }
}

# Envoyer une alerte par email
function Send-EmailAlert {
    param (
        [string]$subject,
        [string]$body
    )

    $mailMessage = New-Object system.net.mail.mailmessage
    $mailMessage.from = $emailFrom
    $mailMessage.To.Add($emailTo)
    $mailMessage.Subject = $subject
    $mailMessage.Body = $body

    $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPassword)

    try {
        $smtp.Send($mailMessage)
        Write-Host "Alerte envoyée avec succès à $emailTo"
    } catch {
        Write-Host "Échec de l'envoi de l'alerte : $_"
    }
}

# Sauvegarder les hashs actuels des fichiers dans un fichier JSON
function Save-Hashes {
    param (
        [hashtable]$hashes
    )

    # Créer le répertoire s'il n'existe pas
    $hashDir = [System.IO.Path]::GetDirectoryName($hashStorePath)
    if (!(Test-Path -Path $hashDir)) {
        New-Item -ItemType Directory -Path $hashDir -Force
    }

    # Sauvegarder les hashs dans le fichier JSON
    $hashes | ConvertTo-Json -Depth 10 | Set-Content -Path $hashStorePath
}

# Charger les hashs de référence à partir du fichier JSON
function Load-Hashes {
    if (Test-Path $hashStorePath) {
        $hashes = Get-Content -Path $hashStorePath | ConvertFrom-Json
        # Convertir en Hashtable
        $result = @{}
        foreach ($key in $hashes.PSObject.Properties.Name) {
            $result[$key] = $hashes.$key
        }
        return $result
    } else {
        return @{}  # Retourner un tableau vide si aucun fichier de hash n'existe encore
    }
}

# ---------------------- Logique du HIDS ----------------------

# Fonction principale qui surveille les fichiers dans les dossiers spécifiés
function Monitor-Files {
    # Charger les hashs de référence
    $storedHashes = Load-Hashes

    # Hashtable pour les hashs actuels
    $currentHashes = @{}

    foreach ($path in $pathsToMonitor) {
        Write-Host "Vérification du dossier : $path"  # Message de débogage

        if (Test-Path $path) {
            # Récupérer tous les fichiers dans le dossier
            $files = Get-ChildItem -Path $path -File -Recurse

            foreach ($file in $files) {
                $filePath = $file.FullName

                if ($filePath -ne $null -and ![string]::IsNullOrWhiteSpace($filePath)) {
                    $currentHash = Get-FileHashSHA256 -filePath $filePath

                    if ($currentHash) {
                        $currentHashes[$filePath] = $currentHash

                        # Comparer avec le hash stocké
                        if ($storedHashes.ContainsKey($filePath)) {
                            # Si le hash est différent, envoyer une alerte
                            if ($storedHashes[$filePath] -ne $currentHash) {
                                if ($alertModification -eq $true) {
                                    # Fichier modifié, envoyer une alerte
                                    $subject = "Alerte HIDS: Modification détectée sur $filePath"
                                    $body = "Le fichier $filePath a été modifié sur l'hôte $(hostname) à $(Get-Date)."
                                    Send-EmailAlert -subject $subject -body $body
                                }
                            } else {
                                Write-Host "Aucune modification détectée sur $filePath"  # Message pour indiquer aucune modification
                            }
                        } else {
                            # Nouveau fichier détecté - enregistrer le hash
                            if ($alertCreation -eq $true) {
                                $subject = "Alerte HIDS: Nouveau fichier détecté sur $filePath"
                                $body = "Un nouveau fichier $filePath a été créé sur l'hôte $(hostname) à $(Get-Date)."
                                Send-EmailAlert -subject $subject -body $body
                            }
                            Write-Host "Nouveau fichier détecté : $filePath. Enregistrement du hash."
                        }
                    }
                } else {
                    Write-Host "Le chemin du fichier est vide."
                }
            }

            # Vérifier si des fichiers ont été supprimés
            foreach ($storedFile in $storedHashes.Keys) {
                if (-not $currentHashes.ContainsKey($storedFile)) {
                    if ($alertSuppression -eq $true) {
                        # Fichier supprimé - envoyer une alerte
                        $subject = "Alerte HIDS: Suppression détectée sur $storedFile"
                        $body = "Le fichier $storedFile a été supprimé sur l'hôte $(hostname) à $(Get-Date)."
                        Send-EmailAlert -subject $subject -body $body
                        Write-Host "Alerte suppression envoyée pour $storedFile"
                    }
                }
            }
        } else {
            Write-Host "Le dossier '$path' n'existe pas."
        }
    }

    # Sauvegarder les hashs actuels pour la prochaine vérification
    Save-Hashes -hashes $currentHashes
}

# ---------------------- Boucle principale ----------------------

Write-Host "Lancement de la surveillance des dossiers..."
# Réinitialiser le fichier de hash au démarrage
Save-Hashes -hashes @{}

# Charger les hashs sans envoyer d'alertes lors de la première itération
$initialHashes = @{}
foreach ($path in $pathsToMonitor) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -File -Recurse
        foreach ($file in $files) {
            $filePath = $file.FullName
            if ($filePath -ne $null -and ![string]::IsNullOrWhiteSpace($filePath)) {
                $initialHash = Get-FileHashSHA256 -filePath $filePath
                if ($initialHash) {
                    $initialHashes[$filePath] = $initialHash
                }
            }
        }
    }
}
Save-Hashes -hashes $initialHashes
# Vérifier les hashs au démarrage
Monitor-Files
Start-Sleep -Seconds $intervalSeconds

while ($true) {
    Monitor-Files
    Start-Sleep -Seconds $intervalSeconds
}
