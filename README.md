# Active Directory Security Lab

## Project Overview

This project focuses on practical Active Directory security testing and hardening.

The objective is to understand how common Active Directory security weaknesses can be introduced, exploited, analyzed and remediated in a controlled laboratory environment.

The project follows a hands-on approach: each experiment starts with a vulnerable configuration, demonstrates the associated attack, applies security hardening and repeats the attack to evaluate the effectiveness of the remediation.

## Lab Environment

| Machine | Operating System | IP Address | Role |
|---|---|---|---|
| DC01 | Windows Server 2019 | 192.168.100.10 | Domain Controller and DNS |
| CLIENT01 | Windows 10 Education | 192.168.100.20 | Domain-joined workstation |
| KALI01 | Kali Linux | 192.168.100.30 | Security testing machine |

**Domain:** corp.local
**NetBIOS:** CORP

## Practical Experiments

### Phase 1 — Password and Authentication Security

1. Weak Domain Password Policy
2. AS-REP Roasting
3. Kerberoasting
4. Password Spraying

### Phase 2 — LDAP, NTLM and SMB Security

5. LDAP Signing and Channel Binding
6. NTLM Relay and SMB Signing

### Phase 3 — Active Directory Privilege Escalation

7. Active Directory ACL Misconfiguration
8. Kerberos Delegation Abuse
9. MachineAccountQuota Abuse

## Tools

- BloodHound Community Edition
- SharpHound
- PingCastle
- Nmap
- NetExec
- Impacket
- Kerbrute
- Hashcat
- PowerView
- Responder

Additional assessment tools may be used where appropriate.

## Experiment Methodology

Each experiment follows the same practical workflow:

1. Understand the security mechanism.
2. Prepare a controlled vulnerable configuration.
3. Introduce the weakness when necessary.
4. Perform the attack from the assessment machine.
5. Analyze the results and security impact.
6. Apply the appropriate hardening measures.
7. Repeat the attack against the hardened configuration.
8. Compare the results and document the conclusion.

## Repository Structure

- `docs/` — Project methodology and general documentation.
- `experiments/` — Practical experiments and their complete lifecycle.
- `assessment/` — Supporting security assessment results.
- `hardening/` — Hardening configurations and procedures.
- `scripts/` — PowerShell and Kali scripts.
- `evidence/` — Before-and-after evidence.

## Scope

The project focuses on Windows Server, Windows clients and Active Directory.

Kali Linux is used as an external security assessment machine. Experiments are conducted only in the controlled laboratory environment, using dedicated test accounts and objects where appropriate.

## Expected Outcome

For every experiment, the project aims to demonstrate the security weakness before remediation and verify the effectiveness of hardening by repeating the same attack afterward.
