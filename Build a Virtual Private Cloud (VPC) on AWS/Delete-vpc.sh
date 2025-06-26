#!/bin/bash

# 🧹 AWS VPC Cleanup Script
# This script deletes a VPC and its resources (subnets, route tables, IGW)

# 👉 STEP 0: Enter your own VPC and Internet Gateway IDs below:
VPC_ID="vpc-xxxxxxxxxxxxxxxxxx"  # Replace with your VPC ID
IGW_ID="igw-xxxxxxxxxxxxxxxxxxx"  # Replace with your Internet Gateway ID

echo "🚀 Starting cleanup for VPC: $VPC_ID"

# 👉 STEP 1: Remove route table associations (other than the main one)
echo "🔍 Looking for custom route table associations..."
ASSOCIATION_IDS=$(aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "RouteTables[*].Associations[?Main==\`false\`].RouteTableAssociationId" \
  --output text)

for assoc in $ASSOCIATION_IDS; do
  echo "🔸 Removing association: $assoc"
  aws ec2 disassociate-route-table --association-id "$assoc"
done

# 👉 STEP 2: Delete any non-main route tables
echo "🔍 Finding route tables in the VPC..."
ROUTE_TABLE_IDS=$(aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "RouteTables[*].RouteTableId" --output text)

for rtb in $ROUTE_TABLE_IDS; do
  IS_MAIN=$(aws ec2 describe-route-tables --route-table-ids "$rtb" \
    --query "RouteTables[0].Associations[0].Main" --output text)

  if [ "$IS_MAIN" != "true" ]; then
    echo "🗑️ Deleting route table: $rtb"
    aws ec2 delete-route-table --route-table-id "$rtb"
  fi
done

# 👉 STEP 3: Detach and delete the Internet Gateway
echo "🔌 Detaching Internet Gateway: $IGW_ID"
aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"

echo "🗑️ Deleting Internet Gateway: $IGW_ID"
aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"

# 👉 STEP 4: Delete all subnets in the VPC
echo "📡 Finding subnets in the VPC..."
SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[*].SubnetId" --output text)

for subnet in $SUBNET_IDS; do
  echo "🗑️ Deleting subnet: $subnet"
  aws ec2 delete-subnet --subnet-id "$subnet"
done

# 👉 STEP 5: Finally, delete the VPC
echo "💥 Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id "$VPC_ID"

echo "✅ All done! Your VPC and related resources have been deleted."
