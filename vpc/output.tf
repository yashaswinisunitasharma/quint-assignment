output "region" {
    value = var.region
}

output "project_name" {
    value = var.project_name
}

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "pub_sub_1a_id" {
    value = aws_subnet.pub_sub_1a.id
}

output "pub_sub_2a_id" {
    value = aws_subnet.pub_sub_2a.id
}

output "igw_id" {
    value = aws_internet_gateway.igw
}

output "SG_id" {
    value = aws_security_group.ec2-SG.id
}
