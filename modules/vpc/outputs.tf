output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private_subnet.*.id}"
}

output "vpc_public_rt" {
  value = aws_route_table.vpc_public_rt.id
}

output "vpc_private_rt" {
  value = aws_route_table.vpc_private_rt.id
}