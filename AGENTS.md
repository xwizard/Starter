This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The **Starter** — a GUI launcher for the MaSzyna (EU07) train simulator. Originally written in Delphi/VCL by
Damian Skrzek ("szczawik"), GPL v3. It lets the user pick a scenario and vehicle, edits the scenery `.scn`
file and `eu07.ini`, then launches the simulator binary with `-s $<scenery>.scn -v <vehicle>`.

**This is now a Lazarus/FPC-only project.** Delphi/VCL support has been dropped completely. There is no
dual-build anymore, no reference Delphi build to protect, and no obligation to keep non-`{$IFDEF FPC}`
behaviour untouched. Feel free to delete Delphi-only code, `.dfm` forms, `Vcl.*`/`Winapi.*` references, and
Delphi project files (`Starter.dpr`, `Starter.dproj`, `StarterProject.groupproj`) as they're encountered —
don't preserve them "just in case."

Overriding rules:

1. **Windows is the priority target** (that's the whole point of finally dropping Delphi), then macOS,
   then Linux — all via Lazarus/FPC.
2. Simplify as you go: once a unit no longer needs to support Delphi, collapse the `{$IFDEF FPC}` branching
   and drop the dead `{$ELSE}` VCL code rather than leaving it in place.
3. We still merge from upstream (`szczawikDS/Starter`, Delphi-only) periodically. When resolving those merge
   conflicts, port the *intent* of upstream's Delphi changes into the Lazarus-only codebase rather than
   re-introducing a Delphi build path.

Port status (as of this writing): compiles on macOS arm64, but **launches with errors and most features do
not work yet**; the Lazarus build on **Windows and Linux is unverified**. Diagnosing and fixing runtime is
the current front of work.

## Repo layout / branches

Two remotes, each tracked by a dedicated local branch (there is intentionally **no** local `master` — it
would be ambiguous between the two remotes):

- `origin` = `szczawikDS/Starter` (upstream original, Delphi-only) → tracked by local **`master-szczawik`**.
- `wizard` = `xwizard/Starter` (the working fork, Lazarus-only) → tracked by local **`master-wizard`**.

Branches:

- `master-wizard` — **current working base**; tracks `wizard/master`. The Lazarus-only tree. Push work here.
- `master-szczawik` — the upstream Delphi original; tracks `origin/master` (identical to it); used only as
  the merge source when pulling in upstream changes, never built or run directly.
- `lazarus-port` — where the original port commit originated; historical reference.
- Directories: `src/` (all units, `.lfm` form resources — `.dfm` files are legacy and being phased out),
  `components/` (`uIdHTTPProgress.pas`, Indy-based), `img/`, `res/` (flag bitmaps + `reguly.txt`), `lang/`
  (`lang-{pl,en,cz,hu,ru}.txt`, cp1250).

## Architecture

- **Toolchain:** Lazarus/FPC only. `Starter.lpr` + `Starter.lpi`; `.lfm` forms; LCL. `Starter.lpr` is
  `{$mode delphi}{$H+}`, pulls `cthreads` under `{$IFDEF UNIX}`, includes `uUpdater` only under
  `{$IFDEF MSWINDOWS}`, links `{$R *.res}` only on Windows, and wraps startup in a try/except that writes
  `startup_error.log`.
- **Platform differences within the Lazarus build** still live behind compiler guards: `{$IFDEF MSWINDOWS}`
  for Windows-only APIs (e.g. `ShellExecuteEx`), `{$IFDEF UNIX}` for mac/Linux-only bits, and plain LCL
  everywhere else. See `src/uMain.pas` and `src/uUtilities.pas` for the existing pattern — follow it rather
  than reintroducing raw `Winapi.*`/`Vcl.*` code.
- **Form resources:** forms load `.lfm` (`{$R *.lfm}`). Any lingering `{$IFDEF FPC}...{$ELSE}{$R *.dfm}{$ENDIF}`
  guard and the paired `.dfm` file can be collapsed/deleted once encountered.
- **`src/uLazFixups.pas`** — `ApplyLazFixups` (called first thing in `Starter.lpr`) uses
  `RegisterPropertyToSkip` so form resources load without `EReadError` on properties that don't exist in LCL
  (leftovers from the VCL originals). Current inventory: `Bevel*`/`Ctl3D`/`ParentCtl3D` on
  `TScrollBox`/`TTreeView`/`TListBox`, and `TDateTimePicker.Format`. **When a `.lfm` fails to load on an
  unknown property, extend this unit** — skipping a property only drops a cosmetic design-time setting.
- **Encoding:** sources are **cp1250** (Polish text/comments). `Starter.lpi` forces `-Fccp1250`. Runtime
  string conversion uses `LazUTF8`/`LConvEncoding` (see `uUtilities.pas` implementation uses). Be careful
  editing string literals — the files are not UTF-8.
  - **Editor/agent gotcha:** generic text-editing tools that decode files as UTF-8 before writing them back
    (including AI coding assistants) will silently re-save a whole cp1250 file as UTF-8 on any edit — even one
    that only touches a plain-ASCII line elsewhere in the file. Bytes that don't map cleanly get replaced with
    the U+FFFD `�` character, permanently destroying the original Polish text. Check `file <path>` before and
    after editing a `.pas`/`.lpr`/`.dpr` file — it should read "Non-ISO extended-ASCII text", not "UTF-8 text";
    if it flips, the edit path isn't byte-safe. Prefer byte-level tools (e.g. `perl -0777 -i -pe 's/.../.../s'`
    on the raw file) for edits to these files. If a file has already been corrupted this way, restore it from
    git history (`git show HEAD:<path>`) and reapply the intended change through a byte-safe path instead.

