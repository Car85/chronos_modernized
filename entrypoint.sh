#!/bin/bash
set -e  

socat -d -d PTY,link=/tmp/ptyp0,raw,echo=0 PTY,link=/tmp/ttyp0,raw,echo=0 &
socat -d -d PTY,link=/tmp/ptyp1,raw,echo=0 PTY,link=/tmp/ttyp1,raw,echo=0 &
python3 working-sync-server.py /tmp/ttyp0 &  # Usar python3 en lugar de python2

chown pi:pi /tmp/ptyp0
chown pi:pi /tmp/ptyp1
chown -R pi:pi /home/pi

sleep 2
mkdir -p /var/log/gunicorn

echo "Runing Gunicorn"
gunicorn --workers 3 --bind 0.0.0.0:5000 wsgi:app &

echo -e "YES\nt=100" > /tmp/water_in
echo -e "YES\nt=150" > /tmp/water_out

service nginx start
service chronos start

tail -f /dev/null
