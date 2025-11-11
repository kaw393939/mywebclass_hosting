# MyWebClass.org - Docker Infrastructure

A production-ready Docker infrastructure setup with Traefik reverse proxy, Let's Encrypt SSL certificates, Watchtower for automatic updates, and Apache HTTPD web server.

## 🚀 Features

- **Traefik v2.10**: Modern reverse proxy and load balancer
- **Let's Encrypt SSL**: Automatic SSL/TLS certificates via Cloudflare DNS challenge
- **Watchtower**: Automatic Docker container updates
- **Apache HTTPD**: Reliable web server for static content
- **Docker Compose**: Easy orchestration and deployment

## 📋 Prerequisites

- Docker and Docker Compose installed
- Domain name (mywebclass.org) configured with Cloudflare
- Cloudflare API tokens with DNS edit permissions
- Server with ports 80 and 443 accessible

## 🛠️ Initial Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd mywebclass.org
```

### 2. Configure Environment Variables

Copy the example environment file and configure it:

```bash
cp .env.example .env
```

Edit `.env` and set:

- `CF_DNS_API_TOKEN`: Your Cloudflare API token for DNS
- `CF_ZONE_API_TOKEN`: Your Cloudflare Zone API token
- `TRAEFIK_DASHBOARD_CREDENTIALS`: Basic auth credentials for Traefik dashboard

#### Generate Traefik Dashboard Credentials

```bash
# Using Docker
docker run --rm httpd:2.4-alpine htpasswd -nbB admin "your_password" | sed -e s/\\$/\\$\\$/g

# Or if you have htpasswd installed locally
echo $(htpasswd -nb admin your_password) | sed -e s/\\$/\\$\\$/g
```

### 3. Set Correct Permissions

```bash
chmod 600 traefik/acme.json
```

### 4. Update Email in Traefik Configuration

Edit `traefik/traefik.yml` and change the email address for Let's Encrypt:

```yaml
certificatesResolvers:
  cloudflare:
    acme:
      email: your-email@mywebclass.org  # Change this
```

## 🚦 Deployment

### Start All Services

```bash
docker-compose up -d
```

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f traefik
docker-compose logs -f httpd
docker-compose logs -f watchtower
```

### Stop Services

```bash
docker-compose down
```

## 🌐 Accessing Services

- **Main Website**: https://mywebclass.org or https://www.mywebclass.org
- **Traefik Dashboard**: https://traefik.mywebclass.org (requires authentication)

## 📁 Project Structure

```
.
├── docker-compose.yml          # Main orchestration file
├── .env.example                # Environment variables template
├── traefik/
│   ├── traefik.yml            # Traefik static configuration
│   ├── config.yml             # Traefik dynamic configuration
│   └── acme.json              # Let's Encrypt certificates (auto-generated)
├── www/
│   └── index.html             # Website content
└── README.md                   # This file
```

## 🔧 Configuration Details

### Traefik

- Automatically routes traffic based on domain names
- Handles SSL/TLS certificates via Let's Encrypt
- Uses Cloudflare DNS challenge for wildcard certificates
- Dashboard available for monitoring

### Watchtower

- Checks for image updates every hour (3600 seconds)
- Automatically pulls new images and restarts containers
- Cleans up old images after updates

### HTTPD Web Server

- Serves static content from `./www` directory
- Accessible via mywebclass.org and www.mywebclass.org
- Automatically gets SSL certificates from Traefik

## 🔒 DNS Configuration

Ensure your DNS records in Cloudflare point to your server:

```
A     mywebclass.org          -> YOUR_SERVER_IP
A     www.mywebclass.org      -> YOUR_SERVER_IP
A     traefik.mywebclass.org  -> YOUR_SERVER_IP
```

Or use a wildcard:

```
A     mywebclass.org     -> YOUR_SERVER_IP
A     *.mywebclass.org   -> YOUR_SERVER_IP
```

## 📝 Updating Website Content

1. Edit files in the `www/` directory
2. Commit and push changes to GitHub:

```bash
git add www/
git commit -m "Update website content"
git push origin main
```

3. On the server, pull the changes:

```bash
git pull origin main
docker-compose restart httpd
```

## 🔄 Server Deployment Workflow

On your production server:

```bash
# Initial setup
git clone <repository-url>
cd mywebclass.org
cp .env.example .env
# Edit .env with your credentials
nano .env

# Set permissions
chmod 600 traefik/acme.json

# Start services
docker-compose up -d
```

For updates:

```bash
cd mywebclass.org
git pull origin main
docker-compose up -d
```

Watchtower will automatically handle container updates.

## 🛡️ Security Notes

- `.env` file is gitignored - never commit sensitive credentials
- `acme.json` must have 600 permissions
- Traefik dashboard is password-protected
- All HTTP traffic is automatically redirected to HTTPS

## 📊 Monitoring

View real-time logs:

```bash
# All containers
docker-compose logs -f

# Specific container
docker-compose logs -f traefik
```

Check Traefik dashboard for routing and certificate status:
https://traefik.mywebclass.org

## 🐛 Troubleshooting

### Certificates not generating

1. Check Cloudflare API tokens are correct
2. Verify DNS records are properly configured
3. Check Traefik logs: `docker-compose logs traefik`
4. Ensure ports 80 and 443 are accessible

### Container not starting

```bash
docker-compose down
docker-compose up -d
docker-compose logs -f [service-name]
```

### Reset SSL certificates

```bash
docker-compose down
rm traefik/acme.json
touch traefik/acme.json
chmod 600 traefik/acme.json
docker-compose up -d
```

## 📚 Additional Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Watchtower Documentation](https://containrrr.dev/watchtower/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 📄 License

This project is configured for mywebclass.org infrastructure.

## 🤝 Contributing

1. Make changes locally
2. Test with `docker-compose up`
3. Commit and push to GitHub
4. Pull changes on production server
