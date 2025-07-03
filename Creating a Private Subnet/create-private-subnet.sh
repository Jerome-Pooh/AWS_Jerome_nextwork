#!/bin/bash

# ==============================
# í»  SETUP VARIABLES
# ==============================

# Replace these with actual values from your environment
VPC_NAME="NextWork VPC"
PRIVATE_SUBNET_NAME="NextWork Private Subnet"
PRIVATE_ROUTE_TABLE_NAME="NextWork Private Route Table"
PRIVATE_NACL_NAME="NextWork Private NACL"
CIDR_BLOCK_PRIVATE="10.0.1.0/24"
AVAILABILITY_ZONE="ap-southeast-1b" # Update to your second AZ

# ==============================
#  GET VPC ID
# ==============================

VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=$VPC_NAME" \
  --query "Vpcs[0].VpcId" \
  --output text)

echo " VPC ID: $VPC_ID"

# ==============================
#  CREATE PRIVATE SUBNET
# ==============================

SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $CIDR_BLOCK_PRIVATE \
  --availability-zone $AVAILABILITY_ZONE \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$PRIVATE_SUBNET_NAME}]" \
  --query "Subnet.SubnetId" \
  --output text)

echo " Created Private Subnet: $SUBNET_ID"

# ==============================
#  CREATE PRIVATE ROUTE TABLE
# ==============================

RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$PRIVATE_ROUTE_TABLE_NAME}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

echo " Created Route Table: $RT_ID"

# Associate Route Table with Private Subnet
aws ec2 associate-route-table \
  --route-table-id $RT_ID \
  --subnet-id $SUBNET_ID

echo " Associated Route Table with Private Subnet"

# ==============================
#  CREATE PRIVATE NACL
# ==============================

NACL_ID=$(aws ec2 create-network-acl \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=network-acl,Tags=[{Key=Name,Value=$PRIVATE_NACL_NAME}]" \
  --query "NetworkAcl.NetworkAclId" \
  --output text)

echo " Created Network ACL: $NACL_ID"

# Associate NACL with Private Subnet
aws ec2 associate-network-acl \
  --network-acl-id $NACL_ID \
  --subnet-id $SUBNET_ID

echo " Associated NACL with Private Subnet"

# ==============================
#  DENY INBOUND + OUTBOUND TRAFFIC
# ==============================

# Add DENY rule for all inbound traffic
aws ec2 create-network-acl-entry \
  --network-acl-id $NACL_ID \
  --rule-number 100 \
  --protocol -1 \
  --rule-action deny \
  --ingress \
  --cidr-block 0.0.0.0/0

# Add DENY rule for all outbound traffic
aws ec2 create-network-acl-entry \
  --network-acl-id $NACL_ID \
  --rule-number 100 \
  --protocol -1 \
  --rule-action deny \
  --egress \
  --cidr-block 0.0.0.0/0

echo " Denied all traffic in Private NACL (inbound & outbound)"

# ==============================
#  DONE
# ==============================

echo "  - Private subnet setup completed!"
echo "  - Subnet ID: $SUBNET_ID"
echo "  - Route Table ID: $RT_ID"
echo "  - NACL ID: $NACL_ID"
