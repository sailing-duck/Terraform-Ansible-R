resource "aws_key_pair" "ubuntu_auth" {
  key_name = "auth"
  public_key = file("./auth.pub")
}

resource "aws_instance" "ubuntu" {
    instance_type = "t2.micro"
    ami = "ami-080660c9757080771"
    key_name = aws_key_pair.ubuntu_auth.id
    vpc_security_group_ids = [aws_security_group.lewis_ec2_sg.id]
    subnet_id = aws_subnet.lewis_public_subnet[0].id
    root_block_device {
      volume_size = 8
    }

    tags = {
        Name = "unbuntu_for_R"
    }

    provisioner "local-exec" {
      command = "printf '\n${self.public_ip}' >> aws_hosts"
    }

    provisioner "local-exec" {
      when = destroy
      command = "sed -i '/^[0-9]/d' aws_hosts"
    }

}

resource "null_resource" "r_server_install" {
  depends_on = [aws_instance.ubuntu]
  provisioner "local-exec" {
    command = "ansible-playbook -i aws_hosts --key-file ./auth -u ubuntu playbooks/r_server.yml"
  }
}

