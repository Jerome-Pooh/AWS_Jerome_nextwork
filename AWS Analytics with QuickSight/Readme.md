# 📊 AWS Analytics with QuickSight

Welcome to the **AWS Analytics QuickSight** project by NextWork! This guided, step-by-step tutorial walks you through uploading data to Amazon S3, connecting it to Amazon QuickSight, and building a dynamic dashboard using real Netflix dataset.

---

## 🌟 Project Objective

Build a cloud-based, interactive dashboard that analyzes Netflix data using AWS services. You will:

* Upload `netflix_titles.csv` and `manifest.json` to Amazon S3
* Connect this data source to Amazon QuickSight
* Create insightful visualizations
* Publish and export your dashboard
* Learn how to clean up all resources to avoid charges

---

## 🔧 Tools & Services Used

* **Amazon S3** – For storing CSV and manifest files
* **Amazon QuickSight** – For business intelligence and data visualization
* **manifest.json** – Tells QuickSight how to interpret the dataset
* **NextWork.org** – Your learning community and resource hub

---

## 🔺 Step-by-Step Setup

### 1. 📂 Upload Dataset to S3

1. Log into your AWS account
2. Go to the S3 service
3. Create a bucket (e.g. `nextwork-quicksight-project-<yourname>`) in your preferred region
4. Upload:

   * `netflix_titles.csv`
   * `manifest.json`
5. Open `manifest.json` in a text editor and update the file path:

   ```json
   "url": "s3://nextwork-quicksight-project-<yourname>/netflix_titles.csv"
   ```
6. Re-upload the updated `manifest.json` to your bucket (it will overwrite the previous file)

### 2. 💡 Set Up Amazon QuickSight

1. Open QuickSight from the AWS Console
2. Sign up for a **Free Trial (Enterprise Edition)**
3. Use the **same region** as your S3 bucket
4. Provide an account name: `nextwork-quicksight-<yourname>`
5. Grant access to your S3 bucket
6. ❌ **Uncheck** the *Paginated Reports* box to avoid extra charges
7. Finish the setup

### 3. 🔗 Connect Data in QuickSight

1. Go to **Datasets** > **New dataset** > **S3**
2. Name your source: `kaggle-netflix-data`
3. Paste the S3 URI of your `manifest.json`
4. Click **Connect** and wait for import success

---

## 📈 Create Visualizations

Once the data is connected:

* Use fields like `release_year`, `type`, `date_added`, and `listed_in`
* Try different visuals:

  * Bar chart for content released per year
  * Donut chart for content types
  * Table for TV shows vs movies
  * Line graph for additions over time

### 🔮 Sample Questions to Answer

* What year had the most releases?
* What genres are most common?
* On what date was the most content added?
* How many thrillers were added after 2015?

Create multiple visuals and arrange them into a dashboard layout.

---

## 🌟 Publish & Export Your Dashboard

1. Add titles to all charts
2. Click **Publish** to make your dashboard public
3. Click **Export > PDF** to download your report

---

## 🚨 Resource Cleanup (Very Important!)

### Delete QuickSight Account:

* Go to your profile > **Manage QuickSight** > **Account Settings**
* Scroll down and select **Delete account**

### Delete S3 Bucket:

* Empty the bucket contents first
* Then delete the bucket itself

This ensures no surprise AWS charges after the project.

---

## ✅ What You Accomplished

* 📦 Stored and managed data on S3
* 🔗 Integrated QuickSight with S3 using manifest.json
* 🔢 Built multiple visualizations and a published dashboard
* ♻️ Learned best practices for cost management and resource cleanup

Congrats on completing the AWS Analytics with QuickSight project! 🌟
