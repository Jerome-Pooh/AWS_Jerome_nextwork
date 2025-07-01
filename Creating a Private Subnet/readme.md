# 🔒 AWS Networking Project 3: Creating a Private Subnet

Welcome to your third AWS networking project!  
In this hands-on guide, you’ll learn how to add a **private subnet** to your VPC for storing secure internal resources like databases — isolated from public internet access.

> ✅ Make sure you’ve completed:
> - [✅ Project 1: Build a Virtual Private Cloud](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/Build%20a%20Virtual%20Private%20Cloud%20(VPC)%20on%20AWS)  
> - [✅ Project 2: VPC Traffic Flow and Security](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/VPC%20Traffic%20Flow%20and%20Security)

---

## 📘 Project Overview

| Feature       | Details                    |
|---------------|----------------------------|
| 🧠 Difficulty | Easy-ish                   |
| ⏱️ Time       | ~60 minutes                |
| 💰 Cost       | Free (AWS Free Tier)       |

---

## 🛠️ What You’ll Build

- A **private subnet** (in a different IP range)
- A **private route table** (no route to the internet)
- A **custom network ACL** (restricts traffic)

> 📦 You’ll reuse your existing VPC setup from previous projects.

---

## 🧰 Prerequisites

- An AWS Account
- Familiarity with VPC, Subnets, CIDR blocks, Route Tables, Security Groups, and ACLs
- Previously created:
  - `NextWork VPC`
  - `NextWork Public Subnet`
  - `NextWork IG`, `NextWork Route Table`, `NextWork SG`, and `NextWork Network ACL`

---

## 🪜 Step-by-Step Guide

---

### 🚷 Step 1: Create a Private Subnet

1. Go to **VPC > Subnets > Create Subnet**
2. Fill in:
   - **VPC ID:** `NextWork VPC`
   - **Subnet Name:** `NextWork Private Subnet`
   - **Availability Zone:** Choose the second one
   - **CIDR Block:** `10.0.1.0/24`

3. Click **Create subnet**

> 💡 CIDR Explanation:  
> `10.0.1.0/24` gives you 256 IPs and **does not overlap** with your public subnet (`10.0.0.0/24`).

✅ You now have a subnet with no internet access — yet.

![alt text](Images/1.png)

---

### 🚧 Step 2: Create a Private Route Table

1. Go to **VPC > Route Tables > Create Route Table**
2. Fill in:
   - **Name tag:** `NextWork Private Route Table`
   - **VPC:** `NextWork VPC`

![alt text](Images/2.png)

3. Click **Create Route Table**

4. Go to **Subnet Associations**
   - Click **Edit**
   - Select `NextWork Private Subnet`
   - Save

![alt text](Images/2.1.png)

5. Go to **Routes Tab**
   - Confirm it only has `10.0.0.0/16 → local`
   - ⚠️ **No route to the Internet Gateway!**

✅ You’ve just ensured this subnet has **no path to the public internet**.

![alt text](Images/2.2.png)

---

### 📋 Step 3: Create a Private Network ACL

1. Go to **VPC > Network ACLs > Create Network ACL**
2. Fill in:
   - **Name tag:** `NextWork Private NACL`
   - **VPC:** `NextWork VPC`
3. Click **Create**

![alt text](Images/3.png)

4. Select your NACL > **Subnet Associations**
   - Click **Edit**
   - Select `NextWork Private Subnet`
   - Save

![alt text](Images/3.1.png)

5. Add **Inbound Rule**:
   - Rule #: `100`
   - Type: `All Traffic`
   - Source: `0.0.0.0/0`
   - Action: `DENY`

![alt text](Images/3.2.png)

6. Add **Outbound Rule**:
   - Rule #: `100`
   - Type: `All Traffic`
   - Destination: `0.0.0.0/0`
   - Action: `DENY`

![alt text](Images/3.3.png)

> 🛡️ Why deny all?  
> Custom NACLs deny all traffic by default — this keeps your subnet **locked down** until explicitly opened.

---

## 🔄 Suggested Naming Conventions

| Resource Type     | Name                       |
|-------------------|----------------------------|
| Public Subnet     | `NextWork Public Subnet`   |
| Private Subnet    | `NextWork Private Subnet`  |
| Route Tables      | `NextWork Public/Private`  |
| Network ACLs      | `NextWork Public/Private`  |

---

## 📊 Public vs Private Subnet Comparison

| Feature             | Public Subnet             | Private Subnet              |
|---------------------|---------------------------|------------------------------|
| Internet Access     | ✅ Yes (via IGW)          | ❌ No                        |
| Route Table         | Has IGW route             | No IGW route                |
| Used For            | Web servers, APIs         | DBs, app backends           |
| NACL Default        | Allow all                 | Deny all                    |

---

## 🧼 Cleanup Instructions

Delete resources if you're not moving on to the next project today:

1. Go to **VPC > Your VPCs**
2. Select `NextWork VPC` → **Actions → Delete VPC**
3. Double check:
   - Subnets
   - Route Tables
   - IGWs
   - ACLs
   - Security Groups

> 🧠 This avoids leftover resources that might cost you later.

---

## 🧠 Concept Recap



| Concept       | Description |
|---------------|-------------|
| **CIDR Block** | Defines IP address ranges |
| **Private Subnet** | No internet access allowed |
| **Route Table** | Determines where traffic goes |
| **NACL** | Controls traffic at subnet level |
| **Security Group** | Controls traffic at instance level |

---

# 🔧 AWS CLI Script: Creating a Private Subnet in a VPC

## 📘 What This Script Does

✅ Creates a **private subnet** in your existing VPC  
✅ Creates a **private route table** (no internet route)  
✅ Creates a **custom NACL** that **denies all traffic**  
✅ Associates the subnet with the route table and NACL  

## ⚙️ Prerequisites

- AWS CLI installed and configured (`aws configure`)
- You already created a VPC called `NextWork VPC`  
- The region and availability zone are correctly set
- IAM permissions to manage VPC, subnets, NACLs, and route tables

```bash
#!/bin/bash

# ==============================
# 🛠 SETUP VARIABLES
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
```


## 🙌 Credits

Based on the [NextWork Project Guide](https://learn.nextwork.org/projects/aws-networks-private?track=high)  
Expanded and explained for GitHub by a fellow cloud learner ☁️

---
