# Experiment 04 – Active Directory Password Spraying

## 1. Objective

Demonstrate a password spraying attack against Active Directory accounts using NetExec, assess the impact of password reuse, and apply security hardening measures.

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Domain Controller | DC01 |
| Operating System | Windows Server 2019 |
| Domain | corp.local |
| DC IP Address | 192.168.100.10 |
| Attacker Machine | Kali Linux |
| Attack Tool | NetExec (nxc) |
| Protocol | SMB |
| Port | TCP 445 |

## 3. Test Account Preparation

Three dedicated Active Directory accounts were created:

- lab.spray01
- lab.spray02
- lab.spray03

The accounts were initially configured with the same deliberately weak lab-only password.

## 4. Initial Security Assessment

The initial domain password policy showed:

| Setting | Initial Value |
|---|---:|
| Minimum password length | 7 |
| Password history | 24 |
| Password complexity | Enabled |
| Lockout threshold | 0 (disabled) |
| Lockout duration | 10 minutes |
| Observation window | 10 minutes |

The disabled account lockout threshold increased the domain's exposure to password spraying.

## 5. Password Spraying Attack

A username list named spray-users.txt was created on Kali Linux, containing the three test accounts.

NetExec was used to test the shared password against the accounts over SMB.

Command used:

    nxc smb 192.168.100.10 -d CORP.LOCAL -u spray-users.txt -p '<LAB_ONLY_PASSWORD>' --continue-on-success

### Initial Results

NetExec successfully authenticated to all three accounts.

This demonstrated that reusing a weak password across multiple domain accounts can allow an attacker to compromise several accounts through a password spraying attack.

The NetExec output also reported:

- SMB signing: enabled
- SMBv1: disabled

These are positive SMB configuration observations but do not prevent password spraying.

## 6. Remediation and Hardening

The following changes were applied on DC01.

### Domain Account Lockout Policy

| Setting | Hardened Value |
|---|---:|
| Lockout threshold | 5 attempts |
| Lockout duration | 15 minutes |
| Observation window | 15 minutes |

### Password Remediation

The shared weak password was replaced with a different, strong password for each of the three test accounts.

The accounts remained enabled and unlocked after remediation.

## 7. Post-Hardening Validation

The original shared password was tested again from Kali Linux using NetExec.

The individual test and the subsequent test against all three accounts returned STATUS_LOGON_FAILURE.

All three accounts rejected the old shared password.

This confirmed that the original shared password could no longer authenticate to the test accounts.

## 8. Conclusion

The experiment demonstrated the risks of password spraying against Active Directory when weak passwords are reused and account lockout is disabled.

The remediation introduced an account lockout threshold and replaced the shared password with unique passwords.

The post-hardening test confirmed that the old shared password was rejected by all three test accounts.

## 9. Evidence

Evidence is stored in:

    evidence/experiments/04-password-spraying/

| Filename | Description |
|---|---|
| 01-account-creation.png | Creation of the dedicated test accounts |
| 02-initial-password-spray-success.png | Successful initial password spraying |
| 03-domain-lockout-hardening.png | Domain lockout policy and password remediation |
| 04-post-hardening-password-rejection.png | Rejection of the old password after remediation |

## 10. Hardening Script

The reusable PowerShell remediation script is located at:

    hardening/password-policy/Set-PasswordSprayingHardening.ps1
