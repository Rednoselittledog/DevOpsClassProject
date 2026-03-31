# 1. กำหนดภูมิภาคที่ต้องการ Deploy
variable "aws_region" {
  description = "Region ของ AWS ที่ต้องการสร้าง Resource"
  type        = string
  default     = "ap-southeast-2"
}

# 2. ชื่อกุญแจ SSH (ที่เราสร้างไว้ในข้อ 7.2)
variable "key_name" {
  description = "ชื่อของ Key Pair ใน AWS ที่ใช้สำหรับ SSH เข้าเครื่อง EC2"
  type        = string
  default     = "DevOps-Keys-Pairs"
}

# 3. ขนาดของ Server (Instance Type)
variable "instance_type" {
  description = "ขนาดของ EC2 Instance"
  type        = string
  default     = "m7i-flex.large"
}

# 4. ami
variable "ami" {
  description = "ค่า ami ที่ได้จากการตั้ง m7i-flex.large ใน aws_region ตัวเอง"
  type        = string
  default     = "ami-0c33c6bd24cee108b"
}

# 7. พอร์ตที่แอปพลิเคชันจะรัน
variable "app_port" {
  description = "พอร์ตที่แอปพลิเคชันจะรัน"
  type        = string
  default     = "3000"
}