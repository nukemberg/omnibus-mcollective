name "mcollective"
maintainer "Avishai Ish-Shalom"
homepage "https://puppetlabs.com/mcollective/introduction/"

replaces        "mcollective"
install_path    "/opt/mcollective"
build_version   ENV["MCOLLECTIVE_GIT_REV"]
build_iteration 1

# creates required build directories
dependency "preparation"

# mcollective dependencies/components
dependency "mcollective"
dependency "mcollective-ohai-facts"
dependency "mcollective-facter-facts"
dependency "mcollective-service-agent"
dependency "mcollective-filemgr-agent"

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"
