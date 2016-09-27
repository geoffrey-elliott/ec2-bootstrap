# ec2-bootstrap

## To Build the Bootstrap API

1. Launch an `Ubuntu 16.04` instance
2. Copy `id_rsa` and `id_rsa.pub` to `/home/ubuntu/.ssh`
3. Append `id_rsa.pub` to `/home/ubuntu/.ssh/authorized_keys`
4. Copy `bootstrap.sh` to `/home/ubuntu`
5. Run `echo "@reboot sleep 30 && ssh -oStrictHostKeyChecking=no ubuntu@localhost ${HOME}/bootstrap.sh 0 >> ${HOME}/bootstrap.log 2>&1" | crontab -`
6. Create AMI

## To Launch an Instance

1. Create Instance
2. Choose the AMI
3. Add user-data (e.g. GIT_REPO=)
4. Launch Instance -- Choose "No Key"
