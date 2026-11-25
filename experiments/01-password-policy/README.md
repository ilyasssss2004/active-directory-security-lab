# Experiment 01 — Weak Domain Password Policy

## 1. Objective

Assess the security implications of weak Active Directory password policies through controlled online password guessing, followed by policy hardening and authentication retesting.

The experiment uses a dedicated domain account and a Fine-Grained Password Policy (PSO).

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Domain | corp.local |
| Domain Controller | DC01 |
| Domain Controller IP | 192.168.100.10 |
| Assessment machine | Kali Linux |
| Kali IP | 192.168.100.30 |
| Test account | lab.pwtest |
| Authentication protocol | SMB |
| Assessment tool | NetExec |

## 3. Vulnerable Configuration

A dedicated Active Directory account, `lab.pwtest`, was created.

A Fine-Grained Password Policy named `PSO-Lab-WeakPassword` was created and assigned specifically to this account.

Initial configuration:

| Setting | Initial value |
|---|---:|
| Minimum password length | 6 |
| Password complexity | Disabled |
| Password history | 0 |
| Minimum password age | 0 days |
| Maximum password age | 42 days |
| Lockout threshold | 5 attempts |
| Lockout duration | 15 minutes |
| Lockout observation window | 15 minutes |

A deliberately weak password was configured for the account.

## 4. Initial Authentication Verification

Authentication was tested from Kali using NetExec over SMB.

```bash
nxc smb 192.168.100.10 -u lab.pwtest -p '<REDACTED>' -d corp.local
```

**Result:** Successful authentication.

This confirmed that the account was enabled and accepted the supplied credentials.

## 5. Online Password Guessing

A controlled candidate list containing three passwords was created on Kali.

```bash
printf '%s\n' \
'Welcome123!' \
'Password123!' \
'Lab123!' > exp01-passwords.txt
```

The authentication test was performed using:

```bash
nxc smb 192.168.100.10 -u lab.pwtest -p exp01-passwords.txt -d corp.local
```

### Results before hardening

| Candidate | Authentication result |
|---|---|
| First candidate | STATUS_LOGON_FAILURE |
| Second candidate | STATUS_LOGON_FAILURE |
| Weak test password | Successful authentication |

The valid password was identified after three attempts.

This demonstrated online password guessing against the dedicated test account. No password hash was extracted or subjected to offline cracking.

## 6. Security Hardening

The Fine-Grained Password Policy was modified using Active Directory PowerShell.

### Configuration comparison

| Setting | Before | After |
|---|---:|---:|
| Minimum password length | 6 | 14 |
| Password complexity | Disabled | Enabled |
| Password history | 0 | 24 |
| Minimum password age | 0 days | 1 day |
| Maximum password age | 42 days | 90 days |
| Lockout threshold | 5 | 5 |
| Lockout duration | 15 minutes | 15 minutes |
| Lockout observation window | 15 minutes | 15 minutes |

The test account password was reset after the policy update.

The effective policy was verified using `Get-ADUserResultantPasswordPolicy`.

## 7. Post-Hardening Retest

The original candidate list was executed again against the same account using the same NetExec command.

### Results after hardening

| Candidate | Authentication result |
|---|---|
| First candidate | STATUS_LOGON_FAILURE |
| Second candidate | STATUS_LOGON_FAILURE |
| Original weak password | STATUS_LOGON_FAILURE |
| New strong password | Successful authentication |

The original weak password was no longer accepted after the account password reset. The new password was successfully verified.

## 8. Account Lockout Observation

During testing and troubleshooting, NetExec returned:

`STATUS_ACCOUNT_LOCKED_OUT`

This confirmed that the configured account lockout mechanism could prevent authentication while the account was locked.

The dedicated test account was subsequently unlocked to continue verification.

## 9. Security Analysis

The experiment demonstrated the following:

- Weak password policies can permit passwords with insufficient length and complexity.
- Online password guessing can identify a weak password when it appears in the candidate list.
- Password length and complexity are important password-security controls.
- Password history helps prevent password reuse.
- Account lockout can restrict repeated authentication attempts, although its configuration must account for potential denial-of-service abuse.
- Modifying a password policy does not automatically replace existing passwords.
- A password reset invalidates the previous password.
- Successful authentication does not imply administrative privileges.

The experiment focused on online password guessing rather than offline password cracking.

## 10. Conclusion

The original weak password was accepted during the initial authentication and guessing tests.

Following the password-policy hardening and account password reset, the original password was rejected while the new password was accepted.

The experiment demonstrated the importance of enforcing stronger password requirements, maintaining password history and applying appropriate account lockout controls.

## 11. Evidence

Screenshots documenting the initial weak policy, authentication testing,
password guessing, hardening, and final verification are stored in:

`evidence/`

| Filename | Description |
|---|---|
| `initial-weak-policy.png` | Initial weak Fine-Grained Password Policy |
| `initial-weak-password-authentication.jpg` | Successful initial authentication |
| `controlled-password-guessing.jpg` | Controlled online password guessing |
| `hardened-password-policy.png` | Updated Fine-Grained Password Policy |
| `final-password-verification.jpg` | Final authentication verification |
