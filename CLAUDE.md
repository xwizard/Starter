This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The **Starter** — a GUI launcher for the MaSzyna (EU07) train simulator. Written in Delphi/VCL by
Damian Skrzek ("szczawik"), GPL v3. It lets the user pick a scenario and vehicle, edits the scenery
`.scn` file and `eu07.ini`, then launches the simulator binary with `-s $<scenery>.scn -v <vehicle>`.

A **port to Lazarus/FPC** is in progress so the launcher runs on **macOS and Linux** as well as Windows.
It is a **dual-build**: the same `.pas` units feed two toolchains. The overriding rules:

1. **macOS is the priority target**, then Linux.
2. **The Delphi/Windows build must stay untouched** — never change behaviour of code outside `{$IFDEF FPC}`.
3. **The Lazarus build must also work on Windows**, not only mac/Linux.

Port status (as of this writing): compiles on macOS arm64, but **launches with errors and most features do
not work yet**; the Lazarus build on **Windows and Linux is unverified**. Diagnosing and fixing runtime is
the current front of work.

## Repo layout / branches

Two remotes, each tracked by a dedicated local branch (there is intentionally **no** local `master` — it
would be ambiguous between the two remotes):

- `origin` = `szczawikDS/Starter` (upstream original) → tracked by local **`master-szczawik`**.
- `wizard` = `xwizard/Starter` (the working fork) → tracked by local **`master-wizard`**.

Branches:

- `master-wizard` — **current working base**; tracks `wizard/master`. The unified dual-build tree
  (`origin/master` content + the port commit `Port project from Delphi to Lazarus/FPC`). Push work here.
- `master-szczawik` — the pre-port Delphi original; tracks `origin/master` (identical to it); reference only.
- `lazarus-port` — where the port commit originated.
- Directories: `src/` (all units, plus `.dfm` **and** `.lfm` form resources), `components/`
  (`uIdHTTPProgress.pas`, Indy-based), `img/`, `res/` (flag bitmaps + `reguly.txt`), `lang/`
  (`lang-{pl,en,cz,hu,ru}.txt`, cp1250).

## Dual-build architecture

This is the most important thing to understand before editing. Both toolchains compile the **same units**;
platform differences live behind compiler guards. Follow the existing pattern — do not fork files.

- **Delphi (Windows, do not disturb):** `Starter.dpr` + `Starter.dproj` + `StarterProject.groupproj` +
  `Starter.res`; `.dfm` forms; VCL (`Vcl.*`); Carbon style (`TStyleManager.TrySetStyle('Carbon')`, `Carbon.vsf`).
- **Lazarus/FPC:** `Starter.lpr` + `Starter.lpi`; `.lfm` forms; LCL. `Starter.lpr` is `{$mode delphi}{$H+}`,
  pulls `cthreads` under `{$IFDEF UNIX}`, includes `uUpdater` only under `{$IFDEF MSWINDOWS}`, links `{$R *.res}`
  only on Windows, and wraps startup in a try/except that writes `startup_error.log` under `{$IFDEF FPC}`.
- **`uses` clauses are guarded per unit:** `{$IFDEF FPC}` → LCL units (`LCLIntf, LCLType, LMessages, Forms, …`),
  `{$ELSE}` → `Winapi.Windows, Winapi.Messages, Vcl.*`. See `src/uMain.pas:29` (interface uses) and
  `src/uUtilities.pas:82` (implementation uses). Raw `Winapi.Windows`/`Vcl.*` references are therefore already
  inside Delphi-only branches.
- **Form resources are dual:** each form does `{$IFDEF FPC}{$R *.lfm}{$ELSE}{$R *.dfm}{$ENDIF}`
  (e.g. `src/uMain.pas:808`). `.dfm` and `.lfm` must be kept in sync when a form changes.
- **`src/uLazFixups.pas`** — FPC-only. `ApplyLazFixups` (called first thing in `Starter.lpr`) uses
  `RegisterPropertyToSkip` so shared form resources load without `EReadError` on VCL-only published props.
  Current inventory: `Bevel*`/`Ctl3D`/`ParentCtl3D` on `TScrollBox`/`TTreeView`/`TListBox`, and
  `TDateTimePicker.Format`. **When a `.lfm` fails to load on a VCL-only property, extend this unit** — skipping
  a property only drops a cosmetic design-time setting.
- **Encoding:** sources are **cp1250** (Polish text/comments). `Starter.lpi` forces `-Fccp1250`. Under FPC,
  runtime string conversion uses `LazUTF8`/`LConvEncoding` (see `uUtilities.pas` implementation uses). Be
  careful editing string literals — the files are not UTF-8.
- **Golden rule:** platform-specific code goes behind `{$IFDEF FPC}` / `{$IFDEF MSWINDOWS}` / `{$IFDEF UNIX}`.
  Never alter the non-FPC branch's behaviour.

## Building

There is no build script yet; build with the IDE toolchains directly.

- **macOS (arm64, primary):** `lazbuild Starter.lpi` → binary `./Starter`. The `.lpi` carries macOS linker
  flags in CustomOptions: `-Fccp1250 -k-framework -kUserNotifications -k-ld_classic`; unit output goes to
  `lib/$(TargetCPU)-$(TargetOS)`. Requires Lazarus's **datetimectrls** component (paths already in the `.lpi`).
- **Linux (Lazarus):** `lazbuild Starter.lpi`. The macOS-only linker flags above will need to be gated per
  target OS before this builds cleanly. **Unverified.**
