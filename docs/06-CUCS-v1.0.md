# Computer Use Capability Scale (CUCS) v1.0

A scaffolded scale for measuring how deeply a person or agent can interact with a computer — from opening a file through controlling operating systems, engineering custom execution environments, and designing entirely new computing architectures.

The key distinction: each level represents a change in capability, abstraction, or control — not simply a more complicated way to perform the same task.

## 1. The 12-level scale

## Level 1 — GUI navigation

Basic interaction

Navigate the desktop, open folders, and launch files using graphical interfaces.

Example: Double-click `Documents`, open `report.docx`, edit and save.

Tools: Mouse, keyboard, File Explorer.

## Level 2 — CLI navigation

Command execution

Use a shell to navigate directories, inspect files, and launch applications.

Example (PowerShell):

```
Set-Location "$HOME\Desktop"
Get-ChildItem
notepad.exe .\notes.txt
```

Tools: PowerShell, CMD, Bash, terminal.

## Level 3 — Remote access

Networked interaction

Connect to another computer and operate within its environment.

Example:

```
ssh user@server.example.com
cd /srv/project
ls -la
nano README.md
```

Tools: SSH, remote shells, RDP. SSH connects to a host; the directory is accessed after login.

## Level 4 — Scripting and automation

Automate repeatable sequences of computer operations.

Example: A PowerShell script creates a project folder, checks required files, backs up data, and reports errors.

Tools: PowerShell scripts, Bash scripts, Python, scheduled tasks.

## Level 5 — Programmatic control

Interact with files, processes, APIs, databases, and applications through code.

Example: A Python program scans a directory, parses every JSON file, validates schemas, and writes a report.

Tools: Python, Rust, APIs, SQL, filesystem libraries.

## Level 6 — Environment management

Create and manage isolated, reproducible execution environments.

Example: Launch a Docker container containing Python, PostgreSQL, and an application with pinned dependencies.

Tools: Docker, virtual machines, virtual environments, package managers.

## Level 7 — System administration

Control users, permissions, services, networking, storage, and operating-system configuration.

Example: Configure a Linux server with restricted users, a mounted data volume, a service, firewall rules, and automated backups.

Tools: Linux administration, systemd, filesystems, networking, security policies.

## Level 8 — Infrastructure orchestration

Coordinate multiple machines, services, containers, and deployment pipelines as one system.

Example: Deploy an application, database, and cache; run integration tests; monitor health; roll back a failed release.

Tools: CI/CD, Terraform, Ansible, Kubernetes, monitoring.

## Level 9 — Custom computing interfaces

Build a custom interface that changes how people or agents interact with existing systems.

Example: Create a command such as `project open specification` that resolves a logical project identifier, checks permissions, locates the artifact, and opens it.

Tools: Custom CLIs, command dispatchers, application frameworks, workflow engines.

## Level 10 — Custom filesystem and runtime

Build a virtual filesystem, namespace, or execution runtime that changes how resources are represented and accessed.

Example: A logical path such as `workspace://project/specification` maps to a validated object stored across a local disk, database, or remote server.

Tools: FUSE, virtual filesystems, object stores, custom runtimes.

Important: This can be implemented on top of an existing OS; a custom filesystem does not require a custom OS.

## Level 11 — Operating-system engineering

Design or modify core OS mechanisms: process isolation, memory management, scheduling, device interfaces, and filesystem integration.

Example: Build a small educational kernel that boots in a virtual machine, manages memory, and reads files from a custom filesystem.

Tools: C, C++, Rust, assembly, bootloaders, emulators, kernel APIs.

## Level 12 — Computing architecture design

Define an integrated computing model: resource identity, storage semantics, execution rules, security boundaries, and interfaces.

Example: Design an OS where every artifact has a stable identity, explicit permissions, versioned state, and a machine-verifiable execution contract.

Tools: OS architecture, programming-language design, distributed systems, formal methods, hardware architecture.

## 2. Capability matrix

| Level | Capability                     | Unit of control          | Evidence of competence                          |
| ----- | ------------------------------ | ------------------------ | ----------------------------------------------- |
| 1     | GUI navigation                 | File or application      | Opens and edits a file                          |
| 2     | CLI                            | Command and path         | Executes commands correctly                     |
| 3     | Remote access                  | Remote host/session      | Authenticates and operates remotely             |
| 4     | Automation                     | Repeatable procedure     | Script runs reliably                            |
| 5     | Programmatic control           | Data and APIs            | Program manipulates and validates resources     |
| 6     | Environment management         | Isolated environment     | Reproduces a working environment                |
| 7     | System administration          | OS resources             | Configures permissions, services, and storage   |
| 8     | Orchestration                  | Distributed services     | Deploys and recovers a multi-service system     |
| 9     | Custom interfaces              | User-defined commands    | Implements a reliable abstraction               |
| 10    | Filesystem/runtime engineering | Resource model           | Implements custom resource access and execution |
| 11    | OS engineering                 | Kernel and core services | Builds or modifies working OS mechanisms        |
| 12    | Architecture design            | Entire computing model   | Specifies and validates a coherent system       |

## 3. Where Vault 1 sits

| Level | In Vault 1 |
| ----- | ---------- |
| 1 — GUI navigation | the desktop, the input and vectors folders |
| 2 — CLI | `Set-Location`, `Get-ChildItem`, running each tool |
| 4 — Scripting and automation | the scan, gap, smoke-test and restore scripts |
| 5 — Programmatic control | Python (vector-snake, `capstone_rag.py`) and SQL (`audit.sql`) driving files and a local API |
| 6 — Environment management | a project venv built with uv; one governed model at a time |

