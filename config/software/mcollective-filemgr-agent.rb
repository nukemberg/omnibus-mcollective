name "mcollective-filemgr-agent"
source :git => "https://github.com/puppetlabs/mcollective-filemgr-agent.git"
version "master"

dependency "mcollective"

build do
	block do
		%w(agent application).each do |dir|
			FileUtils.cp_r File.join(project_dir, dir), ::File.join(install_dir, "plugins", "mcollective")
		end
	end
end