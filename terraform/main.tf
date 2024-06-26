# Create VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Create Internet Gateway x Attach to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_ssm_parameter.vpc_id.value

  tags = {
    Name = "${var.project}-igw"
  }
}

# Create Pvt Subnet 1
resource "aws_subnet" "app_subnet1" {
  vpc_id     = aws_ssm_parameter.vpc_id.value
  cidr_block = var.app_subnet1_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "${var.project}-app-subnet1"
  }
}

# Create Pvt Subnet 2
resource "aws_subnet" "app_subnet2" {
  vpc_id     = aws_ssm_parameter.vpc_id.value
  cidr_block = var.app_subnet2_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "${var.project}-app-subnet2"
  }
}

# Create Pvt Subnet 3
resource "aws_subnet" "db_subnet1" {
  vpc_id     = aws_ssm_parameter.vpc_id.value
  cidr_block = var.db_subnet1_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "${var.project}-db-subnet1"
  }
}

# Create Pvt Subnet 4
resource "aws_subnet" "db_subnet2" {
  vpc_id     = aws_ssm_parameter.vpc_id.value
  cidr_block = var.db_subnet2_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "${var.project}-db-subnet2"
  }
}

# Create Pub Subnet 1
resource "aws_subnet" "web_subnet1" {
  vpc_id     = aws_ssm_parameter.vpc_id.value
  cidr_block = var.web_subnet1_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "${var.project}-web-subnet1"
  }
}

# Create Pub Subnet 2
resource "aws_subnet" "web_subnet2" {
  vpc_id     = aws_ssm_parameter.vpc_id.value
  cidr_block = var.web_subnet2_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "${var.project}-web-subnet2"
  }
}

# Allocate EIP
resource "aws_eip" "eip" {
  domain   = "vpc"
  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    Name = "${var.project}-EIP"
  }
}

# Create NGW
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_ssm_parameter.web_subnet1_id.value
  depends_on = [ aws_eip.eip ]

  tags = {
    Name = "${var.project}-ngw"
  }
}

# Create Public RTB
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_ssm_parameter.vpc_id.value
  depends_on = [ aws_internet_gateway.igw ]
  # Add Routes
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-pub-rtb"
  }
}

# Attach RTB to Public Subnet 1
resource "aws_route_table_association" "web_subnet1" {
  subnet_id      = aws_ssm_parameter.web_subnet1_id.value
  route_table_id = aws_route_table.public_rtb.id
  depends_on = [ aws_subnet.web_subnet1 ]
}

# Attach RTB to Public Subnet 2
resource "aws_route_table_association" "web_subnet2" {
  subnet_id      = aws_ssm_parameter.web_subnet2_id.value
  route_table_id = aws_route_table.public_rtb.id
  depends_on = [ aws_subnet.web_subnet2 ]
}

# Create Pvt RTB
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_ssm_parameter.vpc_id.value
  depends_on = [ aws_nat_gateway.ngw ]
  # Add Routes
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${var.project}-pvt-rtb"
  }
}

# Attach to App-Subnet1
resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_ssm_parameter.app_subnet1_id.value
  route_table_id = aws_route_table.private_rtb.id
  depends_on = [ aws_subnet.app_subnet1 ]
}

# Attach to pvt Subnet2
resource "aws_route_table_association" "app_subnet2" {
  subnet_id      = aws_ssm_parameter.app_subnet2_id.value
  route_table_id = aws_route_table.private_rtb.id
  depends_on = [ aws_subnet.app_subnet2 ]
}

# Attach to pvt Subnet3
resource "aws_route_table_association" "db_subnet1" {
  subnet_id      = aws_ssm_parameter.db_subnet1_id.value
  route_table_id = aws_route_table.private_rtb.id
  depends_on = [ aws_subnet.db_subnet1 ]
}

# Attach to pvt Subnet4
resource "aws_route_table_association" "db_subnet2" {
  subnet_id      = aws_ssm_parameter.db_subnet2_id.value
  route_table_id = aws_route_table.private_rtb.id
  depends_on = [ aws_subnet.db_subnet2 ]
}


