# Steps to deploy

# Prerequisites:

AWS Account (Free Tier), AWS Route 53 Domain, GitHub and Docker Hub Accounts.

# Setting up the development environment: (Ubuntu)

### Install git, wget, python, and unzip: 
```bash
sudo apt-get install git unzip wget python -y
```

### Install AWS CLI:

```bash
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip  
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws  
rm -rf awscli-bundle/ awscli-bundle.zip  
```

### Install Docker:

```bash
sudo curl -sSL https://get.docker.com/ | sh  
sudo usermod -aG docker ${USER}  
```
### Install Kubectl: (Latest)

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl  
sudo chmod +x kubectl  
sudo mv kubectl /usr/local/bin/kubectl  
```

### Install Kops:

```bash
wget https://github.com/kubernetes/kops/releases/download/1.7.0/kops-linux-amd64  
sudo chmod +x kops-linux-amd64  
sudo mv kops-linux-amd64 /usr/local/bin/kops  
```

### Clone Repo:

```bash
git clone https://github.com/cbuto/django-app-travis
cd django-app-travis
```

# Setting up AWS for Kops: (Used for setting up Kubernetes clusters)

### Create a Kops user

An existing user can be used but it needs to have the IAM permissions shown in the configuration below.


```bash
aws iam create-group --group-name kops

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops

aws iam create-user --user-name kops

aws iam add-user-to-group --user-name kops --group-name kops

aws iam create-access-key --user-name kops
```

Keep track of the SecretAccessKey and AccessKeyID values.

### Set Environment Variables For Kops

```bash
export AWS_ACCESS_KEY_ID="<AccessKeyID>"
export AWS_SECRET_ACCESS_KEY="<SecretAccessKey>"
```

### SSH Public Key

Make sure your public key file is placed in ```~/.ssh/id_rsa.pub```

# Deployment

### Configure New Kubernetes Cluster

```console
export DOMAIN_NAME="<Your Domain Name>"

export CLUSTER_ALIAS="usa"

export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}"

export CLUSTER_AWS_AZ="us-east-1a"

export CLUSTER_AWS_REGION="us-east-1"
```
Create the S3 bucket for Kops and then create the cluster. This configuration will deploy a master and two nodes (t2.micro instances). The instance type can be changed but t2.micro is used to stay within the AWS free tier limits. 

```console
aws s3api create-bucket --bucket ${CLUSTER_FULL_NAME}-state
export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"

kops create cluster \
--name=${CLUSTER_FULL_NAME} \
--zones=${CLUSTER_AWS_AZ} \
--master-size="t2.micro" \
--node-size="t2.micro" \
--node-count="2" \
--dns-zone=${DOMAIN_NAME} \
--ssh-public-key="~/.ssh/id_rsa.pub" \
--kubernetes-version="1.6.4" --yes
```

After a few minutes, check if the cluster has been created with:

```bash
kubectl get nodes
```

### Create Git Repository for Travis

Copy the repo to another directory: (If you want to use Travis CI)

```bash
cd ..
cp django-app-travis <another directory>
cd <another directory>
```

Configure Git and create the new repo

```bash
git config --global user.name "<username>"
git config --global user.email "<email>"
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
curl -u "<username>" https://api.github.com/user/repos \
     -d '{"name":"django-app-travis"}'
```

Upload contents to the new repo

```bash
git init
git add .
git commit -m "Create Django site repository"
git remote add origin \
    https://github.com/<username>/django-app-travis.git
git push -u origin master
```

### Deploy

Create postgres deployment and service

```bash
kubectl create -f ./kubernetes/database/
```

Create the django-app deployment and service

```bash
kubectl create -f ./kubernetes/app/
```

Getting the site url

```bash
kubectl get svc -o wide
```

### Configure Travis

[Travis CI](https://travis-ci.org/)

Login with your GitHub credentials

