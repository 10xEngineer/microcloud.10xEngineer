# 10xEngineer AMI Builder

Prepares base 10xEngineer AMI.

To run it make sure key pair for selected region is available in SSH agent using

    ssh-add <PATH-TO-KEYPAIR>

Provider AWS credentials

    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...

and run the builder itself

    bundle exec ./ami_builder.sh ap-southeast-1 mykeypair

## Custom image

All customization are done by `definition/postinstall.sh`. 

## Security

AMIs are saved using the AWS Credentials provided. In general no private information should be stored as part of postinstall process, and therefore AMIs are not confidential. Being critical part of infrastructure they should be audited regularly (TBD).

## Improvements

* Clean-up resources in case of failure
