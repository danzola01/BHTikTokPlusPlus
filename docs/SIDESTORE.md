# Personal TikTok build

Source fork: https://github.com/danzola01/BHTikTokPlusPlus
Upstream: https://github.com/raulsaeed/BHTikTokPlusPlus
Initial upstream commit: 6add794 (2025-08-03). Personal branch: `sidestore`.

The user chose to replace App Store TikTok. Preserve original bundle ID
`com.zhiliaoapp.musically` and app name. SideStore may adjust identity during
signing; this does not preserve the official signature. Save local TikTok drafts
before uninstalling the App Store version. Expect a new login.

## Status

Supplied base: TikTok 47.7.0 (477034), minimum iOS 15.0. Upstream does
not document a supported base version. Compilation, packaging, and phone behavior
are separate checks; successful compilation does not establish compatibility.
The first installable IPA was produced and verified below. Phone compatibility
and login persistence remain unverified.

## Build

Run commands from `tiktok/`. The workflow uses hosted macOS, the upstream 16.5
SDK target, arm64, pinned Theos/Logos and cyan. It injects BHTikTok and cyan's
hooking dependencies, preserving identity. Embedded extensions are removed for
the initial SideStore trial. Widgets/share extensions will be unavailable.
No additional compatibility helper or FLEX explorer is injected initially.
Upstream feature defaults and runtime hooks are unchanged. HD download code
uses the third-party tikwm.com service; ordinary downloads should be tested first.

Compile without a proprietary base:

```bash
bash scripts/build_ipa.sh --tweak-only
```

Supply a plain decrypted base under ignored `packages/`, then inspect:

```bash
python3 scripts/inspect_ipa.py packages/TikTok.ipa --require-decrypted --output output/base-ipa.json
```

Review bundle ID, version, minimum OS, hash, encryption records and existing
libraries. Inspection does not establish provenance or device compatibility.
Store the inspected base in an unpublished draft release in the personal fork.
Set `ipa_release` and `ipa_sha256` in `config/sidestore-inputs.json`.

```bash
bash scripts/build_ipa.sh --dry-run
bash scripts/build_ipa.sh
```

The workflow requires a draft with exactly one IPA and verifies the input hash
and unencrypted executables. It validates output identity and library presence,
and removes embedded extensions. Inspect injected load commands before installation.
Compiled tweak artifacts contain no proprietary app. Finished IPAs are stored
only in unpublished draft releases named `tiktok-ipa<RUN_ID>-<ATTEMPT>`.
Retrieve with authenticated `gh release download`; never publish these releases.
Never commit IPAs, credentials, signing material or signed URLs.

## Phone checks and updates

Install through the existing SideStore setup after saving local drafts and
removing regular TikTok. Verify launch/login, two force-quit/reopen cycles,
feed loading, ad blocking, ordinary downloads, optional live hiding, DMs and
SideStore refresh. Device checks require user reports. Do not assume push
notifications work with personal signing.

Reuse the same base while compatible. Merge reviewed upstream changes into
`sidestore`, rebuild and install using the same identity/signing account.
Signing refresh does not rebuild the app. Record run/source/output hashes and
user results here. Commit and push app changes before updating the parent
submodule revision.

## Preparation validation

Workflow YAML parsed and all shell blocks passed `bash -n`. The dispatcher
rejects empty base inputs. Synthetic IPA checks accepted unencrypted metadata,
rejected encrypted metadata, and removed an extension in `Extensions/`.
Upstream included a FLEXing gitlink without a `.gitmodules` URL, causing the
first run to fail at checkout:
https://github.com/danzola01/BHTikTokPlusPlus/actions/runs/43695168933
The unused gitlink was removed (the Makefile does not build it).
Compile-only retry:
https://github.com/danzola01/BHTikTokPlusPlus/actions/runs/43695215948
Source: `567bb98`. Hosted arm64 compilation succeeded; the compiled tweak
was downloaded to `output/BHTikTok.dylib` (ignored by Git).
SHA-256: `cee22303c94440be7467e712d0a149a772ae15ad6807ab1b5d9d9f75b2c32b7b`.
Compile-only preparation did not establish IPA packaging or phone behavior.
Base transferred and inspected: archive CRC passed; all 26 detected Mach-O
files report cryptid 0, with no dylibs or provisioning profiles detected.
Size: 541,238,484 bytes. SHA-256:
`9d5d946248145f884c021c78c1826e089834a14ca5cefba9b2d038338894b5b1`.
Base draft tag: `base-tiktok-47.7.0`. This is a compatibility trial.

## First packaged build

Build succeeded: https://github.com/danzola01/BHTikTokPlusPlus/actions/runs/43696120540
Source: `08d37b4228219f821ad2c6b5604a4109985a00db`.
Remote base size/digest match the inspected file; base remains a draft.
Output draft tag: `tiktok-ipa43696120540-1`.
Owner-only page: https://github.com/danzola01/BHTikTokPlusPlus/releases/tag/untagged-ea823ddc646dcf39d54f
Asset: `TikTok.ipa`, 504,947,959 bytes. SHA-256:
`77894fb7c59cb6e1833fd8516a4386e9805c326983b028ad29e454163979386d`.
Local copy: `output/first-build/TikTok.ipa`.

Hosted compilation/packaging passed. Downloaded IPA hash, archive integrity,
unencrypted metadata, original identity, and absence of embedded extensions
passed local verification. Main executable loads `@rpath/BHTikTok.dylib`;
its CydiaSubstrate framework dependency is bundled. Inspection reports and
load commands are saved under ignored `output/first-build/`.
Output release remains unpublished. User subsequently installed the app and
reported login failure as recorded below; successful login is not verified.

On iPhone, sign into GitHub as the owner, open the draft page, and download
`TikTok.ipa` from Assets. Save App Store TikTok drafts before removing that app.
Install the IPA through SideStore → My Apps → + using the existing signing
account/VPN setup. Test launch, login and two force-quit/reopen cycles first,
then ad removal, normal downloads and SideStore refresh. Report device results.

## First device login failure

User reports being unable to log in, receiving “maximum number of attempts
exceeded” (wording paraphrased from their message). The exact login method,
whether it happened on the first attempt, and Safari login result are pending.
Do not label this an account lockout or claim a tweak fix without a comparison.

A historical upstream report describes the same message on the first attempt:
https://github.com/BandarHL/BHTikTok/issues/4
A maintainer attributed that old case to changed bundle IDs. Our packaged IPA
retains the original ID; the identity after SideStore signing is not established.
That old report does not prove the cause on TikTok 47.7.0.

The signed iPhone/server login flow cannot be reproduced in this Linux checkout.
Packaging checks cannot assert this symptom. Next evidence requested: login
method, first-attempt behavior, and whether the same account can log in via
Safari. Avoid repeated app login attempts while gathering the comparison.
No runtime hooks have been changed and no replacement build is claimed to fix it.
