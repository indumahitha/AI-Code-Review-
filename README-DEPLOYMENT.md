# DevOps Deployment Guide

This guide covers transforming your Node.js backend into a DevOps-ready project with Docker, CI/CD, and AWS deployment.

## Prerequisites

- GitHub repository
- AWS account with EC2 access
- SSH key pair for EC2 access
- Docker and Docker Compose installed locally

## Local Development

### Using Docker Compose

1. **Build and run locally:**
   ```bash
   docker-compose up --build
   ```

2. **Test the application:**
   - GET `http://localhost:5000` - Returns "Hello World"
   - POST `http://localhost:5000/ai/get-review` - AI code review endpoint

## CI/CD Pipeline

### GitHub Actions Workflow

The `.github/workflows/deploy.yml` file contains:
- Automated building on push/PR to main branch
- Docker image building and pushing to GHCR
- Cache optimization for faster builds

### Setting up GHCR

1. Go to your GitHub repository Settings > Secrets and variables > Actions
2. The workflow uses `GITHUB_TOKEN` which is automatically available
3. Images will be available at: `ghcr.io/your-username/your-repo/backend:latest`

## AWS EC2 Deployment

### Option 1: Manual Deployment

1. **Create EC2 instance:**
   - AMI: Ubuntu 22.04 LTS
   - Instance type: t2.micro (free tier)
   - Security group: Allow SSH (22), HTTP (80), HTTPS (443), Custom TCP (5000)

2. **Configure the deployment script:**
   Edit `deploy-ec2.sh` with your values:
   ```bash
   EC2_HOST="your-ec2-public-ip"
   SSH_KEY_PATH="~/.ssh/your-key.pem"
   GITHUB_REPO="your-username/your-repo"
   ```

3. **Run deployment:**
   ```bash
   chmod +x deploy-ec2.sh
   ./deploy-ec2.sh
   ```

### Option 2: Terraform Deployment

1. **Install Terraform:**
   ```bash
   # On Windows with Chocolatey
   choco install terraform

   # Or download from https://www.terraform.io/downloads
   ```

2. **Configure AWS credentials:**
   ```bash
   aws configure
   ```

3. **Update variables:**
   Edit `terraform/variables.tf` and `terraform/main.tf` with your values

4. **Deploy with Terraform:**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

5. **Get instance IP:**
   ```bash
   terraform output instance_public_ip
   ```

## Environment Variables

Create a `.env` file in the backend directory with:
```
GOOGLE_API_KEY=your-google-ai-api-key
NODE_ENV=production
```

## Monitoring and Maintenance

### Check application status:
```bash
# On EC2 instance
docker-compose ps
docker-compose logs
```

### Update deployment:
```bash
# Pull latest image
docker pull ghcr.io/your-repo/backend:latest

# Restart services
docker-compose down
docker-compose up -d
```

## Security Considerations

- Restrict SSH access to your IP only
- Use HTTPS in production (consider AWS Certificate Manager + Load Balancer)
- Store secrets in GitHub Secrets or AWS Secrets Manager
- Regularly update Docker images and dependencies

## Troubleshooting

### Common Issues:

1. **Port 5000 not accessible:**
   - Check security group rules
   - Verify Docker container is running: `docker-compose ps`

2. **GHCR push fails:**
   - Ensure GITHUB_TOKEN has package permissions
   - Check repository settings for package creation

3. **Terraform errors:**
   - Verify AWS credentials
   - Check VPC/subnet configurations

### Logs:
```bash
# Application logs
docker-compose logs backend

# Docker system logs
docker system events
```

## Next Steps

- Add health check endpoints
- Implement blue-green deployments
- Set up monitoring with CloudWatch
- Add database persistence
- Configure load balancer for high availability
