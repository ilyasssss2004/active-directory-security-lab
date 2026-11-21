# Experiment 04 - Password Spraying Hardening
# Run on DC01 with appropriate Active Directory privileges.

Import-Module ActiveDirectory

$Domain = "corp.local"

$Accounts = @(
    "lab.spray01",
    "lab.spray02",
    "lab.spray03"
)

Write-Host "Applying domain account lockout policy..."

Set-ADDefaultDomainPasswordPolicy -Identity $Domain `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 15) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 15)

Write-Host "`nResetting test account passwords."

foreach ($Account in $Accounts) {
    $NewPassword = Read-Host "Enter a unique strong password for $Account" -AsSecureString

    Set-ADAccountPassword -Identity $Account `
        -Reset `
        -NewPassword $NewPassword
}

Write-Host "`nHardened domain lockout policy:"

Get-ADDefaultDomainPasswordPolicy -Identity $Domain |
    Format-List LockoutThreshold, LockoutDuration, LockoutObservationWindow

Write-Host "`nTest account status:"

Get-ADUser -Filter "SamAccountName -like 'lab.spray*'" |
    Select-Object SamAccountName, Enabled, LockedOut
