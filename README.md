[![Generic badge](https://img.shields.io/badge/Version-1.0-<COLOR>.svg)](https://shields.io/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)
![Maintainer](https://img.shields.io/badge/maintainer-raphael.chir@gmail.com-blue)
# CNPG Labs setup

## Prerequisites
- AWS Account + AWS CLI
- Terraform 
                
## Terraform backend

All terraform state files are stored and shared in a dedicated S3 bucket. Create if needed your own bucket.

Refer your bucket in your terraform backend configuration (main.tf)
**Specify a key for your project !**

```bash
terraform {
  backend "s3" {
    region  = "<Your bucket region>"
    key     = "<The name of the key that will be created to access your tf state>"
    bucket  = "<Your bucket name>"
  }
}
```

## SSH Keys

### Generate

We need to generate key pair in order to ssh into instances. Create a .ssh folder in the repo.
[SSH Academy](https://www.ssh.com/academy/ssh/keygen#creating-an-ssh-key-pair-for-user-authentication)

Open a terminal and paste this default command

```bash
ssh-keygen -q -t rsa -b 4096 -f .ssh/id_rsa -N ''
```

Change if needed ssh_keys_path variable in terraform.tvars  
Run this command, if necessary, to ensure your key is not publicly viewable.

```bash
chmod 400 id_rsa
```

### Choosing an Algorithm and Key Size

SSH supports several public key algorithms for authentication keys. These include:

**rsa** - an old algorithm based on the difficulty of factoring large numbers. A key size of at least 2048 bits is recommended for RSA; 4096 bits is better. RSA is getting old and significant advances are being made in factoring. Choosing a different algorithm may be advisable. It is quite possible the RSA algorithm will become practically breakable in the foreseeable future. All SSH clients support this algorithm.

**dsa** - an old US government Digital Signature Algorithm. It is based on the difficulty of computing discrete logarithms. A key size of 1024 would normally be used with it. DSA in its original form is no longer recommended.

**ecdsa** - a new Digital Signature Algorithm standarized by the US government, using elliptic curves. This is probably a good algorithm for current applications. Only three key sizes are supported: 256, 384, and 521 (sic!) bits. We would recommend always using it with 521 bits, since the keys are still small and probably more secure than the smaller keys (even though they should be safe as well). Most SSH clients now support this algorithm.

**ed25519** - this is a new algorithm added in OpenSSH. Support for it in clients is not yet universal. Thus its use in general purpose applications may not yet be advisable.

The algorithm is selected using the -t option and key size using the -b option. The following commands illustrate:

```bash
ssh-keygen -t rsa -b 4096
ssh-keygen -t dsa
ssh-keygen -t ecdsa -b 521
ssh-keygen -t ed25519
```

## Configuration

Renam terraform.tfvars.templates to terraform.tfvars and adapt the value : 

```properties
region_target = "eu-west-1" 

resource_tags = {
  project     = "cnpg"
  environment = "labs"
  owner       = "raphael.chir@enterprisedb.com"
}

key_pair_name = "cnpg-labs-rch-kp"
ssh_public_key_path = ".ssh/id_rsa.pub"
ssh_private_key_path = ".ssh/id_rsa"

vpc_cidr_block = "10.0.0.0/24"  
public_subnet_cidr_block = "10.0.0.0/24"

ingress-rules = [
  {
      port    = 80
      proto   = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  },
  {
    port    = 22
    proto   = "TCP"
    cidr_blocks = ["<YOUR IP>/32"] 
  },
  {
    port    = 9001
    proto   = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    port    = 9090
    proto   = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    port    = 3000
    proto   = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

number_of_instances = 1 # The number of VM to create
instance_type = "t3.medium"
volume_type = "gp3"
volume_size = "24"
ami_id = "ami-03fd334507439f4d1" # Depend of the region
```

## How to choose your OS AMI

Warn, ami id depend of the region ! From AWS console you can just copy from aws console the **ami-id** needed.  
e.g : '_Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20_' is **ami-01ded35841bc93d7f**  

## Execute

First time
```
terraform init
```
After modification
```
terraform validate
terraform plan
```
To deploy
```
terraform apply
```
To destroy everything
```
terraform destroy
```
To access urls, ssh command
```
terraform output
```

## Notes

The labs attendees access to their environment with a web browser.
- On port 80 : Terminal built with ttyd and tmu
- On port 9001 : Minio
- On port 9090 : Prometheus
- On port 3000 : Grafana

Follow the instructions on [this workshop](https://github.com/raphael-chir/cnpg-ha)



