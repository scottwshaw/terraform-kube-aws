/*
  Kube Nodes
*/
resource "aws_security_group" "master" {
    name = "vpc_kube"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
/*
  kube api server port
*/
    ingress {
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
/*
  ssh port
*/
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  //
  //so workers can contact api server 
  //
  egress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

    tags = {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "master" {
  //  ami = "${lookup(var.amis, var.aws_region)}"
  //  ami = "ami-000c2343cf03d7fd7"
  ami = "ami-0390bc3cc44fc4a9f" // This is the ami I created with Packer
  availability_zone = "ap-southeast-2a"
  instance_type = "t2.medium"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.master.id}"]
  subnet_id = "${aws_subnet.ap-southeast-2a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false
/*
  provisioner "remote-exec" {
    script = "init-kube-master.sh"
    connection {
      host = "${self.public_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(var.aws_key_path)}"
    }
  }
*/
  tags = {
    Name = "Kube Master"
  }
}

resource "aws_instance" "worker1" {
  //    ami = "${lookup(var.amis, var.aws_region)}"
  //ami = "ami-0390bc3cc44fc4a9f" // This is the ami I created with Packer
  ami = "ami-022514100ec2a53f8" // This is the worker ami I created with Packer
  availability_zone = "ap-southeast-2a"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.master.id}"]
  subnet_id = "${aws_subnet.ap-southeast-2a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false
  
  tags = {
    Name = "Kube Worker 1"
  }
} 

resource "aws_instance" "worker2" {
  //  ami = "${lookup(var.amis, var.aws_region)}"
  // ami = "ami-0390bc3cc44fc4a9f" // This is the ami I created with Packer
  ami = "ami-022514100ec2a53f8" // This is the worker ami I created with Packer
  availability_zone = "ap-southeast-2a"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.master.id}"]
  subnet_id = "${aws_subnet.ap-southeast-2a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false 
  tags = {
    Name = "Kube Worker 2"
  }
}

resource "aws_eip" "master" {
    instance = "${aws_instance.master.id}"
    vpc = true
}
