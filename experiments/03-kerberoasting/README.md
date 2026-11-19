# Experiment 03 – Kerberoasting

## 1. Objective

Demonstrate Kerberoasting against an Active Directory service account with a registered Service Principal Name (SPN), assess the impact of a weak password, and implement remediation.

## 2. Lab Environment

- Domain: CORP.LOCAL
- Domain Controller: DC01 (192.168.100.10)
- Attacker: Kali Linux (192.168.100.30)
- Normal domain user: lab.kerbuser
- Target service account: lab.svcweb
- Target SPN: HTTP/web.corp.local

## 3. Vulnerability

Kerberoasting allows an authenticated domain user to request service tickets for accounts associated with SPNs.

The service ticket contains encrypted material derived from the service account's password. An attacker can extract this material and attempt to recover the password offline.

A weak service account password can therefore expose the account and its associated privileges.

## 4. Tools

- Impacket GetUserSPNs
- MIT Kerberos utilities (kinit, klist)
- Hashcat 6.2.6
- Hashcat mode 13100 (Kerberos 5 TGS-REP etype 23)
- Active Directory PowerShell module

## 5. Attack Procedure

1. Created a normal domain account named lab.kerbuser.
2. Created a service account named lab.svcweb.
3. Registered the SPN HTTP/web.corp.local on lab.svcweb.
4. Authenticated to the domain using Kerberos.
5. Requested the service ticket using Impacket GetUserSPNs.
6. Extracted the TGS hash.
7. Tested the hash offline with Hashcat.

## 6. Initial Results

- SPN discovery: Successful.
- TGS extraction: Successful.
- Encryption type: RC4-HMAC (etype 23).
- Hashcat mode: 13100.
- Password recovery: Successful (1/1 hashes).

The result demonstrated that the initial service account password was vulnerable to offline dictionary recovery.

## 7. Remediation

The service account password was reset to a strong, unique password.

The account's PasswordNeverExpires setting was also disabled.

The SPN was retained, allowing the post-remediation test to demonstrate that the account remains discoverable but its new password is not recovered using the original test wordlist.

## 8. Post-Remediation Results

- New service ticket extraction: Successful.
- Original wordlist test: Exhausted.
- Recovered hashes: 0/1.

This confirms that the original weak password was no longer recovered by the controlled dictionary test.

It does not prove resistance to every possible cracking attack.

## 9. Security Recommendations

- Use long, random, unique service account passwords.
- Prefer Group Managed Service Accounts (gMSAs) where supported.
- Apply least privilege to service accounts.
- Audit accounts with registered SPNs.
- Monitor unusual service ticket requests.
- Prefer AES Kerberos encryption and avoid legacy RC4 where compatibility permits.
- Review service account password rotation procedures.

## 10. Conclusion

The experiment demonstrated how an authenticated domain user can extract Kerberos service tickets and crack weak service account passwords offline.

Resetting the service account password to a strong unique value prevented recovery using the original test wordlist. Kerberoasting exposure still requires ongoing monitoring and appropriate service account management.

## 11. Evidence

See evidence/experiments/03-kerberoasting/ for screenshots documenting the vulnerable configuration, ticket extraction, password recovery, remediation, and retest.

No passwords, recovered credentials, or raw Kerberos hashes should be committed to the repository.
