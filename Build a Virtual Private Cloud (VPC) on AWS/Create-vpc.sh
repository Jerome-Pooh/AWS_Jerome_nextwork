#!/bin/bash

# Set variables
VPC_NAME="NextWork VPC"
VPC_CIDR="10.0.0.0/16"

SUBNET_NAME="Public 1"
SUBNET_CIDR="10.0.0.0/24"
AVAILABILITY_ZONE="ap-southeast-1a"  # Update if needed

IGW_NAME="NextWork IG"

# 1. Create VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
  --query 'Vpc.VpcId' --output text)
echo "VPC ID: $VPC_ID"

# 2. Enable DNS hostname support (for public IPs to work properly)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames "{\"Value\":true}"

# 3. Create Subnet
echo "Creating Subnet..."
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID \
  --cidr-block $SUBNET_CIDR --availability-zone $AVAILABILITY_ZONE \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$SUBNET_NAME}]" \
  --query 'Subnet.SubnetId' --output text)
echo "Subnet ID: $SUBNET_ID"

# 4. Enable Auto-assign Public IP on Subnet
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch

# 5. Create Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$IGW_NAME}]" \
  --query 'InternetGateway.InternetGatewayId' --output text)
echo "IGW ID: $IGW_ID"

# 6. Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Internet Gateway attached."

# 7. Create Route Table and route for Internet
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' --output text)
echo "Route Table ID: $ROUTE_TABLE_ID"

aws ec2 create-route --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# 8. Associate Route Table with Subnet
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID

echo "✅ VPC setup complete!"
