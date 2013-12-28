name "mcollective-facter-facts"
source :git => "https://github.com/puppetlabs/mcollective-facter-facts.git"
version "master"

dependency "mcollective"

build do
	gem "install facter --no-ri --no-rdoc"
	block do
		FileUtils.cp_r File.join(project_dir, "facts"), ::File.join(install_dir, "plugins", "mcollective")
	end
end