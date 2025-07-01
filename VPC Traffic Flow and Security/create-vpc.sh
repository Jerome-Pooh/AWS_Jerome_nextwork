#!/bin/bash

######################################
# AWS Networking Project 2: VPC Traffic Flow and Security
# This script creates:
# - VPC
# - Public Subnet
# - Internet Gateway
# - Route Table with Internet Access
# - Security Group (allows HTTP)
# - Network ACL (allows all in/out)
######################################

# -------------------------------
# CONFIGURATION VARIABLES
# -------------------------------

REGION="ap-southeast-1"
AZ="${REGION}a"
VPC_NAME="NextWork VPC"
SUBNET_NAME="Public 1"
IGW_NAME="NextWork IG"
RT_NAME="NextWork Route Table"
SG_NAME="NextWork Security Group"
SG_DESC="Allows HTTP traffic"
ACL_NAME="NextWork Network ACL"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.0.0/24"

# -------------------------------
# CREATE VPC
# -------------------------------

echo "🛠️  Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
  --query 'Vpc.VpcId' --output text)
echo "✅ VPC created: $VPC_ID"

# -------------------------------
# CREATE SUBNET
# -------------------------------

echo "🛠️  Creating Subnet..."
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_CIDR \
  --availability-zone $AZ \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$SUBNET_NAME}]" \
  --query 'Subnet.SubnetId' --output text)

aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_ID \
  --map-public-ip-on-launch

echo "✅ Subnet created: $SUBNET_ID"

# -------------------------------
# CREATE INTERNET GATEWAY
# -------------------------------

echo "🛠️  Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$IGW_NAME}]" \
  --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

echo "✅ Internet Gateway created and attached: $IGW_ID"

# -------------------------------
# CREATE ROUTE TABLE
# -------------------------------

echo "🛠️  Creating Route Table..."
RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$RT_NAME}]" \
  --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route \
  --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

aws ec2 associate-route-table \
  --route-table-id $RT_ID \
  --subnet-id $SUBNET_ID

echo "✅ Route Table created and associated: $RT_ID"

# -------------------------------
# CREATE SECURITY GROUP
# -------------------------------

echo "🛠️  Creating Security Group..."
SG_ID=$(aws ec2 create-security-group \
  --group-name "$SG_NAME" \
  --description "$SG_DESC" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

echo "✅ Security Group created: $SG_ID"

# -------------------------------
# CREATE NETWORK ACL
# -------------------------------

echo "🛠️  Creating Network ACL..."
ACL_ID=$(aws ec2 create-network-acl \
  --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=network-acl,Tags=[{Key=Name,Value=$ACL_NAME}]" \
  --query 'NetworkAcl.NetworkAclId' --output text)
echo "✅ Network ACL created: $ACL_ID"

# Add Ingress rule (allows all inbound traffic)
echo "🛠️  Adding Ingress rule to Network ACL ($ACL_ID)..."
aws ec2 create-network-acl-entry \
  --network-acl-id "$ACL_ID" \
  --rule-number 100 \
  --protocol -1 \
  --rule-action allow \
  --ingress \
  --cidr-block 0.0.0.0/0
echo "✅ Ingress rule added to ACL."

# Add Egress rule (allows all outbound traffic)
echo "🛠️  Adding Egress rule to Network ACL ($ACL_ID)..."
aws ec2 create-network-acl-entry \
  --network-acl-id "$ACL_ID" \
  --rule-number 101 \
  --protocol -1 \
  --rule-action allow \
  --egress \
  --cidr-block 0.0.0.0/0
echo "✅ Egress rule added to ACL."

# --- START Network ACL Association (Reverted to replace-network-acl-association with improved logging) ---
echo "🛠️  Attempting to associate Network ACL '$ACL_ID' with subnet '$SUBNET_ID'..."

# Get current ACL association ID
# This command should return an association ID, even if it's the default ACL association.
# We redirect stderr to stdout to capture any error messages from aws CLI in ASSOC_ID.
ASSOC_ID=$(aws ec2 describe-subnets \
  --subnet-ids "$SUBNET_ID" \
  --query "Subnets[0].NetworkAclAssociationId" \
  --output text 2>&1)

echo "DEBUG: Retrieved raw Association ID: '$ASSOC_ID'"

# Check if ASSOC_ID contains an error message or is empty/None
if [[ "$ASSOC_ID" == *"An error occurred"* ]]; then
  echo "❌ Error retrieving current Network ACL association ID: $ASSOC_ID"
  echo "   Skipping ACL replacement as the current association could not be determined."
elif [ -z "$ASSOC_ID" ] || [ "$ASSOC_ID" = "None" ]; then
  # This branch should ideally not be hit if describe-subnets always returns an ID.
  # However, it's a safeguard for unexpected 'None' or empty responses.
  echo "❌ Current Network ACL association ID is empty or 'None' ('$ASSOC_ID')."
  echo "   'replace-network-acl-association' requires an existing association ID."
  echo "   If your AWS CLI does not support 'associate-network-acl', you may need to manually"
  echo "   associate the ACL with the subnet via the AWS console."
else
  echo "DEBUG: Identified current Network ACL Association ID: '$ASSOC_ID'"
  echo "🛠️  Replacing existing Network ACL association '$ASSOC_ID' with new ACL '$ACL_ID' for subnet '$SUBNET_ID'..."

  aws ec2 replace-network-acl-association \
    --association-id "$ASSOC_ID" \
    --network-acl-id "$ACL_ID"

  if [ $? -eq 0 ]; then
    echo "✅ Successfully replaced Network ACL association for subnet $SUBNET_ID with $ACL_ID."
  else
    echo "❌ Failed to replace Network ACL association. Please review the AWS CLI error output above for details."
  fi
fi
# --- END Network ACL Association (Updated Logic) ---

# -------------------------------
# DONE
# -------------------------------

echo ""
echo "🎉 Your VPC with Route Table, Security Group, and ACL is ready!"
echo "🔹 VPC ID:        $VPC_ID"
echo "🔹 Subnet ID:     $SUBNET_ID"
echo "🔹 IGW ID:        $IGW_ID"
echo "🔹 Route Table:   $RT_ID"
echo "🔹 Sec Group ID:  $SG_ID"
echo "🔹 ACL ID:        $ACL_ID"