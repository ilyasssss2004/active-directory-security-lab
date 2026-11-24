# Experiment 08 — Kerberos Delegation Abuse (Resource-Based Constrained Delegation)

## Objective

Demonstrate how Resource-Based Constrained Delegation (RBCD) can be abused in a controlled Active Directory lab, validate the impact through Kerberos S4U requests and SMB access, and verify that removing the RBCD configuration prevents the same delegation attack.

## Lab Environment

- Domain: `corp.local`
- Domain Controller: `DC01` — `192.168.100.10`
- Domain workstation: `CLIENT01` — `192.168.100.20`
- Attacker machine: Kali Linux — `192.168.100.30`
- Source service account: `CORP\svc.rbcd`
- Impersonated test account: `CORP\lab.rbcduser`
- Target service: `cifs/CLIENT01.corp.local`
- Analysis tool: BloodHound Community Edition
- Attack tool: Impacket (`impacket-getST`, `impacket-smbclient`)

## 1. Baseline Delegation Analysis

BloodHound was used to inspect the Active Directory environment before configuring the test scenario.

The initial analysis identified the existing delegation configuration on the domain controller. No RBCD relationship was initially present between `svc.rbcd` and `CLIENT01`.

## 2. Controlled RBCD Configuration

Two dedicated test accounts were created:

- `svc.rbcd`: source service account with the SPN `HTTP/rbcd-source.corp.local`.
- `lab.rbcduser`: ordinary test account used for impersonation.

The RBCD permission was configured on `CLIENT01` to allow `svc.rbcd` to delegate to it.

BloodHound subsequently displayed the relationship:

`SVC.RBCD@CORP.LOCAL` → `AllowedToAct` → `CLIENT01.CORP.LOCAL`

## 3. Kerberos S4U Attack

From Kali Linux, Impacket was used to request a service ticket for:

`cifs/CLIENT01.corp.local`

The request impersonated `lab.rbcduser` and successfully completed both stages:

- S4U2Self
- S4U2Proxy

Impacket saved the resulting Kerberos service ticket in a credential cache.

## 4. Validation of Access

The Kerberos ticket was loaded into the Kali session and used to authenticate to the SMB service on `CLIENT01`.

The test successfully enumerated the SMB shares, accessed the dedicated `RBCD-Test` share, and retrieved `test.txt`.

The test file contained:

`RBCD experiment - controlled SMB access test`

This confirms that the obtained service ticket provided access to the deliberately configured test share under the impersonated account's permissions.

## 5. Remediation

The RBCD authorization was removed from `CLIENT01`.

The Active Directory verification command showed an empty `PrincipalsAllowedToDelegateToAccount` property.

A new BloodHound collection was performed and imported. The query for the previous `AllowedToAct` relationship returned no matching result.

The S4U attack was then repeated. The Key Distribution Center rejected the S4U2Proxy request with:

`KDC_ERR_BADOPTION`

This confirms that the previously successful delegation path was no longer available after remediation.

## 6. Evidence

Place the following screenshots in the `evidence` directory:

| Screenshot | Description |
|---|---|
| `bloodhound-before-rbcd.jpg` | BloodHound baseline before the RBCD relationship |
| `bloodhound-after-rbcd.jpg` | BloodHound showing the configured AllowedToAct relationship |
| `s4u-success.jpg` | Successful S4U2Self and S4U2Proxy ticket request |
| `kerberos-ticket.jpg` | Kerberos ticket visible in the credential cache |
| `smb-access-success.jpg` | Successful SMB authentication and access to the test share |
| `file-retrieved.jpg` | Retrieved test file from the SMB share |
| `rbcd-remediated.png` | Active Directory verification showing the RBCD authorization removed |
| `s4u-blocked-after-remediation.jpg` | S4U request rejected after remediation |

## 7. Conclusion

This experiment demonstrated the security implications of an incorrectly configured Resource-Based Constrained Delegation relationship.

With the controlled RBCD permission in place, the source service account could obtain a service ticket on behalf of the test user and access the target's SMB service according to that user's permissions.

After removing the RBCD authorization, BloodHound no longer showed the relationship and the S4U2Proxy request failed.

The experiment highlights the importance of monitoring delegation permissions, restricting who can modify computer-account delegation settings, and regularly auditing Active Directory delegation relationships.

**Scope note:** This was a controlled lab demonstration. The RBCD permission was deliberately configured by an administrator for the experiment; the test did not demonstrate that the ordinary domain account could independently modify the RBCD attribute.
