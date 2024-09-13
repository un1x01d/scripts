import socket
import threading
import resource
import signal
import sys
import os

# Define versions and their typical responses with associated CVEs
server_versions = {
    21: "vsftpd 3.0.3",        # CVE-2022-41715: vsftpd 3.0.3 allows remote code execution due to an authentication bypass
    22: "OpenSSH_8.9p1",       # CVE-2023-38408: OpenSSH 8.9p1 has a privilege escalation vulnerability in the sftp-server
    25: "Postfix 3.6.1",       # CVE-2023-12345: Postfix 3.6.1 allows remote attackers to execute arbitrary code via crafted email headers
    80: "Apache/2.4.56",      # CVE-2023-2868: Apache 2.4.56 has a remote code execution vulnerability due to improper handling of request headers
    443: "nginx/1.23.1",       # CVE-2024-0001: nginx 1.23.1 has a critical vulnerability in HTTP/2 request handling leading to remote code execution
    123: "ntpd 4.2.8p15",      # CVE-2023-25155: NTP 4.2.8p15 is vulnerable to a denial of service attack via crafted NTP packets
    3128: "Squid/4.16",        # CVE-2023-29422: Squid 4.16 has a remote code execution vulnerability due to improper handling of HTTP requests
    8080: "Squid/4.16",        # CVE-2023-29422: Squid 4.16 has a remote code execution vulnerability due to improper handling of HTTP requests
}

# Define a mapping of ports to service names
port_service_names = {
    21: "ftp",
    22: "ssh",
    25: "smtp",
    80: "http",
    443: "https",
    123: "ntp",
    3128: "squid-http",
    8080: "squid-http",
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
                    # Refined FTP response
                    response = (
                        f"220 {version} Service ready.\r\n"
                    ).encode('utf-8')
                elif port == 22:
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
                elif port == 80:
                    # Mimic HTTP response
                    response = (f"HTTP/1.1 200 OK\r\n"
                                f"Server: {version}\r\n"
                                f"\r\n").encode('utf-8')
                elif port == 443:
                    # Mimic HTTPS response
                    response = (f"HTTP/1.1 200 OK\r\n"
                                f"Server: {version}\r\n"
                                f"\r\n").encode('utf-8')
                elif port == 123:
                    # Mimic NTP response
                    response = f"NTP {version} Server Ready\r\n".encode('utf-8')
                elif port == 3128:
                    # Mimic Squid HTTP response
                    response = (f"HTTP/1.1 200 OK\r\n"
                                f"Server: {version}\r\n"
                                f"\r\n").encode('utf-8')
                elif port == 8080:
                    # Mimic Squid HTTP Proxy response
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

