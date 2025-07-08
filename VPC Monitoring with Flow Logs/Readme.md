# AWS Project: VPC Monitoring with Flow Logs

**Difficulty**: Spicy 🌶
**Time**: \~60 mins
**Cost**: Free Tier

---

## ✨ Project Overview

In this project, we enhance our AWS networking skills by enabling **network traffic monitoring** in our VPC using **VPC Flow Logs** and **Amazon CloudWatch**. This project builds upon the previous networking projects from NextWork and assumes that you've already:

* Created VPCs
* Launched EC2 instances
* Tested connectivity
* Configured VPC peering

You can refer to the previous steps from these GitHub repos:

* [Project 1: Build a VPC](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/Build%20a%20Virtual%20Private%20Cloud%20%28VPC%29%20on%20AWS)
* [Project 2: VPC Traffic Flow and Security](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/VPC%20Traffic%20Flow%20and%20Security)
* [Project 4: Launching VPC Resources](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/Launching%20VPC%20Resources)
* [Project 5: Testing VPC Connectivity](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/Testing%20VPC%20Connectivity)
* [Project 6: VPC Peering](https://github.com/Jerome-Pooh/AWS_Jerome_nextwork/tree/main/VPC%20Peering)

---

## ✅ Step-by-Step Instructions

### 🔹 Step 1: Create Two VPCs

1. **Go to the VPC Console**

   * Search "VPC" in the AWS Console.

2. **Click "Create VPC" > "VPC and more"**

3. **Create VPC 1:**

   * Name: `NextWork-1`
   * IPv4 CIDR: `10.1.0.0/16`
   * Public Subnet: 1
   * NAT Gateway: None
   * VPC Endpoints: None
   * Tenancy: Default

4. **Create VPC 2:**

   * Name: `NextWork-2`
   * IPv4 CIDR: `10.2.0.0/16`
   * Same settings as VPC 1

> ⚡ **Explanation:** Each VPC gets a unique CIDR block to prevent IP conflicts. One public subnet is enough since we won’t need NAT or private subnets.

---

### 🔹 Step 2: Launch EC2 Instances

1. Go to **EC2 Console**
2. Click **Launch Instance**
3. Use these settings for both VPCs:

   * AMI: Amazon Linux 2023
   * Instance Type: `t2.micro`
   * Name: `Instance - NextWork VPC 1` (or VPC 2)
   * Key Pair: Proceed without
   * Enable Public IP
4. Create a **new security group**:

   * Allow `All ICMP - IPv4` from `0.0.0.0/0`

> ⚡ **Explanation:** We enable ping (ICMP) so we can test connectivity. EC2 Instance Connect needs public IP and public subnet access.

---

### 🔹 Step 3: Set Up VPC Flow Logs

1. Go to **CloudWatch Console > Logs > Log groups**

2. Click **Create Log Group**

   * Name: `NextWorkVPCFlowLogsGroup`

3. Go back to **VPC Console > Your VPCs**

4. Select VPC 1 > **Flow Logs > Create Flow Log**

5. Settings:

   * Name: `NextWorkVPCFlowLog`
   * Filter: All
   * Max Aggregation: 1 minute
   * Destination: CloudWatch Logs
   * Destination Log Group: `NextWorkVPCFlowLogsGroup`
   * IAM Role: (will be created next)

> ⚡ **Explanation:** Flow Logs track all inbound/outbound traffic. Sending to CloudWatch helps us view and analyze it later.

---

### 🔹 Step 4: Create IAM Policy and Role

#### Create IAM Policy

1. Go to **IAM Console > Policies > Create Policy**
2. Choose JSON and paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    }
  ]
}
```

3. Name: `NextWorkVPCFlowLogsPolicy`

#### Create IAM Role

1. Go to **IAM Console > Roles > Create Role**
2. Choose **Custom Trust Policy**:

```json
"Principal": {
  "Service": "vpc-flow-logs.amazonaws.com"
}
```

3. Attach previously created policy
4. Name: `NextWorkVPCFlowLogsRole`

Return to VPC > Flow Logs and select this role.

---

### 🔹 Step 5: Test VPC Peering Connection

1. **Ping VPC 2 from VPC 1** using private IP — fails
2. Ping VPC 2 using public IP — succeeds

> ⚡ **Explanation:** No route exists for private IP. This tells us a **peering connection** and **route update** is needed.

---

### 🔹 Step 6: Create Peering Connection + Update Route Tables

1. Go to **VPC > Peering Connections > Create**

   * Name: `VPC 1 <> VPC 2`
   * Requester: VPC 1
   * Accepter: VPC 2 (same region)

2. Accept the request

3. Update Route Tables

   * VPC 1: add route to `10.2.0.0/16` via peering connection
   * VPC 2: add route to `10.1.0.0/16` via peering connection

4. Retry ping using private IP — now succeeds!

---

### 🔹 Step 7: Analyze Flow Logs in CloudWatch

1. Go to **CloudWatch > Log Groups > NextWorkVPCFlowLogsGroup**
2. Open log stream (named after `eni-*`)
3. Expand logs to view source/destination, bytes, protocol, status (ACCEPT/REJECT)

#### Use Log Insights

1. Select **Logs Insights**
2. Choose log group `NextWorkVPCFlowLogsGroup`
3. Run query:

```sql
fields @timestamp, @message
| stats sum(bytes) by srcAddr, dstAddr
| sort sum(bytes) desc
| limit 10
```

> ⚡ **Explanation:** This shows the top 10 IP pairs transferring the most data — great for spotting traffic spikes.

---

## ♻️ Clean-Up

1. Terminate both EC2 instances
2. Delete VPC peering connection (with route entries)
3. Delete both VPCs
4. Delete CloudWatch Log Group
5. Delete IAM Role and Policy

---

## 🎓 Final Notes

You now know how to:

* Monitor network traffic using Flow Logs
* Route traffic between peered VPCs
* Analyze logs using CloudWatch Logs Insights

Next project: [Access S3 from a VPC](https://learn.nextwork.org/projects/aws-networks-s3access?track=high)
