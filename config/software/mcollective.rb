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

MCOLLECTIVE_EXTRA_BINS = %w( ext/mc-irb bin/mcollectived bin/mc-call-agent ext/mc-rpc-restserver.rb)

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
    if project.name == "mcollective"
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
  command "rm -rf #{install_dir}/embedded/share/man"
  block do # copy mcollective files
    MCOLLECTIVE_EXTRA_BINS.each do |file|
      FileUtils.cp ::File.join(project_dir, file), ::File.join(install_dir, "bin/")
    end
    FileUtils.cp_r ::File.join(project_dir, "plugins"), install_dir
    FileUtils.cp_r ::File.join(Omnibus.project_root, "files", "etc"), install_dir
    FileUtils.cp_r ::File.join(Omnibus.project_root, "files", "mcollective.init"), install_dir
  end
end
