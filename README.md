# DevOps end-to-end pipeline: Git -> Jenkins -> Maven -> Nexus -> Docker -> EKS -> Prometheus/Grafana

## Execution order

### 1. CloudFormation - Terraform state backend
```
cd cloudformation
aws cloudformation deploy --template-file terraform-backend.yaml \
  --stack-name terraform-backend --region us-east-1
```
Creates the S3 bucket + DynamoDB table Terraform needs. Note the bucket name
in the stack output and put it into `terraform/backend.tf`.

### 2. Terraform - infrastructure
```
cd terraform
terraform init
terraform apply -var="key_pair_name=<your-ec2-keypair>"
```
Creates: VPC, EKS cluster + node group, and one EC2 instance for the CI/CD tools.
Note the `cicd_server_public_ip` and `eks_cluster_name` outputs.

### 3. Ansible - configure the CI/CD server
Edit `ansible/inventory.ini` with the EC2 IP from step 2, then:
```
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```
Installs Jenkins, Docker, Maven, and starts Nexus + Grafana as containers.

### 4. Nexus one-time setup (manual, via UI)
- Visit `http://<cicd-ip>:8081`, log in, create a Docker (hosted) repo on port 8082,
  and enable Docker Bearer Token realm under Security > Realms.
- Get the admin password: `docker exec nexus cat /nexus-data/admin.password`

### 5. Jenkins one-time setup (manual, via UI)
- Visit `http://<cicd-ip>:8080`, unlock with `/var/lib/jenkins/secrets/initialAdminPassword`.
- Install plugins: Git, Pipeline, Docker Pipeline, AWS Credentials.
- Add Nexus credentials and AWS credentials in Jenkins Credential Manager.
- Create a new Pipeline job pointing at this repo's `Jenkinsfile`.
- Add a GitHub webhook so pushes trigger the job automatically.

### 6. Push code -> pipeline runs automatically
Git push triggers Jenkins, which:
Maven builds & tests -> deploys jar to Nexus -> builds Docker image ->
pushes image to Nexus Docker registry -> deploys to EKS via kubectl.

Replace placeholders in `app/pom.xml`, `Dockerfile`, and `Jenkinsfile`
(`<CICD_SERVER_IP>`, `<your-org>/<your-repo>`) with your real values first.

### 7. Monitoring
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  -f monitoring/prometheus-values.yaml -n monitoring --create-namespace
```
Grafana dashboard is exposed via LoadBalancer on port 80; default login admin/changeme
(set in prometheus-values.yaml — change before real use).

## File map
| Tool | File(s) |
|---|---|
| CloudFormation | `cloudformation/terraform-backend.yaml` |
| Terraform | `terraform/*.tf` |
| Ansible | `ansible/inventory.ini`, `ansible/playbook.yml` |
| Maven | `app/pom.xml` |
| Docker | `Dockerfile` |
| Jenkins (CI/CD glue) | `Jenkinsfile` |
| Kubernetes / EKS | `k8s/deployment.yaml`, `k8s/service.yaml` |
| Prometheus + Grafana | `monitoring/prometheus-values.yaml` |


Webhook test 2

Jenkins SCM test

tet
