import socket
import threading
import resource
import signal
import sys
import os
import time
import logging
from prometheus_client import start_http_server, Counter
from colorama import init

# Initialize colorama
init()

# Configure logging
log_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

console_handler = logging.StreamHandler(sys.stdout)
console_handler.setFormatter(log_formatter)

file_handler = logging.FileHandler('/var/log/simulate_ports.log')  # Adjust the path as needed
file_handler.setFormatter(log_formatter)

logging.basicConfig(level=logging.INFO, handlers=[console_handler, file_handler])

# Define versions and their typical responses with associated CVEs
server_versions = {
    22: "OpenSSH_8.9p1",       # CVE-2022-3095: Remote code execution
    25: "Postfix 3.6.1",       # CVE-2021-26318: Remote code execution
    80: "Apache/2.4.51",      # CVE-2021-22905: Remote code execution
    443: "nginx/1.21.6",       # CVE-2022-4174: Remote code execution
    123: "ntpd 4.2.8p15",      # CVE-2020-25839: Denial of Service
    3128: "Squid/4.12",        # CVE-2021-20207: Remote code execution
    8080: "Squid/4.12",        # CVE-2021-20207: Remote code execution
    5900: "TigerVNC 1.11.0",   # CVE-2021-22916: Remote code execution
}

# Define a mapping of ports to service names
port_service_names = {
    22: "ssh",
    25: "smtp",
    80: "http",
    443: "https",
    123: "ntp",
    3128: "squid-http",
    8080: "squid-http",
    5900: "vnc",  # VNC service
}

# Define CVE mappings for colors
cve_info = {
    22: ("CVE-2022-3095", "Remote Code Execution"),
    25: ("CVE-2021-26318", "Remote Code Execution"),
    80: ("CVE-2021-22905", "Remote Code Execution"),
    443: ("CVE-2022-4174", "Remote Code Execution"),
    123: ("CVE-2020-25839", "Denial of Service"),
    3128: ("CVE-2021-20207", "Remote Code Execution"),
    8080: ("CVE-2021-20207", "Remote Code Execution"),
    5900: ("CVE-2021-22916", "Remote Code Execution"),  # CVE info for VNC
}

# List to keep track of open sockets for clean shutdown
sockets = []

# Create Prometheus counters for each port
hit_counters = {port: Counter(f'port_{port}_hits', f'Number of hits for port {port}') for port in port_service_names.keys()}

def simulate_service(port):
    version = server_versions.get(port, "Unknown")
    service_name = port_service_names.get(port, "Unknown")
    cve_id, cve_type = cve_info.get(port, ("N/A", "N/A"))

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  # Allow reuse of local addresses
    s.bind(('', port))
    s.listen()
    sockets.append(s)  # Add to sockets list for cleanup

    # Log that the port is open
    message = (f'Listening on port {port} '
               f'as {service_name} '
               f'({version}, CVE: {cve_id} ({cve_type}))')
    logging.info(message)

    while True:
        try:
            conn, addr = s.accept()
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
            # Log details of the new connection
            conn_message = (f'{timestamp} - Connection from {addr[0]}:{addr[1]} '
                            f'on port {port}')
            logging.info(conn_message)
            
            # Increment the hit counter for this port
            hit_counters[port].inc()

            with conn:
                # Simulate responses based on port
                if port == 22:
                    # Mimic SSH response with a real version format
                    response = (
                        b"SSH-2.0-" +
                        version.encode('utf-8') +
                        b"\r\n"
                    )
                elif port == 25:
                    # Mimic SMTP response with a more accurate version format
                    response = (
                        b"220 localhost ESMTP " +
                        version.encode('utf-8') +
                        b"\r\n"
                    )
                elif port == 80 or port == 443:
                    # Simulate HTTP/HTTPS responses
                    response = (f"HTTP/1.1 200 OK\r\n"
                                f"Server: {version}\r\n"
                                f"\r\n").encode('utf-8')
                elif port == 123:
                    # Simulate NTP response
                    response = f"NTP {version} Server Ready\r\n".encode('utf-8')
                elif port == 3128 or port == 8080:
                    # Simulate Squid HTTP/Proxy response
                    response = (f"HTTP/1.1 200 OK\r\n"
                                f"Server: {version}\r\n"
                                f"\r\n").encode('utf-8')
                elif port == 5900:
                    # Simulate VNC response (generic VNC greeting)
                    response = (b"RFB 003.008\n")  # Correct VNC greeting

                conn.sendall(response)
        except Exception as e:
            logging.error(f"Error on port {port}: {e}")

def signal_handler(sig, frame):
    logging.info('Interrupt received, shutting down...')
    for s in sockets:
        s.close()  # Close all open sockets
    sys.exit(0)

def daemonize():
    """Daemonize the process."""
    try:
        pid = os.fork()
        if pid > 0:
            # Exit the parent process
            sys.exit(0)
    except OSError as e:
        logging.error(f"Fork #1 failed: {e}")
        sys.exit(1)

    # Decouple from parent environment
    os.setsid()
    os.umask(0)
    try:
        pid = os.fork()
        if pid > 0:
            # Exit the second parent process
            sys.exit(0)
    except OSError as e:
        logging.error(f"Fork #2 failed: {e}")
        sys.exit(1)

    # Redirect standard file descriptors
    sys.stdin.close()
    sys.stdout.close()
    sys.stderr.close()
    sys.stdin = open(os.devnull, 'r')
    sys.stdout = open('/dev/null', 'w')
    sys.stderr = open('/dev/null', 'w')

def main():
    # Register the signal handler for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)

    # Start Prometheus metrics server
    start_http_server(8000)  # Port for Prometheus to scrape metrics

    # Parse arguments
    if '--daemon' in sys.argv:
        daemonize()

    # Increase the maximum number of open file descriptors
    resource.setrlimit(resource.RLIMIT_NOFILE, (65536, 65536))

    ports = list(port_service_names.keys())
    threads = []
    for port in ports:
        thread = threading.Thread(target=simulate_service, args=(port,))
        thread.start()
        threads.append(thread)

    for thread in threads:
        thread.join()

if __name__ == '__main__':
    main()

