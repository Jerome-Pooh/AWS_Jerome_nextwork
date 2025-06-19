# Cloud Security with AWS IAM

## Project Description

This project, part of the AWS Beginners Challenge, guides you through a hands-on experience in securing your cloud resources using AWS Identity and Access Management (IAM). As a DevOps engineer at NextWork, you will learn to control who is authenticated and authorized in your AWS account by managing access to Amazon EC2 instances. You'll gain practical experience in setting up secure environments, onboarding new team members with appropriate permissions, and ensuring that sensitive production resources are protected from unauthorized access.

This project is designed for absolute beginners with zero prior cloud experience, aiming to help you kickstart your cloud portfolio.

## Features & Key Concepts Learned

Throughout this project, you will learn and work with the following AWS services and fundamental cloud security concepts:

* **AWS IAM (Identity and Access Management):** Understand how to manage access levels for users and services to your AWS resources.
* **Amazon EC2 (Elastic Compute Cloud):** Launch and manage virtual servers in the cloud to boost computing power.
* **IAM Policies:** Define rules for who can perform specific actions on your AWS resources.
* **IAM Users and User Groups:** Create individual user accounts and organize them into groups for simplified permission management.
* **AWS Account Alias:** Create a user-friendly alias for your AWS account login URL.
* **Resource Tagging:** Utilize tags (e.g., `Env: production`, `Env: development`) for organizing and filtering resources, crucial for applying granular policies.
* **Development vs. Production Environments:** Understand the importance of separating resources for different stages of software development.
* **Secure Access Practices:** Learn to set up and test user permissions to prevent unauthorized access to sensitive resources.

## Difficulty & Time Commitment

* **Difficulty:** Easy peasy
* **Time:** Approximately 1 hour

## Cost

* **Cost:** $0 (if all resources are deleted after the project and Free Tier eligible options are utilized)

## Prerequisites

* An AWS account. If you don't have one, you can create one [here](https://aws.amazon.com/free/).

## Project Steps

This project is broken down into several guided steps, building your AWS security knowledge incrementally.

### Step #0: Before We Start - Project Goal

Understand the objective: Demonstrate how to control access to AWS resources, specifically EC2 instances, using IAM by setting up policies and user groups for different environments (production and development).

### Step #1: Launch EC2 Instances

You'll start by acting as a DevOps engineer at NextWork, tasked with boosting computing power and onboarding an intern.

* **Objective:** Launch two Amazon EC2 instances: one for your `production` environment and one for your `development` environment.
* **Key Actions:**
    * Log in to the AWS Management Console and navigate to the EC2 dashboard.
    * Launch the first EC2 instance:
        * Name: `nextwork-prod-<your_name>`
        * Tags: `Key: Env`, `Value: production`
        * Ensure a Free Tier eligible **Amazon Machine Image (AMI)** and **Instance Type** are selected.
        * Proceed without a key pair for simplicity in this project (though not recommended for real-world scenarios).
    * Launch the second EC2 instance:
        * Name: `nextwork-dev-<your_name>`
        * Tags: `Key: Env`, `Value: development`
        * Use Free Tier eligible AMI and Instance Type.
    * Verify both instances are created and tagged correctly.
* **Concepts Explained:**
    * **EC2:** A service that provides virtual computers in the cloud.
    * **AMI:** A template containing the operating system and applications to launch an EC2 instance.
    * **Instance Type:** Defines the hardware components (CPU, memory, storage) of your EC2 instance.
    * **Tags:** Labels used for organizing, identifying, and filtering AWS resources, crucial for policy application.
    * **Virtual Computer vs. Server:** Understanding the difference in purpose and use cases.
    * **Key Pair:** Used for secure SSH access to your EC2 instance (outside the scope of this project).

### Step #2: Create an IAM Policy

Now, set up permissions for the new intern, ensuring they only have access to the development EC2 instance.

* **Objective:** Create an IAM policy that grants access specifically to the development EC2 instance.
* **Key Actions:**
    * Navigate to the IAM console and select "Policies."
    * Choose "Create policy" and switch to the "JSON" editor.
    * Paste the provided JSON policy:
        ```json
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": "ec2:*",
              "Resource": "*",
              "Condition": {
                "StringEquals": {
                  "ec2:ResourceTag/Env": "development"
                }
              }
            },
            {
              "Effect": "Allow",
              "Action": "ec2:Describe*",
              "Resource": "*"
            },
            {
              "Effect": "Deny",
              "Action": [
                "ec2:DeleteTags",
                "ec2:CreateTags"
              ],
              "Resource": "*"
            }
          ]
        }
        ```
    * Name the policy: `NextWorkDevEnvironmentPolicy`
    * Add a valid description (e.g., "IAM Policy for NextWork's development environment").
