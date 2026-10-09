# Releasing

1. Set the new version in `Resources/Info.plist` (`CFBundleShortVersionString`) and add a section for it at the top of `CHANGELOG.md`.
2. If the app window changed, run `make screenshots` and update the README.
3. Commit, then tag and push:

   ```bash
   git tag v2.1.0
   git push origin main v2.1.0
   ```

The **Release** workflow builds the app and publishes a GitHub release with `PixelCat-<version>.zip` and `PixelCat-<version>.dmg`. The tag must match the version in `Info.plist`. The release notes are that version's section of `CHANGELOG.md` followed by `docs/release-footer.md`.

Installed copies find the new release through the in-app updater, which downloads the zip. Keep the zip asset's name ending in `.zip`.

To build the same files on your own Mac, run `make release`. They land in `build/`.

## Signing

The app is ad-hoc signed, not signed with an Apple Developer ID or notarized. It runs, but macOS makes each user approve the first launch in System Settings. Updates installed by the app itself do not ask again.
