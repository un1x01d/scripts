import paramiko
import socket
import threading
import logging

# Configure logging
logging.basicConfig(filename='server.log', level=logging.INFO, format='%(asctime)s - %(message)s')

class RestrictedShell(paramiko.ServerInterface):
    def __init__(self):
        self.event = threading.Event()

    def check_channel_request(self, kind, channel):
        if kind == 'session':
            return paramiko.OPEN_SUCCEEDED
        return paramiko.CLOSED

    def check_channel_shell_request(self, channel):
        logging.info("Received shell request")
        return paramiko.OPEN_SUCCEEDED

    def check_channel_exec_request(self, channel, command):
        logging.info(f"Received exec request: {command}")
        return paramiko.OPEN_SUCCEEDED

    def check_channel_pty_request(self, channel, term, width, height, pixel_width, pixel_height, modes):
        # Log PTY request details for debugging
        logging.info(f"PTY request: term={term}, width={width}, height={height}, pixel_width={pixel_width}, pixel_height={pixel_height}")
        return paramiko.OPEN_SUCCEEDED

    def check_auth_password(self, username, password):
        # Simple authentication for demonstration; replace with secure method
        if username == 'user1' and password == 'password1':
            logging.info(f"Authentication successful for user: {username}")
            return paramiko.AUTH_SUCCESSFUL
        logging.warning(f"Authentication failed for user: {username}")
        return paramiko.AUTH_FAILED

def execute_command(command):
    """Execute the command and return stdout and stderr."""
    try:
        import subprocess
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        return stdout.decode('utf-8'), stderr.decode('utf-8')
    except Exception as e:
        logging.error(f"Error executing command '{command}': {str(e)}")
        return '', str(e)

def handle_client(client_socket):
    """Handle an individual client connection."""
    transport = paramiko.Transport(client_socket)
    try:
        # Generate and set the server's RSA key
        server_key = paramiko.RSAKey.generate(2048)
        transport.add_server_key(server_key)

        server = RestrictedShell()
        transport.start_server(server=server)

        # Wait for client authentication
        channel = transport.accept()
        if channel is None:
            logging.warning("No channel.")
            return

        logging.info("Client authenticated successfully.")

        # Interaction with the client
        channel.send("Welcome to the SSH Jail Shell.\n")
        while True:
            command = channel.recv(1024).decode('utf-8').strip()
            if not command:
                break

            stdout, stderr = execute_command(command)
            channel.send(stdout + stderr)

        channel.close()
    finally:
        transport.close()

if __name__ == "__main__":
    # Create a TCP/IP socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('0.0.0.0', 2222))
    server_socket.listen(100)

    logging.info("SSH Jail Shell listening on port 2222")

    while True:
        client_socket, _ = server_socket.accept()
        client_thread = threading.Thread(target=handle_client, args=(client_socket,))
        client_thread.start()

