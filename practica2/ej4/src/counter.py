import time
import redis
import subprocess
import socket
import os
from flask import Flask
from flask import request
from markupsafe import Markup
from flask import render_template

app = Flask(__name__)
redis_host = 'redis'
cache = redis.Redis(host=redis_host, port=6379)
error = None

def get_hit_count():
    global error
    retries = 2
    redis_result = True

    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                error = str(exc)
                return -1
            retries -= 1
            time.sleep(0.5)

def get_ip():
    global server_ip
    try:
        addr_info = socket.getaddrinfo(socket.gethostname(), None)
        ips = [info[4][0] for info in addr_info if ":" not in info[4][0]]
        
        for ip in ips:
            if ip.startswith("10.0.1."):
                server_ip = ip
                return server_ip
        
        for ip in ips:
            if ip.startswith("10.0.0."):
                server_ip = ip
                return server_ip

        for ip in ips:
            if not ip.startswith("127.") and not ip.startswith("172."):
                server_ip = ip
                return server_ip
        
        server_ip = ips[0] if ips else "127.0.0.1"
    except Exception:
        server_ip = "127.0.0.1"
    
    return server_ip
    
server_ip = get_ip()

@app.route('/')
def index():
    global server_ip
    client_ip = request.remote_addr
    counter = get_hit_count()
    server_hostname = os.uname()[1]

    if counter == -1:
        height = '355px'
        result = Markup('<span style="color: red;">FAILED</span><p><span style="color: red;">{}</span>').format(error)
        counter = Markup('<span style="color: red;">N/A</span>')
    else:
        height = '330px'
        result = Markup('<span style="color: green;">PASSED</span>')
        count = counter
        counter = Markup('<span style="color: green;">{}</span>').format(count)

    return render_template('index.html', redis_host=redis_host, counter=counter, result=result, client_ip=client_ip, server_ip=server_ip, server_hostname=server_hostname)