* **Concepts Explained:**
    * **IAM:** Central service for managing identities and access.
    * **Policy:** A document that defines permissions, specifying who can do what to which resources under what conditions.
    * **JSON Policy Structure:** Breakdown of `Version`, `Statement`, `Effect` (`Allow`/`Deny`), `Action`, `Resource`, and `Condition` blocks.
        * **`Effect: Allow` + `Action: ec2:*` + `Condition: ec2:ResourceTag/Env: development`:** Allows all EC2 actions on resources tagged with `Env: development`.
        * **`Effect: Allow` + `Action: ec2:Describe*`:** Allows viewing (describing) all EC2 resources.
        * **`Effect: Deny` + `Action: ec2:DeleteTags, ec2:CreateTags`:** Denies the ability to create or delete tags on any EC2 resource, enhancing security.

### Step #3: Create an AWS Account Alias

Simplify the login process for your intern.

* **Objective:** Create a friendly alias for your AWS account login URL.
* **Key Actions:**
    * In the IAM console, go to "Dashboard."
    * Under "Account Alias," choose "Create."
    * Enter a preferred alias: `nextwork-alias-<your_name>`
* **Concepts Explained:**
    * **Account Alias:** A custom, memorable name that replaces your AWS account ID in the login URL, making it easier for users to sign in.

### Step #4: Create IAM Users and User Groups

Set up the intern's login credentials and manage their permissions efficiently.

* **Objective:**
    * Set up a dedicated IAM group for NextWork interns.
    * Set up a dedicated IAM user for your new intern.
* **Key Actions:**
    * In the IAM console, choose "User groups" and "Create group."
    * Name the group: `nextwork-dev-group`
    * Attach the `NextWorkDevEnvironmentPolicy` to this group.
    * Choose "Users" and "Create user."
    * User name: `nextwork-dev-<your_name>`
    * Tick "Provide user access to the AWS Management Console."
    * **Important:** For this project, uncheck "Users must create a new password at next sign-in - Recommended" (in real-world scenarios, always leave this checked).
    * Add the user to the `nextwork-dev-group`.
    * Note down the console sign-in URL, username, and password provided.
* **Concepts Explained:**
    * **IAM User Group:** A collection of IAM users that allows you to manage permissions for multiple users simultaneously by attaching policies to the group.
    * **IAM User:** An entity that represents a person or application that interacts with AWS.

### Step #5: Test Your Intern's Access

Verify that the permissions are set up correctly.

* **Objective:**
    * Log in to AWS using the intern's IAM user.
    * Test the intern's access to your production and development instances.
* **Key Actions:**
    * Open a new incognito/private browser window.
    * Navigate to the Console sign-in URL provided for the IAM user.
    * Log in using the IAM username and password.
    * **Observation:** Note that certain dashboard panels might show "Access denied," demonstrating initial permission limitations.
    * Go to the EC2 console and try to **stop the production instance**: Observe the "not authorized" error banner.
    * Try to **stop the development instance**: Observe the "Success" banner.
* **Learnings:** This step directly demonstrates the effectiveness of the IAM policy in restricting access based on resource tags, proving that the intern user can manage only the development resources.

### 💎 Secret Mission: IAM Policy Simulator (Optional)

For an advanced challenge, explore the IAM Policy Simulator.

* **Objective:** Use the IAM Policy Simulator to test user access in a faster, more efficient way without logging in as the user.
* **Key Benefit:** This tool helps you validate policies and troubleshoot permissions before deploying them.

## Cleanup

**It is crucial to delete all resources created in this project to avoid incurring unexpected AWS charges.**

You should delete the following resources:

* EC2 development instance
* EC2 production instance
* IAM user group (`nextwork-dev-group`)
* IAM user (`nextwork-dev-<your_name>`)
* IAM policy (`NextWorkDevEnvironmentPolicy`)
* Account Alias (`nextwork-alias-<your_name>`)

## Conclusion & Learnings

Congratulations! By completing this project, you have gained valuable hands-on experience in AWS security with IAM. You've successfully learned how to:

* Launch and manage EC2 instances.
* Utilize tagging for resource organization and policy application.
* Create granular IAM policies to control access to resources.
* Set up IAM users and groups for efficient user management.
* Test and verify IAM access permissions.
* Simplify login using AWS account aliases.

This project is a significant milestone in your cloud journey, demonstrating your ability to implement secure access controls in AWS.