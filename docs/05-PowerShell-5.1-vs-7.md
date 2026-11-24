# PowerShell 5.1 vs PowerShell 7: Quick Reference

The essential distinction: Windows PowerShell 5.1 is the legacy Windows-integrated edition; PowerShell 7 is the modern, cross-platform edition. They can coexist on the same machine.

## 1. At a glance

| Feature           | Windows PowerShell 5.1             | PowerShell 7                                                  |
| ----------------- | ---------------------------------- | ------------------------------------------------------------- |
| Executable        | `powershell.exe`                   | `pwsh.exe`                                                    |
| Runtime           | .NET Framework                     | Modern .NET                                                   |
| Operating systems | Windows                            | Windows, Linux, macOS                                         |
| Installation      | Built into Windows                 | Installed separately                                          |
| Updates           | Tied to Windows servicing          | Updated independently                                         |
| Compatibility     | Legacy Windows modules and scripts | Modern modules, APIs and scripting                            |
| Default shell     | Windows legacy shell               | Modern PowerShell shell, if explicitly launched or configured |
| Typical use       | Older administration scripts       | New development and automation                                |

Important: Installing PowerShell 7 does not replace or remove PowerShell 5.1. Some older Windows-specific modules work only in 5.1 or require compatibility workarounds in 7.

## 2. Default installation vs separate installation

Windows PowerShell 5.1

Included with Windows

- Usually available immediately on Windows 10 and 11.
- Launch via Start Menu, `powershell.exe`, or Windows Terminal.
- No separate installation normally required.
- Receives Windows-related maintenance rather than modern PowerShell feature releases.

PowerShell 7

Separate installation

- Downloaded and installed independently.
- Launched using `pwsh.exe`.
- Installed side-by-side with 5.1.
- Suitable for current scripting, development tooling and cross-platform automation.

## 3. Install or update PowerShell 7

For a standard Windows 11 development machine, use WinGet.

Check the installed version:

```
pwsh --version
```

Check whether WinGet can see the package:

```
winget search --id Microsoft.PowerShell --exact
```

Install PowerShell 7:

```
winget install --id Microsoft.PowerShell --source winget
```

Upgrade an existing installation:

```
winget upgrade --id Microsoft.PowerShell
```

Microsoft's installation guide (Microsoft Learn, "Installing PowerShell on Windows") documents the supported options.

Version note: WinGet installs the newest release it knows, so check the version it reports (`pwsh --version`) rather than assuming one. SPOOKY ran 7.6.7 during the recording and 7.6.9 afterwards.

## 4. Verify both installations

Run these commands in either shell:

```
powershell.exe -NoProfile -Command '$PSVersionTable'
pwsh.exe -NoProfile -Command '$PSVersionTable'
```

Or inspect the current session:

```
$PSVersionTable.PSVersion
$PSVersionTable.PSEdition
$PSHOME
```

Expected editions:

- PowerShell 5.1: `Desktop`
- PowerShell 7: `Core`

## 5. Practical recommendation

| Task                                          | Preferred shell                         |
| --------------------------------------------- | --------------------------------------- |
| New `.ps1` scripts and development automation | PowerShell 7                            |
| Node.js, Python, Git and Docker workflows     | PowerShell 7                            |
| Legacy Windows administration modules         | Test compatibility; use 5.1 if required |
| Existing scripts explicitly designed for 5.1  | Keep using 5.1 until tested             |
| Cross-platform automation                     | PowerShell 7                            |

Bottom line: Keep both installed. Use `pwsh.exe` as your normal development shell and retain `powershell.exe` as your Windows compatibility shell. They have separate profiles, module paths and executable names, so changing one does not automatically configure the other.


**Seen in Vault 1:** a new terminal tab opened Windows PowerShell 5.1 (where `-Encoding utf8NoBOM` doesn't exist) or Command Prompt (where `&` and `Start-Transcript` don't exist). The prompt must start with `PS`; type `pwsh` to switch.
