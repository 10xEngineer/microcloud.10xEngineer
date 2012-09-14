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

cookbook_file "/home/lab/wrap-ssh4git.sh" do
	owner "lab"
	source "wrap-ssh4git.sh"
	mode 0755
end

if node["lab"]["attributes"]["origin_url"]
	git "/home/lab/deploy" do
		repository node["lab"]["attributes"]["origin_url"]
		reference "master"
		action :sync

		user "lab"
		group "lab"

		ssh_wrapper "/home/lab/wrap-ssh4git.sh"
	end
end