resource "aws_instance" "my-ec2" {
  ami                         = "ami-005fc0f236362e99f"         # ubuntu-22.04
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-08a8a3036b7808569"      # Subnet ID for EC2 instance
  key_name                    = "test3"
  vpc_security_group_ids      = [aws_security_group.my-sg.id] # Assign EC2 security group
  associate_public_ip_address = true
  iam_instance_profile = "tf_maaz_role"

  tags = {
    Name = "my-ec2"
  }

    user_data = base64encode(file("${path.module}/userdata/website.sh"))

    // if we do not mention our ec2 instance will still be created with default instance.
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

}

resource "aws_instance" "my-ec2-al" {
  ami                         = "ami-0453ec754f44f9a4a"         # amazon-linux
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-08a8a3036b7808569"      # Subnet ID for EC2 instance
  key_name                    = "test3"
  vpc_security_group_ids      = [aws_security_group.my-sg.id]   # Assign EC2 security group
  associate_public_ip_address = true
  iam_instance_profile = "tf_maaz_role"

  tags = {
    Name = "my-ec2-al"
  }

    user_data = base64encode(file("${path.module}/userdata/websiteAL.sh"))

    // if we do not mention our ec2 instance will still be created with default instance.
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}
