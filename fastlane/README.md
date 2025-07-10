fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and deploy iOS app to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and deploy iOS app to App Store

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata and screenshots only

### ios update_profiles

```sh
[bundle exec] fastlane ios update_profiles
```

Update provisioning profiles

----


## Android

### android beta

```sh
[bundle exec] fastlane android beta
```

Build and deploy Android app to internal track

### android release

```sh
[bundle exec] fastlane android release
```

Build and deploy Android app to production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
