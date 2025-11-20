# adding repository and installing nginx		
apt update
apt install nginx -y
cat <<EOT > cr7578
upstream cr7578 {

 server app01:8080;

}

server {

  listen 80;

location / {

  proxy_pass http://cr7578;

}

}

EOT

mv cr7578 /etc/nginx/sites-available/cr7578
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/cr7578 /etc/nginx/sites-enabled/cr7578

#starting nginx service and firewall
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