## Building

`build_macos.sh` (or equivalent) wraps the Lazarus toolchain; otherwise build directly with `lazbuild`.

- **Windows (priority target):** `lazbuild Starter.lpi`; `{$R *.res}` links `Starter.res`. **Unverified** —
  the macOS-only linker flags in the `.lpi` CustomOptions must be gated per target OS before this builds
  cleanly here.
- **macOS (arm64, currently the only build actually verified working):** `lazbuild Starter.lpi` → binary
  `./Starter`. The `.lpi` carries macOS linker flags in CustomOptions: `-Fccp1250 -k-framework
  -kUserNotifications -k-ld_classic`; unit output goes to `lib/$(TargetCPU)-$(TargetOS)`. Requires Lazarus's
  **datetimectrls** component (paths already in the `.lpi`).
- **Linux:** `lazbuild Starter.lpi`. The macOS-only linker flags above will need to be gated per target OS
  before this builds cleanly. **Unverified.**
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
- **Updater is unported Delphi/VCL/Indy code, gated off by default:** `uUpdater.pas` (and its DFM,
  `uUpdater.dfm`) and `components/uIdHTTPProgress.pas` still use `Vcl.*`/`Winapi.*` and Indy
  (`IdHTTP`/`IdSSLOpenSSL`) and would not compile under FPC even on Windows. Rather than delete or port them,
  their inclusion/call sites (`Starter.lpr`, `uMain.pas`, `uSettings.pas`) are now gated behind
  `{$IFDEF ENABLE_UPDATER}`, which is undefined everywhere, so the feature compiles out entirely until someone
  decides its fate. **TODO:** confirm whether auto-update is still wanted; if yes, port it to FPC's own
  `fphttpclient` instead of Indy (which isn't wired into `Starter.lpi`'s search path) and drop the flag; if no,
  delete `uUpdater.pas`/`.dfm` and `components/uIdHTTPProgress.pas` outright. `uInstaller.pas` (Indy + JCL
  `JclCompression`) is separate, dead code — not referenced from `Starter.lpr` or anywhere else — left in place
  pending the same decision.
- Leftover WinAPI-only code paths (e.g. `SendMessage(...WM_SETREDRAW...)` `uRules.pas:244`,
  `LoadFromResourceName(HInstance,'keyboard')` `uKeyboard.pas:249+`) still need a working non-Windows
  equivalent when those forms are touched.

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
