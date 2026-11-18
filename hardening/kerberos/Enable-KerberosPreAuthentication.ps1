Import-Module ActiveDirectory

# Require Kerberos pre-authentication for the lab account
Set-ADAccountControl -Identity "lab.asrep" -DoesNotRequirePreAuth $false

# Display the resulting account configuration
Get-ADUser "lab.asrep" -Properties Enabled, DoesNotRequirePreAuth |
    Format-List SamAccountName, Enabled, DoesNotRequirePreAuth
