#!/bin/bash

##########################################
# Cleanup Script for AWS Networking Project 2
# Safely deletes all resources in the correct order
##########################################

# ----------------------------
# 📝 Replace with your resource IDs
# ----------------------------
VPC_ID="vpc-0dcc7ec4d327702dc"
SUBNET_ID="subnet-099ba599f49fd3a8b"
IGW_ID="igw-0fcd660b9b2f899fe"
RT_ID="rtb-0e6aa5b579c9ab33c"
SG_ID="sg-03d947659a3930f28"
ACL_ID="acl-08e5f43da8154c010"

echo "⚠️  Starting cleanup..."

# ----------------------------
# 1. Detach and delete IGW
# ----------------------------
echo "🔌 Detaching Internet Gateway from VPC..."
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

echo "❌ Deleting Internet Gateway..."
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# ----------------------------
# 2. Disassociate and delete Route Table
# ----------------------------
echo "🔗 Disassociating Route Table..."
ASSOC_ID=$(aws ec2 describe-route-tables \
  --route-table-ids $RT_ID \
  --query "RouteTables[0].Associations[?Main==\`false\`].RouteTableAssociationId" \
  --output text)

if [ -n "$ASSOC_ID" ]; then
  aws ec2 disassociate-route-table --association-id $ASSOC_ID
  echo "✅ Disassociated: $ASSOC_ID"
fi

echo "🧭 Deleting Route Table..."
aws ec2 delete-route-table --route-table-id $RT_ID

# ----------------------------
# 3. Disassociate and delete Network ACL
# ----------------------------
echo "🔗 Disassociating Network ACL from Subnet..."
ACL_ASSOC_ID=$(aws ec2 describe-subnets \
  --subnet-ids $SUBNET_ID \
  --query "Subnets[0].NetworkAclAssociationId" \
  --output text)

if [ "$ACL_ASSOC_ID" = "None" ] || [ -z "$ACL_ASSOC_ID" ]; then
  echo "⚠️  No ACL association found or already default — skipping replacement."
else
  DEFAULT_ACL_ID=$(aws ec2 describe-network-acls \
    --filters Name=default,Values=true Name=vpc-id,Values=$VPC_ID \
    --query "NetworkAcls[0].NetworkAclId" --output text)

  aws ec2 replace-network-acl-association \
    --association-id "$ACL_ASSOC_ID" \
    --network-acl-id "$DEFAULT_ACL_ID"

  echo "✅ ACL replaced with default"
fi

echo "📋 Deleting Network ACL..."
aws ec2 delete-network-acl --network-acl-id $ACL_ID


# ----------------------------
# 4. Delete Subnet
# ----------------------------
echo "🧱 Deleting Subnet..."
aws ec2 delete-subnet --subnet-id $SUBNET_ID

# ----------------------------
# 5. Delete Security Group
# ----------------------------
echo "🛡️ Deleting Security Group..."
aws ec2 delete-security-group --group-id $SG_ID

# ----------------------------
# 6. Delete VPC
# ----------------------------
echo "🏙️ Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "✅ Cleanup complete! All resources deleted."
