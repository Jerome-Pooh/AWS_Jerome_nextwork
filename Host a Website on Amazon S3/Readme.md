# Host a Website on Amazon S3

This project demonstrates how to host a static website using **Amazon S3 (Simple Storage Service)**. The goal is to deploy a simple HTML-based site with public access via an S3 bucket and optionally connect it to a custom domain.

## 🚀 Project Overview

Amazon S3 is a scalable and highly available object storage service. In this project, we:
- Created an S3 bucket named `Jerome-S3-Project` in `ap-southeast-1` (Singapore)
- Enabled static website hosting
- Uploaded `index.html` and assets
- Configured bucket policy for public access
- Verified access using the S3 website endpoint

## 🛠️ Tools and Concepts
- **Amazon S3** – Static website hosting
- **Bucket Policies** – Granting public read access
- **ACL (Access Control Lists)** – Disabled for simplicity
- **Website Endpoints** – Publicly accessible URLs

## 📝 Setup Steps

1. **Create a Bucket**
   - Must be globally unique (e.g., `jerome-s3-project`)
   - Choose a region (e.g., `ap-southeast-1`)

2. **Upload Files**
   - Upload `index.html` and any images/assets

3. **Enable Static Website Hosting**
   - Under **Properties** → **Static website hosting**
   - Set the index document (`index.html`)

4. **Make Files Public**
   - Adjust **Bucket Policy** to allow public read
   - Sample policy:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Sid": "PublicReadGetObject",
           "Effect": "Allow",
           "Principal": "*",
           "Action": "s3:GetObject",
           "Resource": "arn:aws:s3:::your-bucket-name/*"
         }
       ]
     }
     ```

5. **Access via Website Endpoint**
   - Example: `http://your-bucket-name.s3-website-ap-southeast-1.amazonaws.com`

## ✅ Success!
Once configured, the website becomes publicly accessible. This is a simple, cost-effective solution for hosting portfolios, documentation, and static landing pages.

---

