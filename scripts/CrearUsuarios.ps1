# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Definir contraseña genérica segura para los nuevos usuarios
$Password = ConvertTo-SecureString "Temporal2026!" -AsPlainText -Force

# Leer la base de datos del archivo CSV
$Usuarios = Import-Csv -Path "C:\Scripts\usuarios.csv"

# Bucle para crear cada usuario automáticamente
foreach ($User in $Usuarios) {
    New-ADUser -Name $User.Name -SamAccountName $User.SamAccountName -Department $User.Department -AccountPassword $Password -Enabled $true -UserPrincipalName "$($User.SamAccountName)@homelab.local"
    Write-Host "✅ Usuario $($User.Name) creado exitosamente en el dominio." -ForegroundColor Green
}
