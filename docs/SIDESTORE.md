# Personal TikTok build

Source fork: https://github.com/danzola01/BHTikTokPlusPlus
Upstream: https://github.com/raulsaeed/BHTikTokPlusPlus
Initial upstream commit: 6add794 (2025-08-03). Personal branch: `sidestore`.

The user chose to replace App Store TikTok. Preserve original bundle ID
`com.zhiliaoapp.musically` and app name. SideStore may adjust identity during
signing; this does not preserve the official signature. Save local TikTok drafts
before uninstalling the App Store version. Expect a new login.

## Status

No decrypted TikTok base IPA is available in this workspace yet. Upstream does
not document a supported base version. Compilation, packaging, and phone behavior
are separate checks; successful compilation does not establish compatibility.
No installable IPA has been produced. Login persistence must be checked early.

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