# Create SG for ELB
resource "aws_security_group" "web_elb_sg" {
  name        = "${var.project}-web-elb-sg"
  description = "Security group for ELB"
  vpc_id      = aws_ssm_parameter.vpc_id.value
  depends_on = [ aws_vpc.main ]
  tags = {
      Name = "${var.project}-Web-ELB-SG"
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
  } 

  ingress {
    from_port       = var.ssh-port
    to_port         = var.ssh-port
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create SG for ASG
resource "aws_security_group" "asg_sg" {
  name        = "${var.project}-asg-sg"
  description = "Security group for ASG"
  vpc_id      = aws_ssm_parameter.vpc_id.value
  depends_on = [ aws_vpc.main ]
  tags = {
      Name = "${var.project}-ASG-SG"
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_elb_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_elb_sg.id]
  }
}

# Create SG for DB Server
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-db-sg"
  description = "Security group for DB"
  vpc_id      = aws_ssm_parameter.vpc_id.value
  depends_on = [ aws_vpc.main ]
  tags = {
      Name = "${var.project}-DB-SG"
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.asg_sg.id]
  }
}

########################################################################
# Generate Bastion Public Key
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate Bastion Public Key
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a bastion key pair
resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.project}-bastionkp" 
  public_key = tls_private_key.bastion.public_key_openssh
}

# Create a server key pair
resource "aws_key_pair" "server_key" {
  key_name   = "${var.project}-serverkp"
  public_key = tls_private_key.server.public_key_openssh
}

# Save the bastion pem file as a local file
resource "local_file" "bastion_pem" {
    content         = tls_private_key.bastion.private_key_pem
    filename        = "${path.module}/success-bastion.pem"
    file_permission = "0600"
    }

# Save server the pem file as a local file
resource "local_file" "server_pem" {
    content         = tls_private_key.server.private_key_pem
    filename        = "${path.module}/success-server.pem"
    file_permission = "0600"
    }

###################################################################


# Create Bastion Host
resource "aws_instance" "jump" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_elb_sg.id]
  subnet_id = aws_ssm_parameter.web_subnet1_id.value
  key_name = aws_key_pair.bastion_key.key_name
  # user_data     = filebase64("${path.module}/bastiondata.sh")
  associate_public_ip_address = true

  tags = {
    Name = "${var.project}-Bastion-Host"
  }
}


# Create Subnet Group
resource "aws_db_subnet_group" "dbsubnetgrp" {
  name       = "dbsubnetgroup"
  subnet_ids = [aws_ssm_parameter.db_subnet1_id.value, aws_ssm_parameter.db_subnet2_id.value]

  tags = {
    Name = "Success DB Subnet Grp"
  }
}

resource "aws_secretsmanager_secret" "db_creds" {
  name = "my-db-secret"
}

resource "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id = aws_secretsmanager_secret.db_creds.name
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)

  depends_on = [aws_secretsmanager_secret_version.db_creds_version]
}

# Create RDS
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  db_name              = "successdb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = local.db_creds.username
  password             = local.db_creds.password
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.dbsubnetgrp.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible = false

  depends_on = [aws_secretsmanager_secret_version.db_creds_version]

  tags = {
    Name = "successdatabase"
  }
}

# Create launch Template
resource "aws_launch_template" "app-lt" {
  name_prefix   = "success-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data     = filebase64("${path.module}/userdata.sh")
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  key_name = aws_key_pair.server_key.key_name

  tags = {
    Name = "${var.project}-lt"
  }
}

# Create ASG
resource "aws_autoscaling_group" "app-asg" {
  name                = "${var.project}-App-asg"
  desired_capacity    = "2"
  max_size            = "2"
  min_size            = "2"
  depends_on = [ aws_launch_template.app-lt ]
  target_group_arns   = [aws_lb_target_group.app-tg.arn]
  vpc_zone_identifier = [aws_ssm_parameter.app_subnet1_id.value, aws_ssm_parameter.app_subnet2_id.value]
  launch_template {
    id = aws_launch_template.app-lt.id
  }
  tag {
    key                 = "Name"
    value               = "${var.project}-App-server"
    propagate_at_launch = true
  }
}

# CREATE ELB
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  internal           = false
  name = "success-alb"
  subnet_mapping {
    subnet_id     = aws_ssm_parameter.web_subnet1_id.value
  }
  subnet_mapping {
    subnet_id     = aws_ssm_parameter.web_subnet2_id.value
  }
  security_groups    = [aws_security_group.web_elb_sg.id]
  depends_on         = [aws_lb_target_group.app-tg]
  tags = {
    Name = "${var.project}-app-alb"
  }
}

# Attach a target group to the ALB
resource "aws_lb_target_group" "app-tg" {
  name     = "success-tg"
  port     = 80
  vpc_id   = aws_ssm_parameter.vpc_id.value
  protocol = "HTTP"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create a listener for the ALB
resource "aws_lb_listener" "alb-listener" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.app-tg]
}