# Amazon EKS Project – Kubernetes on AWS  
This project demonstrates how to deploy a **containerized application** on **Amazon Elastic Kubernetes Service (EKS)** using **Terraform** and **Kubernetes manifests**.  
It covers infrastructure provisioning, networking, load balancing, and secure IAM integration to simulate a production-ready environment. 

## Architecture  
<img width="2130" height="1040" alt="EKS DIAGRAM" src="https://github.com/user-attachments/assets/9932214e-61f8-48e4-a4ec-d31c1eab3b47" />

### Flow 
Users ──> Application Load Balancer (Ingress) ──> EKS Cluster
├── Frontend (UI)
├── Backend (API)
└── Database (PostgreSQL / RDS)

## Prerequisites  

Before you begin, ensure you have the following installed:  

- [Terraform](https://developer.hashicorp.com/terraform/downloads)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [eksctl](https://eksctl.io/)  
- [AWS CLI](https://docs.aws.amazon.com/cli/)  
- [Helm](https://helm.sh/docs/intro/install/)  

Also, configure your AWS CLI:  aws configure

## Deployment Steps

### 1.Provision Infrastructure with Terraform  

```bash
terraform init
terraform plan
terraform apply
```

> This will create:
VPC with public & private subnets
Internet Gateway & NAT Gateway
Security Groups & Route Tables
EKS Cluster & Fargate profiles

### 2.Configure kubectl to Access EKS  

```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```
- Verify the cluster connection:
  
```bash
  kubectl get nodes
```

### 3.install AWS Load Balancer Controller  
- Step 1: Associate IAM OIDC Provider:  
  
```bash
  eksctl utils associate-iam-oidc-provider \
  --region <region> \
  --cluster <cluster-name> \
  --approve
```
- Step 2: Download and Create IAM Policy
  
```bash
  curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json  
  aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```
- Step 3: Create IAM Service Account for the Controller
  
```bash
  eksctl create iamserviceaccount \
  --cluster=<cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```
- Step 4: Install Controller using Helm  
  
```bash
  helm repo add eks https://aws.github.io/eks-charts  
  helm repo update  


helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region> \
  --set vpcId=<vpc-id>  
```
- Step 5: Verify Deployment  
  
```bash
  kubectl get deployment -n kube-system aws-load-balancer-controller
```

### 4.Deploy the Application
- Apply Kubernetes manifests (frontend, backend, database, services, ingress):  
  
```bash
  kubectl apply -f kuberenets/
```
- Check deployed resources  
  ```bash
  kubectl get pods -n <namespace>  
  kubectl get svc -n <namespace>
  ```

### 5.Verify Load Balancer Creation
- To confirm the AWS Load Balancer Controller is working and the application is exposed:  
  ```bash
  kubectl get ingress -n <namespace>
  ```

 > The output will include the ALB DNS name. Copy and paste the DNS name into your browser to access the application.


  
