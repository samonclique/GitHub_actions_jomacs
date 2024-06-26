resource "aws_ssm_parameter" "vpc_id" {
    name  = "/${var.project}/vpc_id"
    type  = "String"
    value = aws_vpc.main.id
    depends_on = [ aws_vpc.main ]
}

resource "aws_ssm_parameter" "app_subnet1_id" {
    name  = "/${var.project}/app_subnet1_id"
    type  = "String"
    value = aws_subnet.app_subnet1.id
    depends_on = [ aws_subnet.app_subnet1 ]
}

resource "aws_ssm_parameter" "app_subnet2_id" {
    name  = "/${var.project}/app_subnet2_id"
    type  = "String"
    value = aws_subnet.app_subnet2.id
    depends_on = [ aws_subnet.app_subnet2 ]
}

resource "aws_ssm_parameter" "db_subnet1_id" {
    name  = "/${var.project}/db_subnet1_id"
    type  = "String"
    value = aws_subnet.db_subnet1.id
    depends_on = [ aws_subnet.db_subnet1 ]
}

resource "aws_ssm_parameter" "db_subnet2_id" {
    name  = "/${var.project}/db_subnet2_id"
    type  = "String"
    value = aws_subnet.db_subnet2.id
    depends_on = [ aws_subnet.db_subnet2 ]
}

resource "aws_ssm_parameter" "web_subnet1_id" {
    name  = "/${var.project}/web_subnet1_id"
    type  = "String"
    value = aws_subnet.web_subnet1.id
    depends_on = [ aws_subnet.web_subnet1 ]
}

resource "aws_ssm_parameter" "web_subnet2_id" {
    name  = "/${var.project}/web_subnet2_id"
    type  = "String"
    value = aws_subnet.web_subnet2.id
    depends_on = [ aws_subnet.web_subnet2 ]
}

