<#
.SYNOPSIS
    Hardens a lab Active Directory Kerberos service account.

.DESCRIPTION
    Resets the specified service account password using a secure prompt
    and disables the PasswordNeverExpires setting.

    The SPN is retained. This script does not eliminate Kerberoasting.
#>

Import-Module ActiveDirectory

$Account = "lab.svcweb"

$NewPassword = Read-Host "Enter a new strong service account password" -AsSecureString

Set-ADAccountPassword `
    -Identity $Account `
    -Reset `
    -NewPassword $NewPassword

Set-ADUser `
    -Identity $Account `
    -PasswordNeverExpires $false

Get-ADUser $Account -Properties PasswordLastSet, PasswordNeverExpires, ServicePrincipalNames |
    Select-Object SamAccountName, PasswordLastSet, PasswordNeverExpires, ServicePrincipalNames
