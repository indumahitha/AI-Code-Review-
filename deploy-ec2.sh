#!/bin/bash

# AWS EC2 Deployment Script for Node.js Backend
# This script assumes you have:
# 1. Created an EC2 instance with Ubuntu
# 2. Configured security groups to allow SSH (22) and HTTP (80), HTTPS (443), and your app port (5000)
# 3. Installed Docker and Docker Compose on the EC2 instance
# 4. Set up SSH key pair for access

# Variables - Update these with your actual values
EC2_HOST="your-ec2-public-ip"  # Replace with your EC2 public IP
EC2_USER="ubuntu"             # Default for Ubuntu instances
SSH_KEY_PATH="~/.ssh/your-key.pem"  # Path to your SSH private key
GITHUB_REPO="your-username/your-repo"  # Your GitHub repository

echo "🚀 Starting deployment to AWS EC2..."

# Step 1: Copy docker-compose.yml to EC2
echo "📋 Copying docker-compose.yml to EC2..."
scp -i $SSH_KEY_PATH docker-compose.yml $EC2_USER@$EC2_HOST:~/docker-compose.yml

# Step 2: SSH into EC2 and deploy
echo "🔧 Deploying application on EC2..."
ssh -i $SSH_KEY_PATH $EC2_USER@$EC2_HOST << EOF
    # Update system
    sudo apt update && sudo apt upgrade -y

    # Install Docker if not installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker \$USER
    fi

    # Install Docker Compose if not installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    # Pull latest image from GHCR
    echo "📦 Pulling latest Docker image..."
    echo "your-github-token" | docker login ghcr.io -u your-github-username --password-stdin
    docker pull ghcr.io/$GITHUB_REPO/backend:latest

    # Stop existing containers
    docker-compose down || true

    # Start the application
    docker-compose up -d

    # Check if application is running
    sleep 10
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "✅ Deployment successful! Application is running on port 5000"
    else
        echo "❌ Deployment failed. Check logs:"
        docker-compose logs
    fi
EOF

echo "🎉 Deployment script completed!"
echo "🌐 Your application should be accessible at: http://$EC2_HOST:5000"
