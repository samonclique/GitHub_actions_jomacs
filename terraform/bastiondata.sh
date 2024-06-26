#!/bin/bash

cat "${tls_private_key.server.private_key_pem}" > /home/ubuntu/success-server.pem
sudo chmod 400 /home/ubuntu/success-server.pem
