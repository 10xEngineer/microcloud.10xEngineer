# Internal setup

Dependencies
* Microcloud node
* Providers
* EC2 AMIs
* Hostnode binary distribution (for ubuntu/lxc)

## EC2 Setup

Existing AMIs:
* _eu-west-1_: 
* _ap-southeast-1_:
* _us_east-1_: NA

LXC/Ubuntu Hostnode toolchain distribution is done via S3 (origin is bucket tenxlabs-dev)

---

To setup AWS account/individual region you need to

* create security zone `tenxlab_node` - allow access to ports 22, 80, 443, 8080, 8443
* `export AWS_ACCESS_KEY_ID=xxx`
* `export AWS_SECRET_ACCESS_KEY=...`
* run `cd ami_builder && bundle install && bundle exec ./ami_builder.rb region_name key_to_use`
* wait for instance to terminate / AMI to get become available
* remove instance and it's backing EBS

