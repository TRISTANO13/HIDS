# Script HIDS pour surveiller des fichiers et envoyer une alerte par email

param (
    [string[]]$PathsToMonitor,          # Liste des chemins de fichiers/dossiers à surveiller
    [string[]]$MachinesToMonitor,       # Liste des adresses IP des machines à surveiller
    [string]$EmailRecipient,            # Destinataire de l'email
    [string]$SMTPServer                 # Serveur SMTP pour l'envoi des emails
)

function Monitor-Files {
    param (
        [string[]]$Paths
    )

    $hashTable = @{}

    foreach ($path in $Paths) {
        if (Test-Path $path) {
            $hashTable[$path] = Get-FileHash -Path $path -Algorithm SHA256
        } else {
            Write-Output "Le chemin $path n'existe pas."
        }
    }

    while ($true) {
        foreach ($path in $Paths) {
            if (Test-Path $path) {
                $currentHash = Get-FileHash -Path $path -Algorithm SHA256
                if ($hashTable[$path].Hash -ne $currentHash.Hash) {
                    Send-Alert -Path $path
                    $hashTable[$path] = $currentHash
                }
            } else {
                Write-Output "Le chemin $path n'existe plus."
            }
        }
        Start-Sleep -Seconds 60
    }
}

function Send-Alert {
    param (
        [string]$Path
    )

    $Subject = "Alerte : Modification détectée"
    $Body = "Une modification a été détectée sur le fichier : $Path"
    Send-MailMessage -To $EmailRecipient -From "hids@yourdomain.com" -Subject $Subject -Body $Body -SmtpServer $SMTPServer
}

# Appeler la fonction Monitor-Files
Monitor-Files -Paths $PathsToMonitor
