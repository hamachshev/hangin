#!/bin/bash
sudo certbot certonly --nginx -n --agree-tos -d $(/opt/elasticbeanstalk/bin/get-config environment -k CERTBOT_DOMAINS) --email $(/opt/elasticbeanstalk/bin/get-config environment -k CERTBOT_EMAIL)
# https://5paceman.dev/aws-elastic-beanstalk-certbot/ && https://certbot.eff.org/instructions?ws=nginx&os=pip&tab=standard