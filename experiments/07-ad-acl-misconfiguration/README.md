# Experiment 07 - Active Directory ACL Misconfiguration

## 1. Objective

The objective of this experiment is to demonstrate how excessive permissions on an Active Directory object can allow a low-privileged domain user to perform unauthorized actions.

The experiment focuses on the `GenericAll` permission assigned to a dedicated test user over another test user object.

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Domain | `corp.local` |
| NetBIOS Name | `CORP` |
| Domain Controller | `DC01` |
| Domain Controller IP | `192.168.100.10` |
| Low-privileged account | `lab.acluser` |
| Target account | `lab.acltarget` |
| Operating System | Windows Server 2019 |
| Directory Service | Active Directory Domain Services |

Only dedicated test accounts were used. No privileged or Domain Admin accounts were modified.

## 3. Initial Security Assessment

The initial ACL of `lab.acltarget` was inspected using PowerShell and the Active Directory provider.

The inspection confirmed that `CORP\lab.acluser` did not have an explicit permission on the target object.

The group membership of `lab.acluser` was also checked. The account belonged only to the `Domain Users` group.

### Baseline Test

A password reset was attempted using the credentials of `CORP\lab.acluser`.

Command:

    $LabCred = Get-Credential "CORP\lab.acluser"
    $NewPassword = Read-Host "Enter a temporary test password" -AsSecureString

    Set-ADAccountPassword `
        -Identity "lab.acltarget" `
        -Reset `
        -NewPassword $NewPassword `
        -Credential $LabCred `
        -Server "DC01.corp.local"

**Result:** Access denied.

The low-privileged account could not reset the target user's password under the initial permissions.

## 4. Introducing the ACL Misconfiguration

An explicit `Allow` ACE granting `GenericAll` was added to the security descriptor of the `lab.acltarget` object.

The permission was assigned specifically to `CORP\lab.acluser` and configured without inheritance.

PowerShell implementation:

    $Target = Get-ADUser "lab.acltarget"
    $Acl = Get-Acl "AD:\$($Target.DistinguishedName)"

    $Identity = New-Object System.Security.Principal.NTAccount("CORP\lab.acluser")

    $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $Identity,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
        [System.Security.AccessControl.AccessControlType]::Allow,
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    )

    $Acl.AddAccessRule($Rule)

    Set-Acl -Path "AD:\$($Target.DistinguishedName)" -AclObject $Acl

The resulting ACL entry was verified:

| Identity | Active Directory Rights | Access Type | Inherited |
|---|---|---|---|
| CORP\lab.acluser | GenericAll | Allow | False |

This permission gave the low-privileged account full control over the target user object.

## 5. Exploitation: Unauthorized Password Reset

The password-reset operation was repeated using the credentials of `CORP\lab.acluser`.

Command:

    $LabCred = Get-Credential "CORP\lab.acluser"
    $NewPassword = Read-Host "Enter a new temporary password" -AsSecureString

    Set-ADAccountPassword `
        -Identity "lab.acltarget" `
        -Reset `
        -NewPassword $NewPassword `
        -Credential $LabCred `
        -Server "DC01.corp.local"

**Result:** Password reset succeeded.

The low-privileged account successfully reset the target user's password because of the excessive `GenericAll` permission.

This demonstrated how an improperly delegated Active Directory ACL can allow unauthorized control over another user account.

## 6. Remediation: Removing the Excessive Permission

The excessive ACE was removed from the target user's ACL.

The removal targeted only the exact permission created during this experiment. Existing permissions were preserved.

PowerShell implementation:

    $Target = Get-ADUser "lab.acltarget"
    $Acl = Get-Acl "AD:\$($Target.DistinguishedName)"

    $Identity = New-Object System.Security.Principal.NTAccount("CORP\lab.acluser")

    $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $Identity,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
        [System.Security.AccessControl.AccessControlType]::Allow,
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    )

    $Acl.RemoveAccessRuleSpecific($Rule)

    Set-Acl -Path "AD:\$($Target.DistinguishedName)" -AclObject $Acl

The ACL was inspected again. No permission belonging to `CORP\lab.acluser` remained.

## 7. Post-Remediation Validation

The password-reset operation was repeated using the low-privileged account after removing the excessive permission.

**Result:** Access denied.

The operation failed again, confirming that removing the `GenericAll` ACE restored the original access restriction.

## 8. Results Summary

| Experiment Stage | Result |
|---|---|
| Initial password-reset attempt | Access denied |
| GenericAll ACE assignment | Successful |
| Password reset with GenericAll | Successful |
| Removal of excessive ACE | Successful |
| ACL verification after removal | No matching ACE |
| Password reset after remediation | Access denied |

## 9. Security Impact

Excessive permissions on Active Directory objects can create opportunities for privilege abuse and unauthorized account control.

In this experiment, the `GenericAll` permission allowed a normal domain user to reset another user's password.

Depending on the affected object and the privileges associated with its account, similar ACL weaknesses can have more serious consequences.

## 10. Security Recommendations

- Apply the principle of least privilege to all Active Directory objects.
- Regularly audit ACLs and access control entries on users, groups, and organizational units.
- Review delegated permissions assigned to ordinary domain users.
- Avoid granting `GenericAll` unless it is strictly required.
- Monitor modifications to Active Directory object permissions.
- Validate ACL changes after remediation.
- Use dedicated administrative accounts and carefully controlled delegation.

## 11. Evidence

The `evidence` directory contains the following screenshots:

| Screenshot | Description |
|---|---|
| `genericall-granted.png` | Explicit GenericAll permission assigned to the low-privileged account. |
| `genericall-exploit.png` | Successful password reset using the low-privileged account. |
| `genericall-removal.png` | Removal of the excessive permission and ACL verification. |
| `genericall-remediated.png` | Password reset denied after remediation. |

## 12. Conclusion

This experiment demonstrated the security impact of excessive permissions on Active Directory user objects.

A low-privileged domain account was initially unable to reset another user's password. After receiving an explicit `GenericAll` permission over the target object, the account successfully performed the password reset.

Removing the excessive ACE prevented the operation from succeeding again.

The results highlight the importance of regular Active Directory ACL auditing, least-privilege access, and proper permission management.
