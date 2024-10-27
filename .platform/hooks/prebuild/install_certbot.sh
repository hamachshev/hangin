#!/bin/bash
sudo dnf install python3 augeas-libs -y
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-nginx
sudo ln -sf /opt/certbot/bin/certbot /usr/bin/certbot

# https://5paceman.dev/aws-elastic-beanstalk-certbot/ && https://certbot.eff.org/instructions?ws=nginx&os=pip&tab=standard