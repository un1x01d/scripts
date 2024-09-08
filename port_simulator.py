import socket
import threading
import resource
import signal
import sys
import os

# Define vulnerable server versions for different services
server_versions = {
    21: "vsftpd 3.0.3",        # Insecure handling of FTP commands (CVE-2021-36159)
    23: "Telnetd 2.4",         # Weak authentication (CVE-2022-23418)
    80: "Apache 2.4.49",       # Remote Code Execution (CVE-2021-41773)
    443: "nginx 1.21.1",       # Potential RCE (CVE-2022-4174)
    3128: "Squid 4.14",        # Remote Code Execution (CVE-2021-20231)
    8080: "Apache 2.4.51"      # Remote Code Execution (CVE-2021-41773)
}

# Define a mapping of ports to service names
port_service_names = {
    21: "ftp",
    23: "telnet",
    80: "http",
    443: "https",
    3128: "squid-http",
    8080: "http-proxy"
}

# List to keep track of open sockets for clean shutdown
sockets = []

def simulate_service(port):
    version = server_versions.get(port, "Unknown")
    service_name = port_service_names.get(port, "Unknown")

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  # Allow reuse of local addresses
    s.bind(('', port))
    s.listen()
    sockets.append(s)  # Add to sockets list for cleanup
    print(f'Listening on port {port} as {service_name} ({version})')

    while True:
        try:
            conn, addr = s.accept()
            with conn:
                if port == 21:
                    # Mimic FTP response with known vulnerability
                    response = (f"220 {version} Service ready.\r\n").encode('utf-8')
                elif port == 23:
                    # Mimic Telnet response with known vulnerability
                    response = (f"Telnetd: {version}\r\n").encode('utf-8')
                elif port == 80 or port == 443 or port == 8080 or port == 3128:
                    # Mimic HTTP/HTTPS/Squid Proxy response with a 404 Not Found
                    response = (f"HTTP/1.1 404 Not Found\r\n"
                                f"Content-Type: text/html\r\n"
                                f"Server: {version}\r\n"
                                f"\r\n"
                                f"404 Not Found\r\n").encode('utf-8')
                elif port == 139:
                    # Mimic NetBIOS response (simplified)
                    response = b"Server: NetBIOS\r\n"

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