- **Windows (Lazarus):** `lazbuild Starter.lpi`; `{$R *.res}` links `Starter.res`. **Unverified.**
- **Windows (Delphi, reference build):** open `Starter.dproj` / `StarterProject.groupproj` in RAD Studio and
  build the VCL app. This is the build that must never regress.
- FPC/Lazarus artifacts (`/Starter`, `/Starter.app/`, `/lib/`, `*.lps`, `*.o`) are gitignored.

## How it launches the game

The launcher's contract with the engine (see sibling repo `../maszyna`):

- **CLI:** the engine accepts only `-s <sceneryfile>` and `-v <vehicle>`
  (`../maszyna/application/application.cpp`, `init_settings`).
- **Working directory matters:** the engine resolves all asset paths (`scenery/`, `dynamic/`, …) relative to
  its CWD, so the launcher runs the exe with working dir set to the game install root. Active/generated scenery
  files are prefixed `$`, hence the launcher passes `-s $<name>.scn`.
- **Config file:** engine reads `eu07.ini` from `%APPDATA%\MaSzyna\` (Win) /
  `~/Library/Application Support/MaSzyna/` (mac) / `~/.config/MaSzyna/` (Linux), falling back to `eu07.ini` in
  CWD (`../maszyna/utilities/utilities.cpp`, `user_config_path`).
- **Launcher code path:** `TMain.actStartExecute` (`src/uMain.pas:1727`) → `TLexParser.ChangeConfig` writes
  the scenery config → `TMain.LaunchSimulator` (`src/uMain.pas:1934`) → `RunSimulator`
  (`src/uUtilities.pas:320`). `RunSimulator` uses `ShellExecuteEx` under `{$IFDEF MSWINDOWS}` and **`TProcess`**
  otherwise, with `CurrentDirectory = ExtractFileDir(exe)`. Exe is chosen from `eu07*.exe`, newest = "Autom."
  (`src/uSettings.pas`).

## Porting surface / known issues

The port has already wired up the big cross-platform mechanics — treat these as **done** and follow their
pattern rather than reintroducing WinAPI:

- Game launch: `RunSimulator` → `TProcess` on non-Windows (`uUtilities.pas:320`).
- Install dir `Util.DIR`: `IncludeTrailingPathDelimiter(GetCurrentDir)` on non-Windows, hardcoded
  `C:\MaSzyna\` on Windows (`uUtilities.pas`, `TUtil.Create`, ~line 449). **Consequence:** on mac/Linux the
  launcher must be started with CWD = the game install dir (as `../pctga/StarterNG.command` does for the C#
  launcher).
- Per-user config dir `INIPath`: `%APPDATA%\MaSzyna\` on Windows, `GetAppConfigDir(False)+'MaSzyna'` otherwise
  (`uUtilities.pas:95`). **Watch out:** verify this matches where the engine reads `eu07.ini` on macOS
  (`~/Library/Application Support/MaSzyna/`) — a mismatch here is a likely source of "settings don't apply".
- `GetFileVersion` version-info API is Windows-only and returns `''` elsewhere (`uUtilities.pas:494`) — cosmetic.

Genuinely open items:

- **Runtime is broken** on macOS (launches with errors, most features non-functional). Root causes not yet
  diagnosed — likely `.lfm`/LCL loading, path/encoding, or resource issues. Check `startup_error.log`.
- **Windows and Linux Lazarus builds are unverified**; the macOS-only linker flags in `Starter.lpi` must be
  gated by target OS for a clean Linux/Windows build.
- **Updater/installer are Windows-only:** `uUpdater` (Indy `IdHTTP`/`IdSSLOpenSSL` via
  `components/uIdHTTPProgress.pas`) is compiled only under `{$IFDEF MSWINDOWS}`; `uInstaller` (Indy + JCL
  `JclCompression`) is not referenced by `Starter.lpr`. On mac/Linux these stay disabled unless replaced with
  FPC equivalents.
- WinAPI still referenced inside Delphi-only branches (e.g. `SendMessage(...WM_SETREDRAW...)` `uRules.pas:244`,
  `LoadFromResourceName(HInstance,'keyboard')` `uKeyboard.pas:249+`). Ensure the FPC branch has a working
  equivalent when touching those forms.

## Sibling repos (context, not part of this repo)

- `../maszyna` — the EU07 engine (C++/CMake). Source of the CLI / `eu07.ini` / `.scn` contract above. Has its
  own CLAUDE.md.
- `../pctga` — the game install & asset dir (`eu07.exe`, `scenery/`, `starter/starter.ini`, `eu07.ini`). Use it
  to run and test the launcher. **Do not modify.**
- `../starterng` — a separate C#/.NET 9 rewrite of the launcher; unrelated to this repo beyond sharing the same
  launch contract.

## Verification

No test suite, no lint. Verification = build succeeds, then run against a real install in `../pctga`.

- macOS loop: `lazbuild Starter.lpi`, then run `./Starter` with **CWD = `../pctga`** (so `scenery/`,
  `dynamic/`, `databases/` resolve). Check `startup_error.log`, whether forms load, whether the scenery/vehicle
  lists populate, and whether Start actually spawns `eu07`.
- **Never regress Delphi:** when editing shared `.pas`, keep everything outside `{$IFDEF FPC}` byte-for-byte
  equivalent; the RAD Studio build of `Starter.dproj` is the reference. Keep `.dfm` and `.lfm` in sync.
