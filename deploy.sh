#!/bin/bash
set -e
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip build-essential libssl-dev libffi-dev authbind

sudo id cowrie >/dev/null 2>&1 || sudo adduser --disabled-password --gecos "" cowrie
sudo id honeypot >/dev/null 2>&1 || sudo adduser --disabled-password --gecos "" honeypot
sudo mkdir -p /var/log/honeypot
sudo chown -R honeypot:honeypot /var/log/honeypot

sudo mkdir -p /opt/honeypot-demo
sudo cp -r fakepanel /opt/honeypot-demo/
sudo chown -R honeypot:honeypot /opt/honeypot-demo
sudo -u honeypot python3 -m venv /opt/honeypot-demo/fakepanel/venv
sudo -u honeypot /opt/honeypot-demo/fakepanel/venv/bin/pip install -r /opt/honeypot-demo/fakepanel/requirements.txt

if [ ! -d /home/cowrie/cowrie ]; then
  sudo -u cowrie git clone https://github.com/cowrie/cowrie /home/cowrie/cowrie
fi

sudo -u cowrie python3 -m venv /home/cowrie/cowrie/cowrie-env
sudo -u cowrie /home/cowrie/cowrie/cowrie-env/bin/pip install --upgrade pip
sudo -u cowrie /home/cowrie/cowrie/cowrie-env/bin/pip install -r /home/cowrie/cowrie/requirements.txt

if [ ! -f /home/cowrie/cowrie/etc/cowrie.cfg ]; then
  sudo -u cowrie cp /home/cowrie/cowrie/etc/cowrie.cfg.dist /home/cowrie/cowrie/etc/cowrie.cfg
fi
sudo -u cowrie bash -c 'cat >> /home/cowrie/cowrie/etc/cowrie.cfg << EOF

[output_jsonlog]
enabled = true
logfile = /home/cowrie/cowrie/var/log/cowrie/cowrie.json
EOF'

sudo cp systemd/fakepanel.service /etc/systemd/system/fakepanel.service
sudo cp systemd/cowrie.service /etc/systemd/system/cowrie.service
sudo systemctl daemon-reload
sudo systemctl enable fakepanel
sudo systemctl enable cowrie
sudo systemctl restart fakepanel
sudo systemctl restart cowrie

sudo ufw allow 2222/tcp || true
sudo ufw allow 8443/tcp || true