# 🛠️ Build a Virtual Private Cloud (VPC) on AWS

Welcome! In this project, you’ll learn the **basics of AWS networking** by setting up your own Virtual Private Cloud (VPC), step-by-step.

🕒 **Time:** ~60 minutes  
💰 **Cost:** Free (on Free Tier)  
🌱 **Skill Level:** Beginner

---

## 📚 What You'll Learn

- What a VPC is and why it matters
- How to create a custom VPC
- How to set up public subnets
- How to configure an Internet Gateway
- Basic IP & CIDR concepts in AWS

---

## 🧰 Prerequisites

- An [AWS account](https://aws.amazon.com/)
- Basic knowledge of cloud computing concepts
- Optional: Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

## 🪜 Step-by-Step Guide

### ☁️ Step 1: Create a VPC

1. **Login to AWS Console**  
   Go to [AWS Console](https://console.aws.amazon.com/).

2. **Search "VPC"**  
   In the search bar, type `VPC` and select **VPC Dashboard**.

3. **Navigate to "Your VPCs"**  
   Click `Your VPCs` in the left panel.

4. **Create VPC**
   - Click `Create VPC`
   - Choose `VPC Only`
   - **Name Tag:** `NextWork VPC`
   - **IPv4 CIDR Block:** `10.0.0.0/16`
   - Leave the rest as default and click **Create VPC**

🧠 *What’s a CIDR?*  
CIDR defines the IP address range for your VPC. `10.0.0.0/16` gives you 65,536 possible IPs!

![alt text](Images/1.png)
![alt text](Images/1.1.png)

---

### 🧱 Step 2: Create a Subnet

1. In the VPC dashboard, go to `Subnets`.

2. Click `Create Subnet`
   - **VPC ID:** Select `NextWork VPC`
   - **Subnet Name:** `Public 1`
   - **AZ:** Choose the first available
   - **IPv4 CIDR block:** `10.0.0.0/24` (smaller segment of your VPC)

3. Click `Create Subnet`

4. Select your new subnet > Actions > `Edit subnet settings`
   - Enable **Auto-assign public IPv4 address**
   - Save

📘 *Why public?*  
This will let resources (like EC2) in the subnet get a public IP for internet access.

![alt text](Images/2.png)
![alt text](Images/2.1.png)
![alt text](Images/2.2.png)

---

### 🌐 Step 3: Create and Attach an Internet Gateway

1. In VPC dashboard, go to `Internet Gateways`.

2. Click `Create Internet Gateway`
   - **Name tag:** `NextWork IG`
   - Click **Create**

3. Select the new IG > Actions > `Attach to VPC`
   - Choose `NextWork VPC` > Click **Attach**

🧠 *What’s an IG?*  
An Internet Gateway connects your private VPC to the internet.

![alt text](Images/3.png)
![alt text](Images/3.1.png)
![alt text](Images/3.2.png)

---

## 🧹 Clean Up: Delete Your Resources

To avoid charges:

1. Go to `VPC > Your VPCs`
2. Select `NextWork VPC` > Actions > Delete
   - This also deletes your subnet and IG

If needed:
- Delete IG in `Internet Gateways`
- Delete subnet in `Subnets`

---

## 💡 Concepts Recap

| Concept | Description |
|--------|-------------|
| **VPC** | A private, virtual network in AWS |
| **Subnet** | A smaller range of IPs within your VPC |
| **CIDR Block** | Defines how many IPs your network/subnet can have |
| **Internet Gateway** | Connects your VPC to the internet |
| **Public Subnet** | A subnet where resources can access the internet |

---


## 📦 Next Steps

Build on this by exploring:
- VPC Security Groups & NACLs
- Private Subnets & NAT Gateways
- Deploying EC2 Instances inside your VPC

---

