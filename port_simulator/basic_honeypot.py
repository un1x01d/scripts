import socket
import threading
import resource
import signal
import sys
import os
import time
from colorama import init, Fore, Style

# Initialize colorama
init()

# Define versions and their typical responses with associated CVEs
server_versions = {
    22: "OpenSSH_8.9p1",       # CVE-2022-3095: Remote code execution
    25: "Postfix 3.6.1",       # CVE-2021-26318: Remote code execution
    80: "Apache/2.4.51",      # CVE-2021-22905: Remote code execution
    443: "nginx/1.21.6",       # CVE-2022-4174: Remote code execution
    123: "ntpd 4.2.8p15",      # CVE-2020-25839: Denial of Service
    3128: "Squid/4.12",        # CVE-2021-20207: Remote code execution
    8080: "Squid/4.12",        # CVE-2021-20207: Remote code execution
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
}

# List to keep track of open sockets for clean shutdown
sockets = []

def simulate_service(port):
    version = server_versions.get(port, "Unknown")
    service_name = port_service_names.get(port, "Unknown")
    cve_id, cve_type = cve_info.get(port, ("N/A", "N/A"))

    # Set color based on the port
    service_color = Fore.RESET
    port_color = Fore.CYAN
    cve_color = Fore.BLUE

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  # Allow reuse of local addresses
    s.bind(('', port))
    s.listen()
    sockets.append(s)  # Add to sockets list for cleanup

    # Print that the port is open with color
    message = (f'{service_color}Listening on port [{port_color}{port}{Fore.RESET}] '
               f'as [{service_color}{service_name}{Fore.RESET}] '
               f'({version}, CVE: {cve_color}{cve_id}{Fore.RESET} ({cve_type})){Fore.RESET}')
    print(message)

    while True:
        try:
            conn, addr = s.accept()
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
            # Print details of the new connection
            conn_message = (f'{timestamp} - Connection from {Fore.CYAN}{addr[0]}:{addr[1]}{Fore.RESET} '
                            f'on port [{Fore.CYAN}{port}{Fore.RESET}]')
            print(conn_message)

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

                conn.sendall(response)
        except Exception as e:
            print(f"Error on port {port}: {e}")

def signal_handler(sig, frame):
    print('Interrupt received, shutting down...')
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
        print(f"Fork #1 failed: {e}")
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
        print(f"Fork #2 failed: {e}")
        sys.exit(1)

    # Redirect standard file descriptors
    sys.stdin.close()
    sys.stdout.close()
    sys.stderr.close()
    sys.stdin = open(os.devnull, 'r')
    sys.stdout = open('/tmp/simulate_ports.log', 'a+')
    sys.stderr = open('/tmp/simulate_ports.log', 'a+')

def main():
    # Register the signal handler for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)

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

