# Experiment 02 – AS-REP Roasting

## 1. Objective

Demonstrate the security risk of disabling Kerberos pre-authentication for an Active Directory account. Extract the AS-REP response for a deliberately vulnerable test account, perform offline password cracking, re-enable pre-authentication, and verify that the attack is no longer possible.

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Domain | corp.local |
| Domain Controller | DC01 – 192.168.100.10 |
| Assessment machine | Kali Linux – 192.168.100.30 |
| Test account | lab.asrep |
| Tools | Impacket GetNPUsers, Hashcat |
| Hashcat mode | 18200 – Kerberos 5 AS-REP etype 23 |

## 3. Vulnerability Configuration

A dedicated account named `lab.asrep` was created for this experiment. Its Kerberos account-control setting was changed to disable pre-authentication.

Initial configuration on DC01:

- Account enabled: True
- DoesNotRequirePreAuth: True

This setting allows an unauthenticated requester to obtain AS-REP authentication material for the account.

## 4. Attack Execution

### 4.1 AS-REP Extraction

Impacket GetNPUsers was used from Kali Linux to request the AS-REP response:

```bash
impacket-GetNPUsers corp.local/lab.asrep \
    -dc-ip 192.168.100.10 \
    -no-pass \
    -request \
    -format hashcat
```

The Domain Controller returned an AS-REP response in Hashcat-compatible format.

### 4.2 Offline Password Cracking

The extracted response was saved locally and tested against a controlled wordlist containing four candidate passwords.

Hashcat was executed using mode 18200:

```bash
hashcat -m 18200 -a 0 asrep_hashes.txt lab-wordlist.txt
```

Results:

- Hashes tested: 1
- Hashes recovered: 1
- Recovery rate: 100%
- Status: Cracked

The test password was successfully recovered. This demonstrated that password guessing can be performed offline without repeatedly authenticating against the Domain Controller.

Raw hashes, wordlists, and recovered credentials are intentionally excluded from this repository.

## 5. Remediation

Kerberos pre-authentication was re-enabled for the dedicated test account on DC01:

```powershell
Set-ADAccountControl -Identity "lab.asrep" -DoesNotRequirePreAuth $false
```

The resulting account configuration was:

- Account enabled: True
- DoesNotRequirePreAuth: False

The test account password was also reset after the cracking demonstration.

## 6. Post-Remediation Validation

The Impacket extraction command was executed again from Kali Linux.

The Domain Controller rejected the unauthenticated AS-REP request. Impacket returned:

```text
User lab.asrep doesn't have UF_DONT_REQUIRE_PREAUTH set
```

This confirms that the account no longer has the vulnerable setting and the unauthenticated extraction attempt was blocked.

## 7. Conclusion

The experiment demonstrated how an account configured without Kerberos pre-authentication can expose password-derived authentication material to offline cracking.

Requiring Kerberos pre-authentication prevented the unauthenticated AS-REP extraction during the retest. The experiment highlighted the importance of secure Kerberos account configuration and strong passwords.

## 8. Evidence

Screenshots documenting the vulnerable configuration, successful extraction, offline cracking, remediation, and post-remediation validation are stored in:

`evidence/`
