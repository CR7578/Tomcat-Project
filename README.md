# Tomcat Project — AWS Deployment Guide

This repository contains a Java web application (Maven) packaged for Apache Tomcat and the support files used when deploying the application on AWS. The repository also includes provisioning scripts for services used in the architecture (Tomcat, MySQL, RabbitMQ, Memcached) under the `aws-userdata/` folder.

This README documents the AWS components and the deployment steps you followed so they can be reproduced or automated.

**Repository highlights**
- `aws-userdata/`: provisioning scripts used as EC2 User Data (see `memcached.sh`, `mysql.sh`, `rabbitmq.sh`, `tomcat_ubuntu.sh`).
- `src/`: application source, configuration, and SQL scripts.
- `webapp/WEB-INF/`: Spring / Tomcat config files used by the app.

**Prerequisites**
- An AWS account with permissions to create IAM users, roles, EC2, ALB/ELB, Security Groups, Target Groups, Launch Templates and Auto Scaling Groups.
- (Optional) `aws` CLI configured locally for scripted operations.
- A key pair for SSH access to EC2 instances (if you need SSH access).

Architecture summary
- Public Application Load Balancer (ALB/ELB) fronting the Tomcat application.
- EC2 instances:
    - `app01` — Tomcat application server
    - `mc01` — Memcached
    - `rmq01` — RabbitMQ
    - `db01` — MySQL
- Security Groups split by layer: `ELB`, `APP`, `BACKEND`.
- IAM users/roles to control access and let EC2 instances interact with AWS services when required.

Step-by-step deployment (reproduces the steps you followed)

1) IAM users
- Create an IAM user for administration (e.g., `admin-user`) and attach `AdministratorAccess` only for initial setup. Use MFA and temporary credentials where possible.
- Create an IAM user for S3 operations (e.g., `s3-user`) with a least-privilege S3 policy (or `AmazonS3FullAccess` only if appropriate).

2) IAM role for EC2 (Tomcat)
- Create an IAM role (for example `TomcatEC2Role`) with the policies the application needs (S3 read, CloudWatch logs, etc.).
- Trust relationship: allow EC2 service to assume the role.
- When launching EC2 instances or creating a Launch Template, attach this role so instances inherit permissions.

3) Security Groups (SG)
- `ELB` SG: Allows inbound HTTP/HTTPS from the Internet (0.0.0.0/0) to the ALB listener ports (80/443). Outbound to `APP` SG.
- `APP` SG: Assigned to Tomcat instances. Allow inbound from `ELB` SG on the app port (80 or 8080) and outbound to `BACKEND` SG for DB/messaging/cache traffic.
- `BACKEND` SG: Assigned to DB, Memcached and RabbitMQ. Allow only the minimum ports from `APP` SG (e.g., MySQL 3306 from `APP`, RabbitMQ 5672/15672 from `APP`, Memcached 11211 from `APP`).

4) EC2 instances and userdata
- Instances you created:
    - `app01` (Tomcat) — use `tomcat_ubuntu.sh` as EC2 User Data to install and configure Tomcat and deploy the WAR.
    - `mc01` (Memcached) — use `memcached.sh` as User Data.
    - `rmq01` (RabbitMQ) — use `rabbitmq.sh` as User Data.
    - `db01` (MySQL) — use `mysql.sh` as User Data (or use an RDS instance for production workloads).
- How to use User Data: when launching an instance (or creating a Launch Template), paste the shell script contents from `aws-userdata/<script>.sh` into the User Data field. These scripts are written for Ubuntu-based AMIs.

5) Target Group and Load Balancer
- Create a Target Group for the Tomcat app (protocol HTTP, port 80 or 8080 as appropriate). Use a health check endpoint such as `/` or `/health` that returns HTTP 200.
- Create an Application Load Balancer (ALB) with a listener on port 80/443 and forward traffic to the Tomcat Target Group. Attach the `ELB` SG to the ALB.

6) Launch Templates and Auto Scaling (optional)
- Create a Launch Template that references the base AMI, instance type, key pair, User Data (`tomcat_ubuntu.sh`), the `TomcatEC2Role`, and the `APP` SG.
- Create an Auto Scaling Group (ASG) using the Launch Template and attach it to the Tomcat Target Group. Configure desired/min/max sizes and scaling policies as needed.

7) Registering instances
- If launching EC2 instances manually, ensure `app01` is registered in the Target Group. If using an ASG, instances will be registered automatically.

8) DNS
- Point your DNS (Route53) record to the ALB DNS name (Alias target) for production traffic.

Useful repository files
- `aws-userdata/memcached.sh` — provisioning script for memcached.
- `aws-userdata/mysql.sh` — bootstraps MySQL server and optionally loads `src/main/resources/accountsdb.sql`.
- `aws-userdata/rabbitmq.sh` — installs and configures RabbitMQ.
- `aws-userdata/tomcat_ubuntu.sh` — installs Java + Tomcat and deploys the webapp.

Deployment checklist (concise)
- Create IAM users and roles (admin, s3-user, TomcatEC2Role).
- Create Security Groups: `ELB`, `APP`, `BACKEND`.
- Create Target Group and ALB.
- Create Launch Template with appropriate User Data and attach `TomcatEC2Role`.
- Launch EC2 instances or create ASG; verify health checks and ALB routing.
- Configure Route53 DNS if required.

Troubleshooting
- ALB health checks failing: confirm the app listens on the port defined by the target group and the health endpoint responds 200.
- Instances not reachable: check that correct SGs are attached and that the `APP` SG allows inbound from the `ELB` SG.
- Scripts failing on boot: view `/var/log/cloud-init-output.log` and `/var/log/user-data.log` on the instance for User Data errors.

Security recommendations
- Don't use long-lived root or admin credentials; use IAM roles for EC2 and temporary credentials for CLI automation.
- Restrict Security Group access using SG references (allow only ALB SG to talk to APP SG; allow only APP SG to talk to BACKEND SG).
- Harden instances (disable password SSH, use keys, enable automatic security updates or a configuration management tool).

Automation tips
- The steps above can be automated using CloudFormation, Terraform, or CDK: define the IAM users/roles, SGs, Target Groups, ALB, Launch Templates and ASGs in code so environments are reproducible.

