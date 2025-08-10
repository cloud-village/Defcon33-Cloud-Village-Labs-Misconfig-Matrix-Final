# Top 50 AWS Misconfigurations - Lab Deployment
# This Terraform script intentionally provisions insecure AWS resources for educational purposes only.

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-west-2"
}

# 1. Create IAM user without MFA
resource "aws_iam_user" "no_mfa_user" {
  name = "no-mfa-user"
}

resource "aws_iam_access_key" "no_mfa_key" {
  user = aws_iam_user.no_mfa_user.name
}

# 2. Create root-like access with access key (for simulation)
resource "aws_iam_user" "root_like" {
  name = "sim-root-user"
  path = "/"
}

resource "aws_iam_user_policy_attachment" "root_like_policy" {
  user       = aws_iam_user.root_like.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "root_like_key" {
  user = aws_iam_user.root_like.name
}



# 4. Security group open to 0.0.0.0/0 for all ports
resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Create VPC and subnet
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "lab_subnet" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

# 6. EC2 instance with public IP and open SSH
resource "aws_instance" "open_ssh_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.lab_subnet.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.open_sg.name]

  tags = {
    Name = "OpenSSHInstance"
  }
}


# 8. IAM policy allowing wildcards
resource "aws_iam_policy" "wildcard_policy" {
  name   = "wildcard-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

# Attach to user
resource "aws_iam_user_policy_attachment" "wildcard_attach" {
  user       = aws_iam_user.no_mfa_user.name
  policy_arn = aws_iam_policy.wildcard_policy.arn
}

# 9. S3 bucket without versioning
resource "aws_s3_bucket" "no_versioning" {
  bucket = "no-versioning-bucket"
  acl    = "private"
  force_destroy = true
}

# 10. CloudTrail not enabled (simulated by omission)
# Skipping CloudTrail creation

# 11. Unrestricted outbound security group
resource "aws_security_group" "open_outbound" {
  name        = "open-outbound"
  description = "All outbound traffic allowed"
  vpc_id      = aws_vpc.lab_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 12. Create an S3 bucket without logging
resource "aws_s3_bucket" "no_logging" {
  bucket = "nologging-bucket"
  acl    = "private"
  force_destroy = true
}

# 13. IAM group with full access
resource "aws_iam_group" "admin_group" {
  name = "admin-group"
}

resource "aws_iam_group_policy_attachment" "admin_group_policy" {
  group      = aws_iam_group.admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}



# 15. Password policy with low requirements
resource "aws_iam_account_password_policy" "weak_policy" {
  minimum_password_length        = 6
  require_uppercase_characters  = false
  require_lowercase_characters  = false
  require_symbols                = false
  require_numbers                = false
  allow_users_to_change_password = true
  max_password_age               = 0
}

# 16. IAM role with trust to everyone
resource "aws_iam_role" "open_trust_role" {
  name = "open-trust-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 17. IAM policy with wildcard resource
resource "aws_iam_policy" "wildcard_resource" {
  name   = "wildcard-resource"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "*"
      }
    ]
  })
}

# 18. EC2 instance without tags
resource "aws_instance" "untagged_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.lab_subnet.id
}

# 19. RDS instance with public accessibility
resource "aws_db_instance" "public_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "password123"
  publicly_accessible  = true
  skip_final_snapshot  = true
}

# 20. Access key never rotated (simulated with creation only)
# Key created above, never rotated

# 21. IAM policy that allows resource deletion
resource "aws_iam_policy" "delete_policy" {
  name   = "delete-resources"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["ec2:TerminateInstances"],
        Resource = "*"
      }
    ]
  })
}

# 22. S3 bucket with no encryption
resource "aws_s3_bucket" "unencrypted_bucket" {
  bucket = "unencrypted-bucket"
  acl    = "private"
  force_destroy = true
}

# 23. IAM user attached to multiple conflicting policies
resource "aws_iam_user" "conflict_user" {
  name = "conflict-user"
}

resource "aws_iam_user_policy_attachment" "conflict_attach_1" {
  user       = aws_iam_user.conflict_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "conflict_attach_2" {
  user       = aws_iam_user.conflict_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 24. No NACL restrictions in VPC
resource "aws_network_acl" "open_nacl" {
  vpc_id = aws_vpc.lab_vpc.id
  subnet_ids = [aws_subnet.lab_subnet.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}



# 26. IAM inline policy with unrestricted access
resource "aws_iam_user_policy" "inline_all" {
  name = "inline-all"
  user = aws_iam_user.conflict_user.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      }
    ]
  })
}


# 28. SNS topic with public subscribe permission
resource "aws_sns_topic" "public_topic" {
  name = "public-topic"
}

resource "aws_sns_topic_policy" "public_subscribe" {
  arn    = aws_sns_topic.public_topic.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAll",
        Effect = "Allow",
        Principal = "*",
        Action   = "SNS:Subscribe",
        Resource = aws_sns_topic.public_topic.arn
      }
    ]
  })
}

# 29. KMS key with wide key policy
resource "aws_kms_key" "wide_key" {
  description = "Wide access KMS key"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "kms:*",
        Resource = "*"
      }
    ]
  })
}

# 30. IAM role without permissions boundary
resource "aws_iam_role" "no_boundary" {
  name = "no-boundary-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

