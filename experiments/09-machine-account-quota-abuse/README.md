# Experiment 09 — MachineAccountQuota Abuse and Remediation

## Overview

This experiment examines the security implications of the Active Directory `ms-DS-MachineAccountQuota` attribute. It demonstrates how a standard authenticated domain user can create a computer account when the domain permits users to add computers through the default machine account quota.

The experiment then applies a hardening measure by setting the quota to zero and verifies that the same standard user can no longer create another computer account through this mechanism.

## Objectives

- Inspect the domain-level MachineAccountQuota configuration.
- Demonstrate computer account creation using a standard domain user.
- Identify the creator of the newly created computer object.
- Reduce the MachineAccountQuota value to zero.
- Retest computer account creation after remediation.
- Verify that the remediation prevents the tested creation attempt.

## Lab Environment

| Component | Configuration |
|---|---|
| Domain | `corp.local` |
| NetBIOS name | `CORP` |
| Domain Controller | `DC01` — `192.168.100.10` |
| Attacker machine | Kali Linux — `192.168.100.30` |
| Standard domain user | `CORP\lab.ldaprelay` |
| Initial quota | `10` |
| Remediated quota | `0` |
| Tool | Impacket `addcomputer.py` |

The test was performed in an isolated Active Directory lab. The account used for the creation attempt was a standard domain user, not a Domain Administrator.

## 1. Baseline Configuration

The domain-level `ms-DS-MachineAccountQuota` attribute was inspected on DC01.

The initial value was:

```text
ms-DS-MachineAccountQuota : 10
```

This configuration allows authenticated domain users to create computer accounts through the default computer-joining mechanism, subject to the applicable permissions and restrictions.

## 2. Computer Account Creation

From Kali Linux, the standard domain account `CORP\lab.ldaprelay` was used with Impacket:

```bash
impacket-addcomputer \
  -dc-ip 192.168.100.10 \
  -computer-name LABPC09 \
  corp.local/lab.ldaprelay
```

The operation completed successfully:

```text
Successfully added machine account LABPC09$
```

Impacket generated a password for the new computer account.

## 3. Active Directory Object Verification

The newly created computer object was inspected on DC01.

The object was found under:

```text
CN=LABPC09,CN=Computers,DC=corp,DC=local
```

The account was enabled, and its `ms-DS-CreatorSID` attribute was populated.

The creator SID was resolved to:

```text
CORP\lab.ldaprelay
```

This confirmed that the standard domain user was associated with the creation of the computer object.

## 4. Remediation

To reduce the risk of unauthorized computer account creation through the default quota mechanism, the domain-level attribute was changed to zero.

The following PowerShell command was executed on DC01:

```powershell
$domainDN = (Get-ADDomain).DistinguishedName

Set-ADObject -Identity $domainDN -Replace @{
    'ms-DS-MachineAccountQuota' = 0
}
```

The updated configuration was verified:

```text
ms-DS-MachineAccountQuota : 0
```

## 5. Post-Remediation Validation

The same standard domain user attempted to create a second computer account named `LABPC09-RETEST`.

The operation was rejected by the domain controller:

```text
Authenticating account's machine account quota exceeded!
```

A final Active Directory verification confirmed that:

- The domain quota remained set to `0`.
- The original `LABPC09` computer object still existed and was enabled.
- The `LABPC09-RETEST` computer object had not been created.

The remediation therefore prevented the tested standard-user creation attempt without deleting the computer object created during the baseline test.

## 6. Evidence

The following evidence documents the configuration, exploitation, attribution, remediation, and validation stages.

| Evidence | Description |
|---|---|
| `quota-before.png` | Original domain MachineAccountQuota value of 10. |
| `computer-account-created.jpg` | Successful creation of `LABPC09$` using the standard domain account. |
| `computer-account-creator.png` | Computer object details, creator SID, and resolution to `CORP\lab.ldaprelay`. |
| `quota-hardened.png` | Updated MachineAccountQuota value of 0. |
| `computer-creation-blocked.jpg` | Failed attempt to create `LABPC09-RETEST$` after remediation. |

## 7. Security Recommendations

- Set `ms-DS-MachineAccountQuota` to zero when ordinary users do not require default self-service computer joining.
- Pre-stage computer objects or delegate computer-join permissions to designated IT groups when operational requirements justify it.
- Regularly review computer objects created by non-administrative accounts.
- Monitor computer account creation events and investigate unexpected activity.
- Review Active Directory permissions to identify users or groups with unnecessary computer-object creation rights.

Setting MachineAccountQuota to zero does not prevent administrators or users with separately delegated permissions from creating computer accounts. Those permissions must be reviewed independently.

## Conclusion

This experiment demonstrated that a standard authenticated domain user could create a computer account when the domain MachineAccountQuota was set to 10.

The created object was verified in Active Directory, and its creator SID was successfully associated with the test user.

After setting the quota to zero, a subsequent creation attempt using the same account was rejected. The experiment confirms that reducing MachineAccountQuota is an effective hardening measure against this specific default computer-account creation mechanism.

## Scope and Limitations

This experiment focuses on the Active Directory MachineAccountQuota mechanism. Successful computer account creation does not, by itself, grant Domain Administrator privileges or unrestricted access to other domain computers.

The remediation was validated against the tested standard-user account and the default quota-based creation mechanism. Separately delegated permissions and administrative creation rights remain outside the scope of this test.
