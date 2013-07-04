
name "mcollective"
maintainer "Avishai Ish-Shalom"
homepage "https://puppetlabs.com/mcollective/introduction/"

replaces        "mcollective"
install_path    "/opt/mcollective"
build_version   Omnibus::BuildVersion.new.semver
build_iteration 1

# creates required build directories
dependency "preparation"

# mcollective dependencies/components
dependency "mcollective"

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"
