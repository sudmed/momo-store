variable "backend_s3_endpoint" {
  type        = string
  description = "Backend s3 endpoint for save TF remote state"
  default     = "storage.yandexcloud.net"
}

variable "s3_bucket_name" {
  type        = string
  description = "Bucket name for save TF remote state"
  default     = "momo-store-terraform-state"
}

variable "s3_bucket_key" {
  type        = string
  description = "Bucket file name for save TF state"
  default     = "dev/terraform.tfstate"
}

variable "s3_access_key" {
  type        = string
  description = "Bucket access key"
  sensitive   = true
}

variable "s3_secret_key" {
  type        = string
  description = "Bucket secret key"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  default     = "b1gvkuni87is2cev03ro"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud folder"
  default     = "b1gp8v55632cik3ud0ro"
}

variable "IAM_token" {
  type        = string
  description = "Yandex IAM token"
  sensitive   = true
}

variable "image_id" {
  type        = string
  description = "Image of the VM"
  default     = "fd81u2vhv3mc49l1ccbb"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
  default     = "e9bhkjni7fseb3tqtjfv"
}

variable "zone" {
  type        = string
  description = "Availability zone"
  default     = "ru-central1-a"
}

variable "master_platform_id" {
  type        = string
  description = "Hardware platform identifier of the VM with master node"
  default     = "standard-v2"
}

variable "master_count" {
  type        = string
  description = "Count of master nodes"
  default     = "1"
}

variable "master_ram" {
  type        = string
  description = "Amout of RAM in master node"
  default     = "4"
}

variable "master_cores" {
  type        = string
  description = "Amout of CPU cores in master node"
  default     = "2"
}

variable "master_core_fraction" {
  type        = string
  description = "Amout of CPU core fraction in master node"
  default     = "20"
}

variable "master_nat" {
  type        = bool
  description = "External IP NAT for master nodes"
  default     = true
}

variable "master_boot_disk_size" {
  type        = string
  description = "Disk size on master node"
  default     = "50"
}

variable "master_serial-port-enable" {
  type        = string
  description = "Serial port enable or not"
  default     = "1"
}


variable "worker_platform_id" {
  type        = string
  description = "Hardware platform identifier of the VM with worker nodes"
  default     = "standard-v2"
}

variable "workers_count" {
  type        = string
  description = "Count of worker nodes"
  default     = "2"
}

variable "workers_ram" {
  type        = string
  description = "Amout of RAM in worker nodes"
  default     = "4"
}

variable "workers_cores" {
  type        = string
  description = "Amout of CPU cores in worker nodes"
  default     = "2"
}

variable "workers_core_fraction" {
  type        = string
  description = "Amout of CPU core fraction in worker nodes"
  default     = "20"
}

variable "worker_nat" {
  type        = bool
  description = "External IP NAT for worker nodes"
  default     = true
}

variable "worker_boot_disk_size" {
  type        = string
  description = "Disk size on master node"
  default     = "50"
}

variable "worker_serial-port-enable" {
  type        = string
  description = "Serial port enable or not"
  default     = "1"
}
