### Digital Ocean
Install the following 1-Clicker with your digitalocean account:
https://marketplace.digitalocean.com/apps/docker

SSH into your server with the generated IP address
```
ssh root@<my.new.ip.address>
```

#### Configure a (non-root) deploy user (optional but highly recommended)
```
adduser -m deploy sudo
passwd deploy
mkdir /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
cp /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
usermod -aG docker deploy
newgrp docker
```

#### Configure the firewall of your new server to accept web requests
```
sudo ufw allow 22/tcp
sudo ufw allow http
sudo ufw allow https
sudo ufw reload
```

If you haven't already pointed the domains' nameservers to your new server, do so now.


### Setup this node as a remote docker context (optional but highly recommended)
If you want to control the remote server from your local environment (recommended), setup the docker context:
```
docker context create \
    --docker host=ssh://deploy@<my.new.ip.address> \
    my_context
docker use my_context
```

[<= Return to main directions](../README.md)