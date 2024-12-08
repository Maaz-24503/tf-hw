#!/bin/bash

# Update system packages and install required tools
yum update -y
yum install -y git docker nginx

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Clone the React application repository
git clone https://github.com/Maaz-24503/reactapp.git
cd reactapp

# Create Dockerfile for single-stage build
cat > Dockerfile.singlestage <<EOF
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npx", "serve", "-s", "build"]
EOF

# Build single-stage Docker image
docker build -f Dockerfile.singlestage -t reactapp-singlestage .

# Create Dockerfile for multistage build
cat > Dockerfile <<EOF
# Use the official Node.js image as the base image
FROM node:18 AS build

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Build the React app for production
RUN npm run build

# Use a lightweight web server to serve the app
FROM nginx:alpine

# Copy the build output to the Nginx html folder
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build multistage Docker image
docker build -t reactapp-multistage .

# Run multistage container (expose port 80)
docker run -d -p 8080:80 --name reactapp-multistage-container reactapp-multistage

# Clean up dangling images to avoid clutter
docker image prune -f

# Configure Nginx as a reverse proxy
cat > /etc/nginx/conf.d/reactapp.conf <<EOF
server {
    listen 80;
    server_name maaz-hw-amazon-linux.bilal0612.online;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Test and restart Nginx
nginx -t
systemctl restart nginx

# Display Docker images for comparison
echo "Docker images:"
docker images

# Display running containers
echo "Running containers:"
docker ps
