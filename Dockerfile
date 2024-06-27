FROM --platform=linux/arm64/v8 dtcooper/raspberrypi-os:python3.11-bookworm
workdir /home/chronos

run apt-get update -y && apt-get install python3 python3-pip socat cron sqlite3 nginx libssl-dev vim -y
run useradd pi
run mkdir -p /home/pi/chronos_db
# Install Gunicorn and the set up for Python 3.11
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org \
    flask pyserial pymodbus APScheduler==3.6.3 gunicorn==22.0.0 \
    sqlalchemy python-socketio==0.4.1 socketIO_client six==1.15.0 \
    gevent python-engineio==3.11.2 python-socketio==4.4.0 gevent-websocket

copy . .
copy chronos.sql /home/pi/chronos_db/
run python setup.py install
run rm /etc/nginx/sites-enabled/default
run ln -s /etc/nginx/sites-enabled/chronos_conf /etc/nginx/sites-enabled/default
#run /usr/local/bin/uwsgi --ini /etc/uwsgi/apps-enabled/socketio_server.ini --pidfile /var/run/uwsgi/uwsgi-socketio.pid --daemonize /var/log/uwsgi/uwsgi-socketio.log
run chmod +x entrypoint.sh

entrypoint [ "./entrypoint.sh" ]
