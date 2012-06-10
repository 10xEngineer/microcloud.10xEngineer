# 10xEngineer AMI Builder

Prepares base 10xEngineer AMI

    ssh-add <PATH-TO-KEYPAIR>

    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...
    bundle exec ./ami_builder.sh ap-southeast-1 mykeypair
