# 10xlabs-vaglab::default

group "lab" do
	gid 1666
end

user "lab" do
	comment "10xLab User"
	uid 1666
	gid "lab"

	home "/home/lab"
	shell "/bin/bash"

	supports :manage_home => true
end

if node["lab"]["attributes"]["remote_url"]
	git "/home/lab/deploy" do
		repository node["lab"]["attributes"]["origin_url"]
		reference "master"
		action :sync

		user "lab"
		group "lab"
	end
end