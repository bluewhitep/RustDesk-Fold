# Upstream RustDesk

RustDesk Fold is based on official RustDesk source code:

- upstream project: <https://github.com/rustdesk/rustdesk>
- upstream baseline for this clean public snapshot:
  `a2b79462ab63db2447a4f5c36e6257c74ae47230`
- Fold patch source used for this snapshot:
  `github/foldable-split-keyboard-main`
- Fold patch source commit:
  `661491b22287a5c2138554902ae9978f9c3fbcfb`

RustDesk Fold is an independent Android foldable-focused build. It is not an
official RustDesk release.

## Public Repository Model

The first public baseline uses a clean source snapshot:

1. official RustDesk source is imported at a selected upstream baseline;
2. Fold-specific Android, Flutter, release, and documentation changes are
   applied;
3. public Fold history starts as one import commit on top of the selected
   upstream baseline;
4. old local development history, GitHub Actions experiments, and self-hosted
   runner workflow history are not published.

## Future Experiment

A future experiment branch may validate a superproject model:

```text
experiment/upstream-submodule-overlay
```

That branch would keep official RustDesk as an `upstream/rustdesk` submodule and
apply Fold patches or overlays into a temporary build workspace before building.
This model separates upstream history more strongly, but it is more complex to
build, update, and audit. It is not the first public release path.

## Update Notes

When updating to a newer upstream RustDesk baseline:

1. review upstream changes;
2. apply the Fold patch set;
3. review Android permissions, package identity, signing configuration,
   dependency changes, and sensitive data;
4. run `flutter analyze`;
5. build the release APK in a trusted local environment;
6. verify the APK before tagging or publishing.
