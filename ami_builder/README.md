# 10xEngineer AMI Builder

Prepares base 10xEngineer AMI. Currently images are

* 64bit 
* EBS based
* Using official Ubuntu 12.04 LTS images

As part of production setup we should extend support and create instance-store images.

## Instructions

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

## Windows Images

For windows images you need to setup base Windows AMI for WinRM. Script `definition/postinstall.ps1` contains all the logic for minimum bootstrap (without chef). [To run it](http://technet.microsoft.com/en-us/library/ee176949.aspx), you need to enabled PowerShell on the target instance

    Set-ExecutionPolicy RemoteSigned

Copy paste the script to a file and run it (as powershell script).

To create AMI use EC2Config Service and

* uncheck "Enable SetPassword feature after sysprep" (to keep default password)
* "Run Sysprep and Shutdown now" (Bundle tab).

Instance will stop and is ready to create AMI from it.

## Improvements

* Clean-up resources in case of failure
* Repeat Windows AMI provisioning to diagnose WinRM *Access denied* problems (so far getting them randomly)
