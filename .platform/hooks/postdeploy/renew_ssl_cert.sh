#!/bin/bash
echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
# https://5paceman.dev/aws-elastic-beanstalk-certbot/ && https://certbot.eff.org/instructions?ws=nginx&os=pip&tab=standard