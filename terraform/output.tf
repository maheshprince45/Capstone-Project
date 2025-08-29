output "vpc_id"            { value = aws_vpc.main.id }
output "public_subnet_id"  { value = aws_subnet.public.id }
output "security_group_id" { value = aws_security_group.sg.id }
output "ec2_public_ip"     { value = aws_instance.ubuntu_host.public_ip }
