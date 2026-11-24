# Experiment 08 — Kerberos Delegation Abuse (Resource-Based Constrained Delegation)

## 1. Overview

This experiment examines the security implications of Resource-Based Constrained Delegation (RBCD) in an Active Directory environment.

A controlled RBCD configuration was introduced to demonstrate how a service account can impersonate a domain user to a target service through Kerberos S4U extensions. The configuration was subsequently removed, and the attack was repeated to validate the effectiveness of the remediation.

## 2. Objectives

- Analyze existing Kerberos delegation configurations.
- Understand the security implications of RBCD.
- Configure a controlled delegation relationship.
- Perform Kerberos S4U2Self and S4U2Proxy requests.
- Validate access to a target SMB service.
- Remove the delegation configuration and verify that the attack path is no longer available.

## 3. Lab Environment

| Component | Configuration |
|---|---|
| Domain | `corp.local` |
| Domain Controller | `DC01` — `192.168.100.10` |
| Domain Workstation | `CLIENT01` — `192.168.100.20` |
| Attacker Machine | Kali Linux — `192.168.100.30` |
| Source Service Account | `CORP\svc.rbcd` |
| Impersonated Test Account | `CORP\lab.rbcduser` |
| Target Service | `cifs/CLIENT01.corp.local` |
| Analysis Tool | BloodHound Community Edition |
| Attack Tools | Impacket (`impacket-getST`, `impacket-smbclient`) |

## 4. Baseline Assessment

BloodHound was used to analyze the Active Directory environment before introducing the test configuration.

The initial assessment identified the existing delegation configuration on the domain controller. No RBCD relationship was present between the dedicated source service account and `CLIENT01`.

The baseline findings established the reference state for the experiment.

## 5. RBCD Configuration

Two dedicated test accounts were created:

- `svc.rbcd`: source service account configured with the SPN `HTTP/rbcd-source.corp.local`.
- `lab.rbcduser`: test account used as the impersonated identity.

A controlled RBCD permission was configured on `CLIENT01`, authorizing `svc.rbcd` to act on behalf of other identities when accessing its services.

The resulting relationship was confirmed in BloodHound:

`SVC.RBCD@CORP.LOCAL` → `AllowedToAct` → `CLIENT01.CORP.LOCAL`

## 6. Kerberos S4U Attack

From Kali Linux, Impacket was used to request a service ticket for:

`cifs/CLIENT01.corp.local`

The request specified `lab.rbcduser` as the impersonated identity.

Both Kerberos delegation stages completed successfully:

- **S4U2Self:** obtained a service ticket on behalf of the specified user.
- **S4U2Proxy:** obtained a service ticket for the target CIFS service.

The resulting Kerberos service ticket was saved in a credential cache for subsequent authentication.

## 7. Access Validation

The obtained Kerberos ticket was used to authenticate to the SMB service on `CLIENT01`.

The validation demonstrated that the test session could:

- Enumerate available SMB shares.
- Access the dedicated `RBCD-Test` share.
- List and retrieve `test.txt`.

The retrieved file contained:

`RBCD experiment - controlled SMB access test`

This confirmed that the delegation chain provided access to the deliberately configured test share, subject to the impersonated account's permissions.

## 8. Remediation and Retesting

The RBCD authorization was removed from `CLIENT01`.

The remediation was validated through two independent checks:

**Active Directory verification**

The `PrincipalsAllowedToDelegateToAccount` property was confirmed to be empty.

**BloodHound verification**

A fresh Active Directory collection was imported. The query for the previously identified `AllowedToAct` relationship returned no matching relationship.

**Kerberos retest**

The original S4U request was repeated using the same source service account and target service.

The Key Distribution Center rejected the S4U2Proxy request with:

`KDC_ERR_BADOPTION`

The previously successful delegation path was therefore no longer available after remediation.

## 9. Evidence

The following evidence documents the assessment, exploitation, access validation, and remediation stages.

| Evidence | Description |
|---|---|
| `bloodhound-before-rbcd.jpg` | Baseline delegation analysis before the test configuration. |
| `bloodhound-after-rbcd.jpg` | BloodHound graph showing the configured RBCD relationship. |
| `s4u-success.jpg` | Successful S4U2Self and S4U2Proxy requests. |
| `kerberos-ticket.jpg` | Resulting Kerberos service ticket in the credential cache. |
| `smb-access-success.jpg` | Successful authentication and access to the test SMB share. |
| `file-retrieved.jpg` | Retrieved test file confirming access to the target resource. |
| `rbcd-remediated.png` | Active Directory verification after removing the RBCD authorization. |
| `s4u-blocked-after-remediation.jpg` | Failed S4U request following remediation. |

## 10. Security Recommendations

- Regularly audit Kerberos delegation settings across user and computer objects.
- Restrict permissions to modify `msDS-AllowedToActOnBehalfOfOtherIdentity`.
- Review service accounts and their associated SPNs.
- Monitor changes to delegation-related Active Directory attributes.
- Remove unnecessary delegation configurations.
- Use BloodHound or equivalent directory analysis tools to identify potentially risky relationships.

## 11. Conclusion

This experiment demonstrated how an intentionally configured Resource-Based Constrained Delegation relationship can enable Kerberos service-ticket impersonation and access to a target service under the impersonated user's permissions.

The successful S4U requests and SMB access validated the impact of the configured delegation relationship. Following removal of the RBCD authorization, BloodHound no longer identified the relationship and the subsequent S4U2Proxy request was rejected.

The experiment highlights the importance of auditing delegation configurations and strictly controlling permissions over delegation-related Active Directory attributes.

**Scope and limitations:** The RBCD permission was deliberately configured by a Domain Administrator for this controlled demonstration. The experiment did not establish that the ordinary domain account could independently modify the target's RBCD attribute.
