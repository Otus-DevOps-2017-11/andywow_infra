#!/bin/bash
set -e

cd /opt
git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install
echo "[Unit]
Description=Puma service
After=syslog.target network.target

[Service]
Type=simple
WorkingDirectory=/opt/reddit
ExecStart=/usr/local/bin/puma

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl start puma
systemctl enable puma
systemctl status puma
