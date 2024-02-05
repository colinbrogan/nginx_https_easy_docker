# Running NGINX with HTTPS (via Let's Encrypt) on Docker
Docker is supposed to make server deployment easy, but without the right recipe, some things may become much harder. Running an NGINX server with HTTPS via Let's Encrypt (replete with auto-renewals) was fairly straightforward in the past, but on Docker, its a real SNAFU. Having found existing recipes on the internet for this unnecessarily complex or unreliable, I am sharing my solution to help others avoid the same head-aches I faced.
## Enough talk. Let's go!
```
git clone https://github.com/colinbrogan/nginx_https_easy_docker
```
Put your domain in the .env file

```
DOMAIN=mydomain.com
```

### Setup a docker node with a hosting provider
Directions for 1-click solutions by major hosting providers are linked to below. In general, any virtual machine setup according to [Official Docker Install Instructions](https://docs.docker.com/engine/install/ubuntu/) should work. Make sure to also open up port 80 and 443 on your firewall. How to do this extra step is found in the Digital Ocean link below
- [DigitalOcean](hosting_providers/digitalocean.md)
- More to come (DM me if you've got directions for other providers)

### Point your domain nameservers to the docker node
(If you haven't already)

### Deploy!
```
docker compose up --build -d
```

Watch your domain magically become HTTPS, and worry not about renewals. You may add your app's NGINX configuration in `dockerdata/nginx/cert.conf`.


## Why would I even need this?
While docker in theory simplifies server setup and management, in practice it's seperation of services can make Let's Encrypt + Nginx configuration complex. Getting docker to create the certificate AND configure NGINX is one thing. To then have it autorenew (so your clients' website doesn't go down in 3 months) is quite another accomplishment. Docker is designed for each service to run a single primary process, so we have to come up with entrypoints to coordinate the two services (nginx and certbot), waiting for eachother to perform particular tasks before progressing to final stages. Luckily, you don't have to worry about any of this because it's all done under the hood for you.

## How does it work under the hood?
We have two seperate configurations files for NGINX: `dockerdata/nginx/precert.conf`, and `dockerdata/nginx/cert.conf`. The first (precert.conf) is only the configuration needed to run NGINX on port 80, so that cerbot can perform it's acme challenge. We then switch to the full configuration of NGINX (cert.conf), including the https certificate after certbot has done it's thing.

Observe the entrypoint for the nginx service here [dockerdata/nginx/cert-entrypoint.sh](dockerdata/nginx/cert-entrypoint.sh). We first overwrite both configuration files with the domain you've entered in .env. We then run an infinite while loop in the background, which checks if the cert files exist every 10 seconds, before moving to the primary process running nginx (which at this point will be running precert.conf). This gets us up on port 80, waiting for the certbot service to do it's acme test. As soon as the file check finds the certificate files, we switch the nginx configuration file to cert.conf, and reload nginx. This gives us the full configuration of NGINX, including the https certificates and other recommended settings. We now switch the while loop wait time to 6 hours, since we now only need to reload nginx when certbot renews the certificate.

If we now examine certbot's entrypoint [dockerdata/certbot/certbot-entrypoint.sh](dockerdata/certbot/certbot-entrypoint.sh), we see another file check looking for the existence of the certificate. If it's not there, we tell certbot to generate the first certificate in the volume which is shared between nginx and certbot. We then enter an infinite loop to renew the certificate every 12 hours. The next time you run compose up, the entrypoint will skip the initial generation, and go straight to the renew loop every 12 hours.


## Conclusion
I have yet to see a solution for NGINX and let's encrypt which manages both initial certificate generation and auto-renewal without performing atleast some of the steps manually. By creating a compose file which automatically generates and/or renews at docker's build / runtime, you can focus your efforts on your app without annoying server setup / maintenance, which is the reason why you chose docker in the first place. No more cursing the Gods!