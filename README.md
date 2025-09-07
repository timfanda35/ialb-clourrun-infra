# A lab note for GCP Cloud Run with Internal Load Balancer

ILB + Serverless NEG + Cloud Run, route traffic by URL Mask.

```
Grafana -> my-prometheus.com/<service> -> Cloud Run (Prometheus Frontend UI) -> Google Managed Prometheus
```

Please note: this is based on a exist project, not a fresh project.

# Setup Project

## Step 1

Edit the `*.tf` files and `terrafom.ftvars` to match your project.

## Step 2

```bash
PROJECT_ID="your_project_id"
gcloud config set project $PROJECT_ID
```

## Step 3

```bash
./prepare.sh $PROJECT_ID
```

## Step 4

```bash
terraform init
```

## Step 5

Create file: `terraform.tfvars` with content:

```hcl
project_id = "your_project_id"
region     = "your_region"
my-ip      = "your_ip_address"
hostname   = "my-prometheus.com"
```

## Step 6

```bash
terraform apply
```
