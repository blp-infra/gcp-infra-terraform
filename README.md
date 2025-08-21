
# 🚀 GCP Terraform Infrastructure (via Jenkins Pipeline)

This repository contains **Terraform code** to provision infrastructure on **Google Cloud Platform (GCP)**.
The Terraform execution is automated and managed through a **Jenkins pipeline**, with support for multiple environments.

---

## 📂 Repository Structure

```
repo/
└── terraform_code/
    ├── env-dev/         # Terraform configs for Dev environment
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars
    ├── env-stage/       # (Optional) Stage environment configs
    ├── env-prod/        # (Optional) Prod environment configs
    └── modules/         # Shared reusable modules
Jenkinsfile              # Pipeline definition for Jenkins
```

---

## ⚙️ Prerequisites

### Jenkins Setup

* Jenkins instance with:

  * **Terraform** installed (`>=1.x`)
  * **Google Cloud SDK** installed
  * Required Jenkins plugins:

    * [Pipeline](https://plugins.jenkins.io/workflow-aggregator/)
    * [Credentials Binding](https://plugins.jenkins.io/credentials-binding/)

### Service Account

* A GCP **Service Account** with sufficient IAM permissions.
* JSON key stored in **Jenkins Credentials**.
* Pipeline will export this for Terraform authentication.

---

## 🚀 Pipeline Workflow

The Jenkins pipeline (`Jenkinsfile`) is designed with the following stages:

1. **Checkout** → Clone this repo
2. **Select Environment** → Choose environment folder (`env-dev`, `env-stage`, `env-prod`)
3. **Init** → Run `terraform init` in the selected folder
4. **Validate** → Run `terraform validate`
5. **Plan** → Run `terraform plan` and display changes
6. **Apply** → Deploy infra (manual approval optional)
7. **Destroy** (optional/manual) → Tear down infra for cleanup

---

## 🖥️ Running Locally (Optional)

If you want to test Terraform locally for `env-dev`:

```bash
cd repo/terraform_code/env-dev

export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
export GOOGLE_PROJECT="your-project-id"

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

---

## 🔒 Security Best Practices

* Do **not** commit service account keys or sensitive variables.
* Use `.gitignore` for:

  ```
  *.tfstate
  *.tfstate.backup
  terraform.tfvars
  .terraform/
  ```
* Store state remotely in **GCS backend** with locking.
* Apply **least privilege** IAM roles for service accounts.





