# AWS Multi-Tier Web Application

A scalable and secure three-tier web application deployed on AWS with load balancing, auto-scaling, and database integration.

---

## 📋 Project Overview
This project demonstrates a production-ready web application architecture on AWS with:
- **Application Load Balancer** for traffic distribution
- **EC2 instances** in private subnets for security
- **RDS MySQL database** with Multi-AZ deployment
- **Auto Scaling** for handling variable traffic
- **Bastion host** for secure SSH access

---

## 🏗️ Architecture

### High-Level Architecture
![Architecture Diagram](architecture/architechture.png)

### Security and Traffic Flow
![Security Flow](architecture/security-flow.png)

**Architecture Components:**
- **Public Subnet:** Application Load Balancer, Bastion Host, NAT Gateway
- **Private Subnet:** Web Servers (EC2), RDS Database
- **Multi-AZ:** Deployed across 2 Availability Zones for high availability

## 🛠️ Technologies Used
- **AWS VPC** - Network isolation
- **EC2** - Web servers (t2.micro)
- **Application Load Balancer** - Traffic distribution
- **RDS MySQL** - Database (db.t3.micro)
- **Auto Scaling Group** - Dynamic scaling
- **Apache** - Web server
- **Amazon Linux 2023** - Operating system

## 📸 Screenshots

### 1. VPC Configuration
| VPC Overview | Subnets |
| --- | --- |
| ![VPC Overview](screenshots/01-vpc-setup/vpc-overview.png) | ![Subnets](screenshots/01-vpc-setup/subnets.png) |

| Public Route Table | Private Route Table |
| --- | --- |
| ![Public Route Table](screenshots/01-vpc-setup/Public-RouteTable.png) | ![Private Route Table](screenshots/01-vpc-setup/Private-RouteTable.png) |

| Internet Gateway | NAT Gateway |
| --- | --- |
| ![Internet Gateway](screenshots/01-vpc-setup/internet-gateway.png) | ![NAT Gateway](screenshots/01-vpc-setup/nat-gateway.png) |

### 2. Security Groups

#### Application Load Balancer SG
| Inbound Rules | Outbound Rules |
| --- | --- |
| ![ALB Inbound](screenshots/02-security-groups/alb-sg-inbound.png) | ![ALB Outbound](screenshots/02-security-groups/alb-sg-outbound.png) |

#### Web Server SG
| Inbound Rules | Outbound Rules |
| --- | --- |
| ![Web Server Inbound](screenshots/02-security-groups/webserver-sg-inbound.png) | ![Web Server Outbound](screenshots/02-security-groups/webserver-sg-outbound.png) |

#### Database SG
| Inbound Rules | Outbound Rules |
| --- | --- |
| ![Database Inbound](screenshots/02-security-groups/database-sg-inbound.png) | ![Database Outbound](screenshots/02-security-groups/database-sg-outbound.png) |

#### Bastion Host SG
| Inbound Rules | Outbound Rules |
| --- | --- |
| ![Bastion Inbound](screenshots/02-security-groups/bastion-sg-inbound.png) | ![Bastion Outbound](screenshots/02-security-groups/bastion-sg-outbound.png) |

### 3. EC2 Instances
| Bastion Host | Web Server 1 | Web Server 2 |
| --- | --- | --- |
| ![Bastion Instance](screenshots/03-ec2-instances/bastion-instance.png) | ![Web Server 1](screenshots/03-ec2-instances/webserver-1-instance.png) | ![Web Server 2](screenshots/03-ec2-instances/webserver-2-instance.png) |

### 4. Load Balancer
| ALB Overview | ALB DNS |
| --- | --- |
| ![ALB Overview](screenshots/04-load-balad-balancer/alb-overview.png) | ![ALB DNS](screenshots/04-load-balad-balancer/alb-dns.png) |

| Target Group | Healthy Targets |
| --- | --- |
| ![Target Group](screenshots/04-load-balad-balancer/target-group.png) | ![Healthy Targets](screenshots/04-load-balad-balancer/healthy-targets.png) |

### 5. RDS Database
| RDS Overview | RDS Connectivity |
| --- | --- |
| ![RDS Overview](screenshots/05-database/rds-overview.png) | ![RDS Connectivity](screenshots/05-database/rds-connectivity.png) |

### 6. Working Application
| Application Instance 1 | Application Instance 2 |
| --- | --- |
| ![Web App 1](screenshots/06-working-app/webapp-screenshot-1.png) | ![Web App 2](screenshots/06-working-app/webapp-screenshot-2.png) |

## 🔒 Security Implementation
- **Network Segmentation:** Web servers and database in private subnets
- **Security Groups:** Restrict traffic between tiers
- **Bastion Host:** Secure SSH access point
- **No Public IPs:** Application servers not directly accessible
- **Least Privilege:** Minimal required permissions only

## 💰 Cost Estimate

| Resource | Monthly Cost |
| --- | --- |
| EC2 Instances (3x t2.micro) | ~$25 |
| RDS MySQL (db.t3.micro) | ~$30 |
| Application Load Balancer | ~$20 |
| NAT Gateway | ~$35 |
| **Total** | **~$110/month** |

*Note: Eligible for AWS Free Tier (first 12 months)*

## 📚 What I Learned
- AWS VPC networking and subnet design
- Multi-tier architecture implementation
- Security best practices (security groups, private subnets)
- Load balancing and auto-scaling configuration
- High availability strategies
- Troubleshooting cloud infrastructure
- Infrastructure documentation

## 🔧 Technical Challenges Solved
- **Load Balancer 504 Errors** - Fixed security group configuration
- **SSH Access Issues** - Configured bastion host properly
- **Database Connection** - Set up security groups correctly
- **Auto Scaling** - Configured proper health checks and policies

## 🎯 Future Improvements
- [ ] Add HTTPS with SSL certificate
- [ ] Implement CI/CD pipeline
- [ ] Add CloudFront CDN
- [ ] Terraform infrastructure as code
- [ ] Enhanced monitoring with custom dashboards
- [ ] Containerize with Docker/ECS

## 📖 Documentation
- **Setup Scripts:** `scripts/setup-webserver.sh`
- **User Data:** `scripts/user-data.sh`
- **Test Connection:** `scripts/test-connection.sh`
- **Database Setup:** `scripts/database-setup.sql`
