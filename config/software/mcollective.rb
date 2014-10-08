# This is an example software definition for a Ruby project.
#
# Lots of software definitions for popular open source software
# already exist in `opscode-omnibus`:
#
#  https://github.com/opscode/omnibus-software/tree/master/config/software
#
name "mcollective"
default_version ENV["MCOLLECTIVE_GIT_REV"] || "master"

dependency "ruby"
dependency "rubygems"
dependency "bundler"

source :git => "https://github.com/puppetlabs/marionette-collective.git"

relative_path "mcollective"

MCOLLECTIVE_EXTRA_BINS = %w( ext/mc-irb ext/mc-rpc-restserver.rb)
GEM_DEPENDENCIES = %w(systemu json stomp i18n)

def copy_bin(bin_file)
  target_filename = ::File.join(install_dir, "bin", ::File.basename(bin_file))
  # instead of using sed to replace the shabang, we use ruby ;)
  File.open(bin_file, "r") do |f|
    File.open(target_filename, 'w') do |target_file|
      target_file.puts "#!#{install_dir}/embedded/bin/ruby"
      target_file.write f.lines.to_a[1..-1].join("\n")
    end
  end
  #FileUtils.chown "root", "root", target_filename
  FileUtils.chmod 0755, target_filename
end

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

      warn "Setting build version to #{build_version}"

      project.build_version   build_version
      project.build_iteration ENV["MCOLLECTIVE_PACKAGE_ITERATION"].to_i || 1
    end
  end

  gem (["install"] + GEM_DEPENDENCIES + ["-n #{install_dir}/bin", "--no-rdoc", "--no-ri"]).join(" ")
  gem "install puppet --no-ri --no-rdoc"

  ["docs",
   "share/man",
   "share/doc",
   "share/gtk-doc",
   "ssl/man",
   "man",
   "info"].each do |dir|
    command "rm -rf #{install_dir}/embedded/#{dir}"
  end

  block do # copy mcollective files
    # Replace the version stub
    if version =~ /\d\.\d\.\d/
      mcollective_rb = File.join(project_dir, "lib", "mcollective.rb")
      File.write(mcollective_rb, 
        File.read(mcollective_rb).gsub("@DEVELOPMENT_VERSION@", version))
    end

    MCOLLECTIVE_EXTRA_BINS.each do |file|
      copy_bin(::File.join(project_dir, file))
    end
    Dir.glob(::File.join(project_dir, "bin", "*")).each {|f| copy_bin(f)}
    ruby_lib_dir = ::File.join(install_dir, "embedded", "lib", "ruby", "site_ruby", "1.9.1")
    FileUtils.cp_r Dir.glob(::File.join(project_dir, "lib", "*")), ruby_lib_dir
    FileUtils.cp_r ::File.join(project_dir, "plugins"), install_dir
    FileUtils.cp_r ::File.join(Omnibus.project_root, "files", "etc"), install_dir
    FileUtils.cp_r ::File.join(Omnibus.project_root, "files", "mcollective.init"), install_dir 

    # chown all files
    #FileUtils.chown "root", "root", Dir.glob(File.join(install_dir, "**")) 
  end
end
