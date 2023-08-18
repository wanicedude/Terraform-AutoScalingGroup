#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
systemctl start httpd
systemctl enable httpd

