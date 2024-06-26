#!/bin/bash

# Update package list
sudo apt update -y

# Install and start Nginx
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Install and start MySQL server
# sudo apt install mysql-server -y
# sudo systemctl enable mysql
# sudo systemctl start mysql

# Install unzip
sudo apt install unzip -y

# Install MySQL client
sudo apt install mysql-client -y

# Copy Website files
curl https://www.tooplate.com/zip-templates/2136_kool_form_pack.zip --output 2136_kool_form_pack.zip
unzip 2136_kool_form_pack.zip
sudo rm /var/www/html/*
sudo cp -r 2136_kool_form_pack/* /var/www/html/
sudo rm -rf 2136_kool_form_pack.zip 2136_kool_form_pack
sudo systemctl restart nginx

# echo "<!-- HTML Codes by Quackit.com -->
# <!DOCTYPE html>
# <title>Text Example</title>
# <style>
# div.container {
# background-color: #ffffff;
# }
# div.container p {
# text-align: center;
# font-family: Helvetica;
# font-size: 14px;
# font-style: normal;
# font-weight: bold;
# text-decoration: blink;
# text-transform: capitalize;
# color: #000000;
# background-color: #ffffff;
# }
# </style>

# <div class="container">
# <h1>We Did This With Terraform.</h1>
# <p>Na We Dey Run Am!</p>
# </div>" > /var/www/html/index.html
