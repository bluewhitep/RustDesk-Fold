# RustDesk Fold Public Import Strategy

Applicable versions: public baseline preparation
Audience: Maintainer
Status: Active

RustDesk Fold should have a public repository surface that is clearly separate
from official RustDesk. The public repository should present Fold as the primary
project, keep Fold README and release documents at the top level, and avoid
exposing old GitHub Actions, self-hosted runner experiments, or upstream release
links as the active project workflow.

## First Public Release: Clean Source Snapshot

Use a new branch based on the selected official upstream RustDesk baseline
instead of publishing the current development history. The public Fold branch
should contain one Fold import commit on top of that upstream baseline, so the
Fold changes are reviewable as a bounded downstream delta.

Recommended shape:

```text
RustDesk-Fold/
  README.md
  README_FOLD.md
  RELEASE_FOLD_MANUAL.md
  FOLD_PUBLIC_IMPORT_STRATEGY.md
  UPGRADE_FOLD.md
  UPSTREAM.md
  flutter/
  libs/
  src/
  tools/
  ...
```

The clean source snapshot contains the full source tree needed to build
RustDesk Fold at the selected release baseline, but does not retain old Fold
development commits, previous Fold `.github/workflows/` experiments, or
self-hosted runner test history.

The Fold public history should start with one clear import commit on top of the
selected upstream baseline:

```text
upstream/master @ <selected upstream commit>
└─ chore: prepare RustDesk Fold public source snapshot
```

## Why This Is the First Public Path

Clean source snapshot is the recommended first release model because it is:

- easiest to build and audit;
- easiest for users to understand from the GitHub landing page;
- independent from old local development and CI experiment history;
- compatible with a manual trusted local APK release process;
- simpler than a submodule-plus-overlay build pipeline.

## Future TODO: Superproject plus Upstream Submodule

The superproject model is useful later, but not for the first public baseline.

Future experiment branch:

```text
experiment/upstream-submodule-overlay
```

Possible future shape:

```text
RustDesk-Fold/
  README.md
  RELEASE_FOLD_MANUAL.md
  patches/
  tools/
  upstream/rustdesk/        # Git submodule
```

The build script would:

1. update `upstream/rustdesk`;
2. copy it to a temporary build workspace;
3. apply Fold patches or overlay files;
4. run `flutter analyze`;
5. run the Android release build;
6. verify the generated APK.

Advantages:

- upstream history stays out of the Fold main repository;
- Fold docs and scripts stay clearly separate;
- the upstream revision is explicit through `.gitmodules`.

Tradeoffs:

- build setup is more complex;
- contributors must initialize submodules;
- patch application can fail after upstream changes;
- auditing must cover both the Fold overlay and the selected upstream submodule
  commit;
- release builds should happen from a generated, reviewed workspace, not from
  an unreviewed submodule working tree.

## Not a Normal Package Import

RustDesk is a full application source tree, not a small Android, Flutter, or
Rust library package. Fold changes touch Android app identity, manifest and
build files, Flutter mobile UI, language strings, release scripts, and the
Rust/Flutter bridge surface.

The practical options are therefore:

- carry a complete clean source snapshot; or
- use a submodule plus patch/overlay build workspace.

The first public release uses the clean source snapshot.
