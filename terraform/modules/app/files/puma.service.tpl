[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/reddit
Environment=DATABASE_URL=${db_url}
ExecStart=/bin/bash -lc 'puma -b tcp://0.0.0.0:${app_port}'
Restart=always

[Install]
WantedBy=multi-user.target
