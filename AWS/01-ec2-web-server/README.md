# AWS EC2 Web Server Project

# AWS EC2 Web Server Project

## Overview
Launched an EC2 instance on AWS running Amazon Linux 2023 with automated web server installation using User Data scripts. Configured and tested both Apache (httpd) and Nginx web servers, demonstrating Linux system administration, AWS compute fundamentals, and infrastructure security through Security Groups.

---

## Architecture

```mermaid
graph TB
    User[👤 User Browser] -->|HTTP Port 80| SG
    Admin[🔑 Admin] -->|SSH Port 22| SG
    
    subgraph AWS Cloud
        subgraph VPC - Default
            SG[🔒 Security Group\nPort 22 - My IP\nPort 80 - 0.0.0.0/0]
            subgraph Public Subnet
                EC2[💻 EC2 Instance\nt2.micro\nAmazon Linux 2023]
            end
        end
    end
    
    SG --> EC2
    EC2 -->|Serves| Web[🌐 Website]
---

## Services & Tools Used
| Component | Service/Tool | Purpose |
| :--- | :--- | :--- |
| **Compute** | EC2 (t2.micro) | Host the web server |
| **OS** | Amazon Linux 2023 | Server operating system |
| **Firewall** | Security Groups | Control inbound/outbound traffic |
| **Access** | Key Pair (RSA) | SSH authentication |
| **Automation** | User Data Script | Auto-install Apache at boot |
| **Web Server 1** | Apache (httpd) | Serve website (default) |
| **Web Server 2** | Nginx | Serve website (alternative) |

---

## What I Did
1. **Created a Key Pair** for secure SSH access to the instance.
2. **Configured Security Group** with rules for SSH (port 22, my IP only) and HTTP (port 80, public).
3. **Launched EC2 Instance** with Amazon Linux 2023 AMI and t2.micro (free tier).
4. **Automated Apache installation** using EC2 User Data bootstrap script.
5. **Verified website** accessible via public IP in browser.
6. **SSH'd into the server** and explored Apache configuration and logs.
7. **Installed Nginx** and switched from Apache to demonstrate both web servers.
8. **Troubleshot Caching:** Verified service transitions using `curl -v` to bypass browser-side persistence.

---

## Key Learnings
* **Security Groups** act as virtual firewalls at the instance level (stateful).
* **User Data** scripts run only once at first boot (not on restart).
* **Directory Paths:** Apache serves from `/var/www/html/`, Nginx serves from `/usr/share/nginx/html/`.
* **Port Management:** Only one web server can listen on port 80 at a time.
* **Systemd:** `systemctl enable` makes a service start on boot, `start` runs it immediately.
* **Cache Persistence:** Learned that `curl` is the source of truth for server-side changes when browsers/ISPs cache content.

---

## Screenshots
<details>
<summary>Click to view project evidence</summary>

### Network & Security
![Security Group Rules](screenshots/01-security-group-inbound-rules.png)

### Instance Management
![EC2 Instance Status](screenshots/02-ec2-instance-running.png)
![SSH Terminal](screenshots/04-ssh-terminal-connected.png)

### Web Server Verification
![Apache Browser](screenshots/03-apache-website-browser.png)
![Nginx Browser](screenshots/05-nginx-website-browser.png)

</details>

---

## Cost Analysis
| Resource | Cost |
| :--- | :--- |
| EC2 t2.micro | Free tier (750 hrs/month) |
| EBS Storage 8GB | Free tier (30 GB/month) |
| **Total** | **$0.00** |
