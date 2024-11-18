#!/bin/bash

sudo aws s3api get-object --bucket $(/opt/elasticbeanstalk/bin/get-config environment -k S3_APPLICATION_BUCKET)  --key $(/opt/elasticbeanstalk/bin/get-config environment -k APNS_AUTHKEY) /var/app/current/$(/opt/elasticbeanstalk/bin/get-config environment -k APNS_AUTHKEY)