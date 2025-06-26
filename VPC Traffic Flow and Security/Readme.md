# 🔐 AWS Networking Project 2: VPC Traffic Flow and Security

Welcome to the second part of the AWS networking series! In this project, you'll learn how to **control traffic flow and enforce security rules** in your custom Virtual Private Cloud (VPC). You’ll implement the foundational layers of network security in AWS.

> ✅ This project builds on [Project 1: Build a Virtual Private Cloud](https://learn.nextwork.org/projects/aws-networks-vpc?track=high). Complete that first if you haven't already.

---

## 📘 Project Overview

| Feature       | Details              |
| ------------- | -------------------- |
| 🧠 Difficulty | Easy                 |
| 🕒 Time       | \~60 minutes         |
| 💰 Cost       | Free (AWS Free Tier) |

---

## 🛠️ What You'll Build

You’ll enhance your VPC by adding:

* A **Route Table** to control how network traffic is directed
* A **Security Group** to protect your individual AWS resources
* A **Network ACL** to control traffic at the subnet level

Together, these define how your applications interact with the internet and other AWS resources.

---

## 🧰 Prerequisites

* An active [AWS account](https://aws.amazon.com/)
* Completion of [Project 1: Build a Virtual Private Cloud](https://learn.nextwork.org/projects/aws-networks-vpc?track=high)
* Basic understanding of networking terms: CIDR, subnet, gateway, etc.

---

## 🪜 Step-by-Step Guide

### ☁️ Step 1: Set Up Your VPC Infrastructure

This section repeats the essential steps from Project 1 to set up your VPC foundation.

1. **Create a VPC**:

   * Go to **VPC Dashboard > Your VPCs > Create VPC**
   * Name: `NextWork VPC`
   * CIDR block: `10.0.0.0/16` (Allows 65,536 IPs)

![alt text](Images/1.png)

2. **Create a Public Subnet**:

   * Go to **Subnets > Create subnet**
   * VPC: `NextWork VPC`
   * Name: `Public 1`
   * Availability Zone: Select the first in your region
   * Subnet CIDR block: `10.0.0.0/24` (256 IPs)
   * Enable **auto-assign public IPv4** to ensure internet accessibility

![alt text](Images/1.1.png)

3. **Create and Attach an Internet Gateway (IGW)**:

   * Go to **Internet Gateways > Create**
   * Name: `NextWork IG`
   * Attach to `NextWork VPC`

![alt text](Images/1.2.png)

> 🧠 A VPC is your own virtual network. Subnets are sections of this network. An IGW provides a doorway to the internet.

---

### 🚏 Step 2: Configure a Route Table

A route table controls how traffic moves within your VPC and how it gets in and out.

1. **Create a Route Table**:

   * Go to **Route Tables > Create route table**
   * Name: `NextWork Route Table`
   * VPC: `NextWork VPC`

2. **Add a Route to the Internet**:

   * Edit the new route table → Routes tab → Edit routes
   * Add route: `Destination: 0.0.0.0/0`, `Target: Internet Gateway (NextWork IG)`

3. **Associate Route Table with Subnet**:

   * Go to the **Subnet Associations tab**
   * Select `Public 1` subnet

> 📘 Think of a route table like a GPS that tells packets where to go — local or internet.

![alt text](Images/2.png)

---

### 👮‍♀️ Step 3: Create a Security Group (SG)

Security groups act like firewalls for individual AWS resources (like EC2 instances).

1. **Create the Security Group**:

   * Go to **Security Groups > Create**
   * Name: `NextWork Security Group`
   * Description: `Allows HTTP traffic`
   * VPC: `NextWork VPC`

2. **Add Inbound Rule**:

   * Type: `HTTP`
   * Port: `80`
   * Source: `0.0.0.0/0` (allows public access)

> 🔐 Security Groups only allow explicitly defined traffic. By default, all inbound traffic is denied.

![alt text](Images/3.png)

---

### 📋 Step 4: Set Up a Network ACL (NACL)

Network ACLs provide subnet-level traffic filtering. Unlike security groups, they support **allow** and **deny** rules.

1. **Create Network ACL**:

   * Go to **Network ACLs > Create**
   * Name: `NextWork Network ACL`
   * VPC: `NextWork VPC`

![alt text](Images/4.png)

2. **Add Inbound Rule**:

   * Rule #: `100`
   * Type: `All Traffic`
   * Source: `0.0.0.0/0`
   * Allow

![alt text](Images/4.1.png)

3. **Add Outbound Rule**:

   * Rule #: `100`
   * Type: `All Traffic`
   * Destination: `0.0.0.0/0`
   * Allow

![alt text](Images/4.2.png)

4. **Associate Subnet**:

   * Subnet: `Public 1`

![alt text](Images/4.3.png)

> 🛡️ Network ACLs are like police at subnet entry/exit. They work alongside security groups to add another layer of protection.

---

## 🧼 Cleanup

To avoid unwanted charges:

1. Go to **Your VPCs > Select `NextWork VPC` > Actions > Delete VPC**
2. Verify that associated resources (subnet, IGW, route table, security group, ACL) are deleted

---

## 🧠 Concepts Recap

| Component      | Role & Responsibility                           |
| -------------- | ----------------------------------------------- |
| VPC            | Isolated network in AWS                         |
| Subnet         | Subdivision of the VPC IP space                 |
| Route Table    | Manages direction of traffic within/outside VPC |
| Security Group | Resource-level firewall (instance-based)        |
| Network ACL    | Subnet-level firewall (stateless)               |

---

## 🏁 Next Steps

* ✅ Finished this? Great! Proceed to **[Creating a Private Subnet](https://learn.nextwork.org/projects/aws-networks-private-subnet)**
* ⚙️ Advanced: Recreate this setup using AWS CLI, Terraform, or CloudFormation

---