
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "test_vpc"
    }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.public_az[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.private_az[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "custom-igw"
    } 
}

resource "aws_route_table" "name" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "public_route_table"
    }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.name.id
  destination_cidr_block = var.igw_route_destination
  gateway_id         = aws_internet_gateway.name.id
}

resource "aws_route_table_association" "igw_route_association" {
      for_each = toset(aws_subnet.public[*].id)

      subnet_id = each.value
      route_table_id = aws_route_table.name.id
}

resource "aws_eip" "nat" {
  count  = length(var.public_subnets)  # Create one EIP per public subnet
  domain = "vpc"
}

resource "aws_nat_gateway" "regional_nat" {
  vpc_id            = aws_vpc.vpc.id
  availability_mode = var.nat_availability_mode

  # Assigning first EIP to the first AZ
  availability_zone_address {
    allocation_ids    = [aws_eip.nat[0].id]
    availability_zone = var.private_az[0]
  }

  # Assigning second EIP to the second AZ
  availability_zone_address {
    allocation_ids    = [aws_eip.nat[1].id]
    availability_zone = var.private_az[1]
  }
}

resource "aws_route_table" "NAT" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "Nat-route-table"
    }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.NAT.id
  destination_cidr_block = var.nat_route_destination
  nat_gateway_id         = aws_nat_gateway.regional_nat.id
}


resource "aws_route_table_association" "nat_route" {
     for_each = toset(aws_subnet.private[*].id)

     subnet_id = each.value
     route_table_id = aws_route_table.NAT.id
}
