#!/bin/bash
set -e

cd /opt
git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install
mv /tmp/puma.service /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl start puma
systemctl enable puma
systemctl status puma
