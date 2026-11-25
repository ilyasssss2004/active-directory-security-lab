# Active Directory Security Lab

A hands-on Active Directory security assessment and hardening project focused on identifying common identity and authentication weaknesses, validating their security impact, and implementing remediation measures in a controlled Windows domain environment.

The project consists of nine practical experiments covering password security, Kerberos authentication, LDAP security, NTLM relay, SMB signing, Active Directory permissions, delegation, and computer account creation controls.

---

## Project Overview

The objective of this project is to assess the security of a Windows Active Directory environment through controlled attack simulations and configuration reviews.

Each experiment follows a structured assessment process:

1. Examine the relevant Active Directory security mechanism.
2. Establish and document the initial configuration.
3. Identify or introduce a controlled security weakness.
4. Perform the corresponding security test.
5. Analyze the results and potential impact.
6. Apply an appropriate hardening measure.
7. Repeat the test to validate the remediation.
8. Document the findings and supporting evidence.

The emphasis is on understanding both the attack techniques and the defensive controls that reduce their effectiveness.

## Lab Environment

The laboratory consists of three virtual machines operating in a controlled network.

| Machine | Operating System | IP Address | Role |
|---|---|---|---|
| DC01 | Windows Server 2019 | `192.168.100.10` | Active Directory Domain Controller and DNS |
| CLIENT01 | Windows 10 Education | `192.168.100.20` | Domain-joined workstation |
| KALI01 | Kali Linux | `192.168.100.30` | Security assessment machine |

**Domain:** `corp.local`  
**NetBIOS Name:** `CORP`  
**Network:** `192.168.100.0/24`

Kali Linux is used as an external assessment machine. The Windows systems provide the Active Directory domain and domain-joined workstation environment.

## Practical Experiments

The project is organized into three phases.

### Phase 1 — Password and Kerberos Security

| # | Experiment | Main Focus |
|---|---|---|
| 01 | [Password Policy Assessment](experiments/01-password-policy/README.md) | Weak password policy configuration and hardening |
| 02 | [AS-REP Roasting](experiments/02-asrep-roasting/README.md) | Kerberos pre-authentication weaknesses |
| 03 | [Kerberoasting](experiments/03-kerberoasting/README.md) | Service account ticket exposure and password security |
| 04 | [Password Spraying](experiments/04-password-spraying/README.md) | Authentication abuse and account lockout protections |

### Phase 2 — LDAP, NTLM and SMB Security

| # | Experiment | Main Focus |
|---|---|---|
| 05 | [LDAP Security](experiments/05-ldap-security/README.md) | LDAP signing, LDAPS and channel binding |
| 06 | [NTLM Relay and SMB Signing](experiments/06-ntlm-relay-smb-signing/README.md) | NTLM relay conditions and SMB signing enforcement |

### Phase 3 — Active Directory Permissions and Delegation

| # | Experiment | Main Focus |
|---|---|---|
| 07 | [Active Directory ACL Misconfiguration](experiments/07-ad-acl-misconfiguration/README.md) | Excessive permissions and access control remediation |
| 08 | [Kerberos Delegation Abuse](experiments/08-kerberos-delegation-abuse/README.md) | Resource-Based Constrained Delegation (RBCD) |
| 09 | [MachineAccountQuota Abuse](experiments/09-machine-account-quota-abuse/README.md) | Unauthorized computer account creation and quota hardening |

Each experiment has a dedicated report describing its methodology, configuration, test results, remediation, and limitations.

## Tools and Technologies

| Tool / Technology | Purpose |
|---|---|
| Windows Server 2019 | Active Directory Domain Services and domain administration |
| Windows 10 | Domain-joined workstation testing |
| Kali Linux | Security assessment environment |
| PowerShell Active Directory Module | Domain configuration, enumeration and hardening |
| Impacket | Kerberos and Active Directory security testing |
| BloodHound Community Edition | Active Directory relationship and permission analysis |
| bloodhound-python | Active Directory data collection |
| Nmap | Network and service discovery |
| Wireshark | Network traffic analysis |

Additional utilities and tools are documented in the relevant experiment reports where applicable.

## Repository Structure

```text
active-directory-security-lab/
│
├── README.md
│
├── experiments/
│   ├── 01-password-policy/
│   ├── 02-asrep-roasting/
│   ├── 03-kerberoasting/
│   ├── 04-password-spraying/
│   ├── 05-ldap-security/
│   ├── 06-ntlm-relay-smb-signing/
│   ├── 07-ad-acl-misconfiguration/
│   ├── 08-kerberos-delegation-abuse/
│   └── 09-machine-account-quota-abuse/
│
├── evidence/
│   └── experiments/
│       ├── 01-password-policy/
│       ├── 02-asrep-roasting/
│       ├── 03-kerberoasting/
│       └── 04-password-spraying/
│
└── hardening/
    ├── kerberos/
    └── password-policy/
```

Evidence for later experiments is maintained inside the corresponding experiment directories. Each experiment README identifies its supporting evidence.

The `hardening/` directory contains supporting hardening configurations and scripts.

## Security Assessment and Hardening Approach

The experiments address several important Active Directory security areas:

- **Password security:** password policy enforcement and resistance to password-based attacks.
- **Kerberos security:** pre-authentication, service tickets and delegation configuration.
- **Directory services security:** LDAP signing, LDAPS and channel binding.
- **Authentication protocols:** NTLM relay conditions and SMB signing.
- **Access control:** identification and remediation of excessive Active Directory permissions.
- **Computer account management:** restriction of default machine account creation.

Remediation is validated through post-hardening tests wherever applicable. Results are documented with the relevant technical observations and evidence.

## Project Scope

This project focuses on Windows Server, Windows client systems and Active Directory security.

Kali Linux is used exclusively as the security assessment machine within the controlled laboratory.

All attack simulations and configuration changes were performed for educational purposes in an isolated test environment using dedicated test accounts and objects.

The experiments demonstrate specific security weaknesses and their remediation. They do not represent a complete assessment of every possible Active Directory attack path or production infrastructure.

## Key Learning Outcomes

- Understanding Active Directory authentication and authorization mechanisms.
- Assessing common Kerberos and NTLM security weaknesses.
- Identifying insecure LDAP and SMB configurations.
- Analyzing Active Directory permissions and delegation relationships.
- Performing controlled security tests with industry-standard tools.
- Applying Windows and Active Directory hardening measures.
- Validating remediation through repeatable testing.
- Producing technical documentation supported by practical evidence.

## Disclaimer

This repository is intended for educational purposes and authorized security testing only.

All experiments were conducted in a controlled laboratory environment. The techniques documented here must not be used against systems or networks without explicit authorization.
