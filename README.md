# terraform
PreRequsite- Create an AWS account with access key and secret key

Setup
Run aws configure to update the secret key and access key.
Region used us-west-2
Generate public and private key using ssh-keygen command and use it in terraforms.tfvars.

Create terraforms.tfvars file and enter all the variable details
Example
vpc_cidr="10.0.0.0/16"
env_prefix="dev"
subnet_cidr="10.0.0.0/28"
availability_zone="us-west-2a"
route_cidr="0.0.0.0/0"
ssh="C:\\Users\\USERNAME\\.ssh\\id_rsa.pub"
instance_type="t2.micro"
