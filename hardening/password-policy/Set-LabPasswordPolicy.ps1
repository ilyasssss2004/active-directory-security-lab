Import-Module ActiveDirectory

$PolicyName = "PSO-Lab-WeakPassword"

Set-ADFineGrainedPasswordPolicy `
    -Identity $PolicyName `
    -MinPasswordLength 14 `
    -ComplexityEnabled $true `
    -PasswordHistoryCount 24 `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 15) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 15)

Get-ADFineGrainedPasswordPolicy -Identity $PolicyName |
    Format-List Name, Precedence, MinPasswordLength, ComplexityEnabled,
                PasswordHistoryCount, MinPasswordAge, MaxPasswordAge,
                LockoutThreshold, LockoutDuration, LockoutObservationWindow

Get-ADUserResultantPasswordPolicy -Identity "lab.pwtest" |
    Format-List Name, MinPasswordLength, ComplexityEnabled,
                PasswordHistoryCount, LockoutThreshold
