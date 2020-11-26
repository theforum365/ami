#!/usr/bin/env bash

sudo amazon-linux-extras install nginx1
sudo amazon-linux-extras enable php7.4

sudo yum update -y

sudo yum install -y git jq nc


