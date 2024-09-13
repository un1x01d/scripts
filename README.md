# Simulate Ports Script

## Overview

This script simulates various network services on specified ports. It responds with typical service banners and includes a configurable logging mechanism to record connections and errors. The script supports running in the foreground or as a daemon, depending on the provided arguments.

## Features

- **Simulates Network Services**: Listens on specified ports and responds with service-specific banners.
- **Logging**: Logs all interactions and errors to `/tmp/simulate_ports.log`.
- **Daemon Mode**: Optionally runs as a daemon process, redirecting output and errors to a log file.

## Dependencies

- Python 3.x
- `colorama` library for colored output (install using `pip install colorama`)

## Configuration

### Port Mappings

The script simulates the following services:

- **Port 22**: SSH (`OpenSSH_8.9p1`) - CVE: CVE-2022-3095 (Remote Code Execution)
- **Port 25**: SMTP (`Postfix 3.6.1`) - CVE: CVE-2021-26318 (Remote Code Execution)
- **Port 80**: HTTP (`Apache/2.4.51`) - CVE: CVE-2021-22905 (Remote Code Execution)
- **Port 443**: HTTPS (`nginx/1.21.6`) - CVE: CVE-2022-4174 (Remote Code Execution)
- **Port 123**: NTP (`ntpd 4.2.8p15`) - CVE: CVE-2020-25839 (Denial of Service)
- **Port 3128**: Squid HTTP (`Squid/4.12`) - CVE: CVE-2021-20207 (Remote Code Execution)
- **Port 8080**: Squid HTTP (`Squid/4.12`) - CVE: CVE-2021-20207 (Remote Code Execution)

### Colors

- **Port Numbers**: Colored to match the service type.
- **Service Types**: Bracketed and colored to differentiate them.
- **CVE Details**: The CVE identifier and impact type are colored blue.

## Usage

### Running in the Foreground

To run the script in the foreground, simply execute:

```bash
python simulate_ports.py
