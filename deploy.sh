#!/bin/bash
set -e
sudo apt update
sudo apt-get install python3-pip python3-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind

sudo adduser --disabled-password --gecos "" cowrie
sudo adduser --disabled-password --gecos "" honeypot
sudo -u cowrie mkdir -p /home/cowrie/cowrie
sudo mkdir -p /var/log/honeypot
sudo chown -R honeypot:honeypot /var/log/honeypot

sudo mkdir -p /opt/honeypot-demo
sudo cp -r fakepanel /opt/honeypot-demo/
sudo chown -R honeypot:honeypot /opt/honeypot-demo
sudo -u honeypot python3 -m venv /opt/honeypot-demo/fakepanel/venv
sudo -u honeypot /opt/honeypot-demo/fakepanel/venv/bin/pip install -r /opt/honeypot-demo/fakepanel/requirements.txt

sudo -u cowrie bash -c '
cd /home/cowrie/cowrie
python3 -m venv cowrie-env
source cowrie-env/bin/activate
python -m pip install --upgrade pip
python -m pip install cowrie

if [ ! -f etc/cowrie.cfg ]; then
  cowrie init
fi
'

# [output_jsonlog]
# enabled = true
# logfile = /home/cowrie/cowrie/var/log/cowrie/cowrie.json
# EOF'
#sudo -u cowrie /home/cowrie/cowrie/cowrie-env/bin/cowrie start
sudo cp systemd/fakepanel.service /etc/systemd/system/fakepanel.service
sudo cp systemd/cowrie.service /etc/systemd/system/cowrie.service
sudo systemctl daemon-reload
sudo systemctl enable fakepanel
sudo systemctl enable cowrie
sudo systemctl restart fakepanel
sudo systemctl restart cowrie

sudo ufw allow 2222/tcp || true
sudo ufw allow 8443/tcp || true