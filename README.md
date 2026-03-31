# DevOps Class Project - Next.js Deployment on AWS EC2

โปรเจคนี้ใช้ Terraform สำหรับการ Deploy แอปพลิเคชัน Next.js ไปยัง AWS EC2 Instance แบบอัตโนมัติ พร้อมกับการตั้งค่า Database, Security Group, และ PM2 สำหรับการรันแอปพลิเคชัน

---

## 📋 สารบัญ

1. [ข้อกำหนดเบื้องต้น](#ข้อกำหนดเบื้องต้น)
2. [การตั้งค่า AWS Account](#การตั้งค่า-aws-account)
3. [การติดตั้ง AWS CLI](#การติดตั้ง-aws-cli)
4. [การติดตั้ง Terraform](#การติดตั้ง-terraform)
5. [การเลือก Region, OS, Instance Type และ AMI](#การเลือก-region-os-instance-type-และ-ami)
6. [การตั้งค่าโปรเจค](#การตั้งค่าโปรเจค)
7. [วิธีการรันโปรเจค](#วิธีการรันโปรเจค)
8. [การตรวจสอบและแก้ไขปัญหา](#การตรวจสอบและแก้ไขปัญหา)
9. [การลบ Resource](#การลบ-resource)

---

## 🔧 ข้อกำหนดเบื้องต้น

- **AWS Account** (Free Tier ก็ใช้ได้)
- **บัตรเครดิต/เดบิต** สำหรับ verify AWS Account
- **คอมพิวเตอร์** ที่รัน macOS, Linux หรือ Windows
- **Terminal/Command Prompt**
- **Internet Connection**

---

## 🌐 การตั้งค่า AWS Account

### ขั้นตอนที่ 1: สมัคร AWS Account

1. ไปที่ [https://aws.amazon.com](https://aws.amazon.com)
2. คลิก **Create an AWS Account**
3. กรอกข้อมูล:
   - Email address
   - Password
   - AWS account name
4. กรอกข้อมูลติดต่อ (Contact Information)
5. กรอกข้อมูลบัตรเครดิต/เดบิต (จะไม่มีการเรียกเก็บเงินถ้าใช้ Free Tier)
6. ยืนยันตัวตนผ่านเบอร์โทรศัพท์
7. เลือกแพลน **Basic Support - Free**
8. รอการ activate บัญชี (อาจใช้เวลา 1-5 นาที)

### ขั้นตอนที่ 2: สร้าง IAM User สำหรับ Terraform

เพื่อความปลอดภัย ไม่ควรใช้ Root Account โดยตรง

1. Login เข้า [AWS Console](https://console.aws.amazon.com)
2. ไปที่ **IAM** (Identity and Access Management)
3. คลิก **Users** > **Add users**
4. ตั้งชื่อ User เช่น `terraform-user`
5. เลือก **Access key - Programmatic access**
6. คลิก **Next: Permissions**
7. เลือก **Attach existing policies directly**
8. เลือก policy ต่อไปนี้:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
9. คลิก **Next: Tags** (ข้ามได้)
10. คลิก **Next: Review**
11. คลิก **Create user**

### ขั้นตอนที่ 3: บันทึก Access Key

⚠️ **สำคัญมาก**: คัดลอกและเก็บข้อมูลนี้ไว้ในที่ปลอดภัย
(ตัวอย่าง key)
```
Access key ID: AKIAIOSFODNN7EXAMPLE
Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**หมายเหตุ**: ข้อมูลนี้จะแสดงเพียงครั้งเดียว หากทำหาย ต้องสร้าง Key ใหม่

---

## 💻 การติดตั้ง AWS CLI

### สำหรับ macOS

#### วิธีที่ 1: ใช้ Homebrew (แนะนำ)

```bash
# ติดตั้ง Homebrew (ถ้ายังไม่มี)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ติดตั้ง AWS CLI
brew install awscli

# ตรวจสอบการติดตั้ง
aws --version
```

#### วิธีที่ 2: ใช้ Installer

```bash
# ดาวน์โหลดและติดตั้ง
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# ตรวจสอบการติดตั้ง
aws --version
```

### สำหรับ Linux (Ubuntu/Debian)

```bash
# อัพเดท package list
sudo apt-get update

# ติดตั้ง dependencies
sudo apt-get install -y unzip curl

# ดาวน์โหลดและติดตั้ง AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# ตรวจสอบการติดตั้ง
aws --version
```

### สำหรับ Windows

1. ดาวน์โหลด [AWS CLI Installer for Windows](https://awscli.amazonaws.com/AWSCLIV2.msi)
2. เปิดไฟล์ `.msi` และทำตามขั้นตอน
3. เปิด Command Prompt หรือ PowerShell
4. ตรวจสอบการติดตั้ง:

```powershell
aws --version
```

### การตั้งค่า AWS CLI

หลังจากติดตั้งเสร็จแล้ว ให้ configure AWS CLI:

```bash
aws configure
```

จะมีการถามข้อมูลดังนี้:

```
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-southeast-2
Default output format [None]: json
```

**คำอธิบาย:**
- **Access Key ID**: คัดลอกจากขั้นตอนที่ 3 ข้างต้น
- **Secret Access Key**: คัดลอกจากขั้นตอนที่ 3 ข้างต้น
- **Default region**: ใส่ `ap-southeast-2` (Sydney) หรือ region ที่ต้องการ
- **Output format**: ใส่ `json`

### ทดสอบการเชื่อมต่อ

```bash
# ทดสอบว่า AWS CLI เชื่อมต่อได้หรือไม่
aws sts get-caller-identity
```

ถ้าสำเร็จ จะได้ output ประมาณนี้:

```json
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

---

## 🔨 การติดตั้ง Terraform

### สำหรับ macOS

```bash
# ใช้ Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# ตรวจสอบการติดตั้ง
terraform --version
```

### สำหรับ Linux (Ubuntu/Debian)

```bash
# เพิ่ม HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# เพิ่ม HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# อัพเดทและติดตั้ง
sudo apt-get update
sudo apt-get install -y terraform

# ตรวจสอบการติดตั้ง
terraform --version
```

### สำหรับ Windows

#### วิธีที่ 1: ใช้ Chocolatey

```powershell
# ติดตั้ง Chocolatey (ถ้ายังไม่มี)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ติดตั้ง Terraform
choco install terraform

# ตรวจสอบการติดตั้ง
terraform --version
```

#### วิธีที่ 2: Manual Installation

1. ดาวน์โหลด Terraform จาก [https://www.terraform.io/downloads](https://www.terraform.io/downloads)
2. แตกไฟล์ ZIP
3. ย้ายไฟล์ `terraform.exe` ไปยังโฟลเดอร์ในระบบ PATH เช่น `C:\Windows\System32`
4. เปิด Command Prompt ใหม่และตรวจสอบ:

```powershell
terraform --version
```

---

## 🌍 การเลือก Region, OS, Instance Type และ AMI

### 1. เลือก AWS Region

Region คือตำแหน่งทางภูมิศาสตร์ของ Data Center ของ AWS

**Region ที่แนะนำสำหรับประเทศไทย:**
- `ap-southeast-1` - Singapore (ใกล้ที่สุด, latency ต่ำ)
- `ap-southeast-2` - Sydney, Australia
- `ap-northeast-1` - Tokyo, Japan

**โปรเจคนี้ใช้:** `ap-southeast-2` (Sydney)

### 2. เลือก Operating System (OS)

**โปรเจคนี้ใช้:** Ubuntu 24.04 LTS (Long Term Support)

**เหตุผลที่เลือก Ubuntu:**
- รองรับการติดตั้ง Node.js ได้ดี
- มี community support เยอะ
- เสถียรและ update security patch สม่ำเสมอ
- Free และ Open Source

### 3. เลือก Instance Type

Instance Type กำหนดขนาดของเครื่อง (CPU, RAM, Network)

**โปรเจคนี้ใช้:** `m7i-flex.large`

**รายละเอียด:**
- **vCPU**: 2 cores
- **RAM**: 8 GiB
- **Network**: Up to 12.5 Gbps
- **ราคา**: ประมาณ $0.12/hour (~$86.4/month)

⚠️ **สำคัญ:** โปรเจคนี้**ต้องใช้ m7i-flex.large เท่านั้น** เนื่องจากการ build Next.js application ต้องใช้ RAM อย่างน้อย 8 GiB หาก instance มี RAM น้อยกว่านี้ (เช่น t3.micro, t3.small, t3.medium) จะทำให้ build ล้มเหลวเพราะ RAM ไม่เพียงพอ

### 4. วิธีหา AMI ID

AMI (Amazon Machine Image) คือ template ของระบบปฏิบัติการ **AMI ID จะต่างกันในแต่ละ Region**

#### วิธีที่ 1: ใช้ AWS Console (แนะนำสำหรับมือใหม่)

1. ไปที่ [AWS EC2 Console](https://console.aws.amazon.com/ec2)
2. เลือก Region ที่ต้องการ (มุมบนขวา) เช่น `ap-southeast-2`
3. คลิก **Launch Instance**
4. ในหน้า **Choose an Amazon Machine Image (AMI)**
5. เลือก **Ubuntu** จาก Quick Start
6. เลือก **Ubuntu Server 24.04 LTS**
7. คัดลอก AMI ID เช่น `ami-0c33c6bd24cee108b`
8. ยกเลิกการสร้าง instance (ยังไม่ต้องสร้างจริง)

#### วิธีที่ 2: ใช้ AWS CLI

```bash
# หา AMI ID ของ Ubuntu 24.04 ใน region ap-southeast-2
aws ec2 describe-images \
  --region ap-southeast-2 \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

**Output ตัวอย่าง:**
```
ami-0c33c6bd24cee108b
```

#### วิธีที่ 3: ดูจาก Ubuntu Cloud Images

ไปที่ [https://cloud-images.ubuntu.com/locator/](https://cloud-images.ubuntu.com/locator/)

1. ค้นหา: `24.04 LTS`
2. เลือก Region: `ap-southeast-2`
3. เลือก Instance Type: `hvm:ebs-ssd` หรือ `hvm:ebs-gp3`
4. คัดลอก AMI ID

### ตารางเปรียบเทียบ AMI ID ตาม Region

| Region | Region Name | Ubuntu 24.04 AMI ID (ตัวอย่าง) |
|--------|-------------|--------------------------------|
| us-east-1 | N. Virginia | ami-0e2c8caa4b6378d8c |
| ap-southeast-1 | Singapore | ami-0497a974f8d5dcef8 |
| ap-southeast-2 | Sydney | ami-0c33c6bd24cee108b |
| ap-northeast-1 | Tokyo | ami-0bba69335379e17f8 |

⚠️ **หมายเหตุ**: AMI ID เปลี่ยนแปลงได้เมื่อมี update ใหม่ ควรตรวจสอบ AMI ID ล่าสุดก่อนใช้งาน

---

## ⚙️ การตั้งค่าโปรเจค

### 1. Clone Repository

```bash
git clone <your-repository-url>
cd projectDevOpps
```

### 2. ตรวจสอบและแก้ไขไฟล์ `variables.tf`

เปิดไฟล์ `variables.tf` และตรวจสอบค่าต่างๆ:

```hcl
# Region ที่ต้องการ Deploy
variable "aws_region" {
  default = "ap-southeast-2"  # เปลี่ยนได้ตามต้องการ
}

# ชื่อ Key Pair สำหรับ SSH
variable "key_name" {
  default = "DevOps-Keys-Pairs"
}

# ขนาดของ Instance
variable "instance_type" {
  default = "m7i-flex.large"  # ห้ามเปลี่ยน! ต้องใช้ instance นี้เท่านั้น
}

# AMI ID ของ Ubuntu 24.04
variable "ami" {
  default = "ami-0c33c6bd24cee108b"  # ต้องตรงกับ Region
}

# พอร์ตที่แอปพลิเคชันรัน
variable "app_port" {
  default = "3000"
}
```

### 3. แก้ไข AMI ID (ถ้าเปลี่ยน Region)

ถ้าคุณเปลี่ยน Region ต้องเปลี่ยน AMI ID ด้วย:

```bash
# หา AMI ID ใหม่สำหรับ region ที่ต้องการ
aws ec2 describe-images \
  --region <your-region> \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

จากนั้นแก้ไขค่า `ami` ใน `variables.tf`

### 4. ตรวจสอบไฟล์ `main.tf`

ไฟล์นี้ประกอบด้วย:
- **Security Group**: เปิด port 22 (SSH), 80 (HTTP), 3000 (Next.js)
- **EC2 Instance**: สร้าง instance Ubuntu พร้อม user-data script
- **User Data Script**: ติดตั้ง Node.js, clone repo, build และรัน Next.js app

---

## 🚀 วิธีการรันโปรเจค

### ขั้นตอนที่ 1: เตรียมไฟล์โปรเจค

```bash
# ตรวจสอบว่าอยู่ในโฟลเดอร์โปรเจค
pwd

# ตรวจสอบว่ามีไฟล์ Terraform ครบ
ls -la
```

ควรจะเห็นไฟล์:
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `.gitignore`

### ขั้นตอนที่ 2: Initialize Terraform

```bash
terraform init
```

**คำสั่งนี้จะ:**
- ดาวน์โหลด AWS Provider plugin
- เตรียม working directory
- สร้างโฟลเดอร์ `.terraform`

**Output ที่คาดหวัง:**
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### ขั้นตอนที่ 3: ตรวจสอบแผนการสร้าง Resource

```bash
terraform plan
```

**คำสั่งนี้จะ:**
- แสดงรายการ resource ที่จะถูกสร้าง
- ไม่สร้าง resource จริง (แค่ preview)

**Output ตัวอย่าง:**
```
Terraform will perform the following actions:

  # aws_instance.nodejs_server will be created
  + resource "aws_instance" "nodejs_server" {
      + ami                          = "ami-0c33c6bd24cee108b"
      + instance_type                = "m7i-flex.large"
      ...
    }

  # aws_key_pair.generated_key will be created
  ...

  # aws_security_group.app_sg will be created
  ...

Plan: 5 to add, 0 to change, 0 to destroy.
```

### ขั้นตอนที่ 4: สร้าง Resource บน AWS

```bash
terraform apply
```

**คำสั่งนี้จะ:**
- แสดงแผนการสร้าง resource
- ถามยืนยัน (พิมพ์ `yes` เพื่อยืนยัน)
- สร้าง resource จริงบน AWS

**ตัวอย่างการรัน:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

พิมพ์ `yes` แล้วกด Enter

**Output เมื่อสำเร็จ:**
```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

app_public_url = "http://3.25.224.220:3000"
instance_public_ip = "3.25.224.220"
```

### ขั้นตอนที่ 5: รอให้ User Data Script ทำงานเสร็จ

⏰ **สำคัญมาก:** หลังจาก `terraform apply` เสร็จแล้ว ต้อง**รออย่างน้อย 5-10 นาที**

**ทำไมต้องรอ:**
1. EC2 Instance ต้อง boot ขึ้นมา (~1-2 นาที)
2. User data script ติดตั้ง Node.js และ dependencies (~2 นาที)
3. Clone repository จาก GitHub (~30 วินาที)
4. รัน `npm install` (~1-2 นาที)
5. รัน `npm run build` (Build Next.js app) (~2-3 นาที)
6. Start app ด้วย PM2 (~30 วินาที)

### ขั้นตอนที่ 6: ทดสอบเปิดเว็บ

หลังจากรอประมาณ 5-10 นาทีแล้ว:

```bash
# คัดลอก URL จาก output
# ตัวอย่าง: http://3.25.224.220:3000
```

เปิด Browser แล้วไปที่ URL ที่ได้

**ถ้าเปิดได้:**
- ✅ แสดงว่า deployment สำเร็จ

**ถ้าเปิดไม่ได้:**
- ⏰ รอเพิ่มอีก 2-3 นาที แล้วลองใหม่
- 🔍 ดูขั้นตอนการแก้ไขปัญหาด้านล่าง

---

## 🔍 การตรวจสอบและแก้ไขปัญหา

### ปัญหาที่ 1: เปิดเว็บไม่ได้ (Connection Timeout)

#### วิธีแก้:

**1. ตรวจสอบว่ารอครบ 5-10 นาทีหรือยัง**

```bash
# ดูเวลาที่ instance ถูกสร้าง
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=NodeJS-App-Server" \
  --query 'Reservations[0].Instances[0].LaunchTime' \
  --output text
```

**2. SSH เข้าไปตรวจสอบสถานะ**

```bash
# ใช้ private key ที่สร้างไว้
chmod 400 DevOps-Keys-Pairs.pem
ssh -i DevOps-Keys-Pairs.pem ubuntu@<your-instance-public-ip>
```

แทนที่ `<your-instance-public-ip>` ด้วย IP ที่ได้จาก output

**3. เช็คว่า user-data script ทำงานเสร็จหรือยัง**

```bash
# เช็คสถานะของ cloud-init
sudo cloud-init status

# ถ้าได้ "status: done" แสดงว่าเสร็จแล้ว
# ถ้าได้ "status: running" แสดงว่ายังทำงานอยู่
```

**4. เช็ค log ของ user-data script**

```bash
# ดู log ทั้งหมด
sudo cat /var/log/user-data.log

# ดู log 50 บรรทัดล่าสุด
sudo tail -50 /var/log/user-data.log

# ค้นหา error
sudo grep -i error /var/log/user-data.log
```

**5. เช็คว่า PM2 รัน Next.js app อยู่หรือไม่**

```bash
# เช็คสถานะ PM2
sudo -u ubuntu pm2 list

# ควรเห็น
# ┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┐
# │ id │ name               │ mode     │ ↺    │ status    │ cpu      │
# │ 0  │ next-app           │ fork     │ 0    │ online    │ 0%       │
# └────┴────────────────────┴──────────┴──────┴───────────┴──────────┘
```

**6. เช็ค logs ของ Next.js app**

```bash
# ดู logs
sudo -u ubuntu pm2 logs next-app --lines 50

# ดู logs แบบ real-time
sudo -u ubuntu pm2 logs next-app
```

**7. เช็คว่า port 3000 เปิดอยู่หรือไม่**

```bash
# เช็ค process ที่ฟัง port 3000
sudo netstat -tlnp | grep 3000

# หรือใช้
sudo lsof -i :3000

# ควรเห็น
# COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# node    1234 ubuntu   21u  IPv6  12345      0t0  TCP *:3000 (LISTEN)
```

### ปัญหาที่ 2: PM2 ไม่ได้รันหรือ app crash

#### วิธีแก้:

```bash
# ไปที่โฟลเดอร์แอป
cd /home/ubuntu/ksrv-version1

# ลอง start manual
sudo -u ubuntu pm2 start npm --name "next-app" -- start

# ถ้า error ให้ลอง build ใหม่
sudo -u ubuntu npm install
sudo -u ubuntu npx prisma generate
sudo -u ubuntu npm run build
sudo -u ubuntu pm2 start npm --name "next-app" -- start

# บันทึกสถานะ PM2
sudo -u ubuntu pm2 save
```

### ปัญหาที่ 3: Build ล้มเหลว

#### วิธีแก้:

```bash
cd /home/ubuntu/ksrv-version1

# เช็คว่า Node.js ติดตั้งสำเร็จหรือไม่
node --version
npm --version

# ลองติดตั้ง dependencies ใหม่
sudo -u ubuntu rm -rf node_modules package-lock.json
sudo -u ubuntu npm install

# ลอง build ใหม่
sudo -u ubuntu npm run build
```

### ปัญหาที่ 4: Security Group ไม่เปิด port 3000

#### วิธีแก้:

```bash
# เช็ค Security Group rules
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=app_sg*" \
  --query 'SecurityGroups[0].IpPermissions' \
  --output json
```

ถ้าไม่มี port 3000 ให้รัน `terraform apply` ใหม่

### ปัญหาที่ 5: Terraform apply ล้มเหลว

#### สาเหตุที่พบบ่อย:

**1. AMI ID ไม่ถูกต้องสำหรับ Region**

```
Error: creating EC2 Instance: InvalidAMIID.NotFound
```

**วิธีแก้:** ตรวจสอบและเปลี่ยน AMI ID ให้ตรงกับ Region

**2. Instance Type ไม่รองรับใน Region**

```
Error: Unsupported instance type 'm7i-flex.large' in region 'us-east-1'
```

**วิธีแก้:** ตรวจสอบว่า Region รองรับ `m7i-flex.large` หรือไม่ ถ้าไม่รองรับให้เปลี่ยน Region

**3. AWS Credentials ไม่ถูกต้อง**

```
Error: error configuring Terraform AWS Provider: no valid credential sources
```

**วิธีแก้:** รัน `aws configure` ใหม่

### ปัญหาที่ 6: Key Pair already exists

#### วิธีแก้:

```bash
# ลบ Key Pair เก่าออก
aws ec2 delete-key-pair --key-name DevOps-Keys-Pairs

# ลบไฟล์ .pem เก่า
rm DevOps-Keys-Pairs.pem

# รัน terraform apply ใหม่
terraform apply
```

### คำสั่งที่มีประโยชน์สำหรับ Debug

```bash
# เช็ค EC2 instances ทั้งหมด
aws ec2 describe-instances --output table

# เช็ค Security Groups
aws ec2 describe-security-groups --output table

# เช็ค Key Pairs
aws ec2 describe-key-pairs --output table

# ดู Terraform state
terraform show

# ดูรายละเอียด resource เฉพาะ
terraform state show aws_instance.nodejs_server
```

---

## 🗑️ การลบ Resource

เมื่อไม่ต้องการใช้งานแล้ว ควรลบ resource ทั้งหมดเพื่อไม่ให้เสียค่าใช้จ่าย

### วิธีที่ 1: ใช้ Terraform (แนะนำ)

```bash
# ลบ resource ทั้งหมดที่สร้างด้วย Terraform
terraform destroy

# จะถามยืนยัน พิมพ์ yes
Enter a value: yes
```

**Output เมื่อสำเร็จ:**
```
Destroy complete! Resources: 5 destroyed.
```

### วิธีที่ 2: ลบ Resource เฉพาะ

```bash
# ลบเฉพาะ EC2 instance
terraform destroy -target=aws_instance.nodejs_server

# ลบเฉพาะ Security Group
terraform destroy -target=aws_security_group.app_sg
```

### วิธีที่ 3: ลบผ่าน AWS Console (กรณีฉุกเฉิน)

1. ไปที่ [AWS EC2 Console](https://console.aws.amazon.com/ec2)
2. คลิก **Instances**
3. เลือก instance ที่ชื่อ `NodeJS-App-Server`
4. คลิก **Instance State** > **Terminate instance**
5. ยืนยัน

**หมายเหตุ:** ควรใช้ `terraform destroy` เพื่อให้ Terraform จัดการ state file อย่างถูกต้อง

---

## 📊 ค่าใช้จ่าย (ประมาณการ)

| Resource | Instance Type | ราคา/ชั่วโมง | ราคา/เดือน (730 ชม.) |
|----------|--------------|-------------|---------------------|
| EC2 | m7i-flex.large | $0.12 | $87.60 |

**หมายเหตุ:**
- โปรเจคนี้ต้องใช้ m7i-flex.large เท่านั้น (ไม่สามารถใช้ instance ที่เล็กกว่าได้)
- ราคาอาจแตกต่างกันตาม Region
- ตรวจสอบราคาล่าสุดได้ที่ [AWS Pricing Calculator](https://calculator.aws/)

---

## 📝 หมายเหตุ

- **Private Key (.pem)**: ไฟล์นี้สำคัญมาก ห้ามแชร์หรือ commit ลง Git
- **Database URL**: มี credentials อยู่ใน .env ไม่ควร commit ลง public repository
- **Security**: ควรจำกัด SSH access (port 22) ให้เฉพาะ IP ของคุณเท่านั้น
- **Backup**: ควร backup terraform state file (`.tfstate`) ไว้ในที่ปลอดภัย

---

## 🔗 ลิงก์ที่เป็นประโยชน์

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EC2 Pricing](https://aws.amazon.com/ec2/pricing/)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/locator/)
- [Next.js Documentation](https://nextjs.org/docs)

---

## ❓ คำถามที่พบบ่อย (FAQ)

### Q: ต้องใช้ Free Tier หรือเปล่า?
A: โปรเจคนี้ไม่สามารถใช้ Free Tier ได้ เพราะต้องใช้ m7i-flex.large ซึ่งมี RAM 8 GiB เท่านั้น instance ที่เล็กกว่านี้จะ build Next.js ไม่สำเร็จ

### Q: สามารถเปลี่ยน Region หลังจาก apply แล้วได้ไหม?
A: ได้ แต่ต้อง destroy resource เดิมก่อน แล้วเปลี่ยนค่าใน `variables.tf` และ apply ใหม่

### Q: ถ้าลืม destroy และเสีย credit ทำไง?
A: ไปที่ AWS Console แล้วลบ resource ที่เหลือด้วยมือ หรือใช้ AWS Cost Explorer ตรวจสอบค่าใช้จ่าย

### Q: ทำไม SSH เข้าไม่ได้?
A: ตรวจสอบว่า:
1. ใช้ private key ที่ถูกต้อง (`DevOps-Keys-Pairs.pem`)
2. ตั้งค่า permission ไฟล์ .pem เป็น 400 (`chmod 400 DevOps-Keys-Pairs.pem`)
3. ใช้ username ที่ถูกต้อง (Ubuntu ใช้ `ubuntu`)

### Q: เปลี่ยน instance type ได้ไหมหลังจาก apply แล้ว?
A: ไม่ได้ โปรเจคนี้ต้องใช้ m7i-flex.large เท่านั้น เพราะต้องการ RAM 8 GiB สำหรับ build Next.js application ห้ามเปลี่ยนเป็น instance ที่เล็กกว่า

---

## 👨‍💻 ผู้จัดทำ

DevOps Class Project - University Year 3

---

## 📄 License

MIT License

---

**สร้างเมื่อ:** 2026-03-31
**อัพเดทล่าสุด:** 2026-03-31
