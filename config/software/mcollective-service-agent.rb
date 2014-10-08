name "mcollective-service-agent"
source :git => "https://github.com/puppetlabs/mcollective-service-agent.git"
default_version "master"

dependency "mcollective"

build do
	block do
		%w(agent application data util validator).each do |dir|
			FileUtils.cp_r File.join(project_dir, dir), ::File.join(install_dir, "plugins", "mcollective")
		end
	end
end
