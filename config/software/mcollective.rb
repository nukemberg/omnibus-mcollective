# This is an example software definition for a Ruby project.
#
# Lots of software definitions for popular open source software
# already exist in `opscode-omnibus`:
#
#  https://github.com/opscode/omnibus-software/tree/master/config/software
#
name "mcollective"
version ENV["MCOLLECTIVE_GIT_REV"] || "master"

dependency "ruby"
dependency "rubygems"
dependency "bundler"

source :git => "https://github.com/puppetlabs/marionette-collective.git"

relative_path "mcollective"

build do
  #####################################################################
  #
  # nasty nasty nasty hack for setting artifact version
  #
  #####################################################################
  #
  # since omnibus-ruby is not architected to intentionally let the
  # software definitions define the #build_version and
  # #build_iteration of the package artifact, we're going to implement
  # a temporary hack here that lets us do so. this type of use case
  # will become a feature of omnibus-ruby in the future, but in order
  # to get things shipped, we'll hack it up here.
  #
  # <3 Stephen (pasted from omnibus-chef)
  #
  #####################################################################
  block do
    project = self.project
    if project.name == "chef"
      git_cmd = "git describe --tags"
      src_dir = self.project_dir
      shell = Mixlib::ShellOut.new(git_cmd,
                                   :cwd => src_dir)
      shell.run_command
      shell.error!
      build_version = shell.stdout.chomp

      project.build_version   build_version
      project.build_iteration ENV["MCOLLECTIVE_PACKAGE_ITERATION"].to_i || 1
    end
  end

  rake "gem"
  gem ["install", "build/*.gem", "-n #{install_dir}/bin", "--no-rdoc", "--no-ri"].join(" ")
end
