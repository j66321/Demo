server {

    listen 80;
    server_name abc.com;
    return 301 https://$server_name$request_uri;
}

server {

    listen 443 ssl;
    server_name abc.com;

    ssl_certificate     /etc/nginx/ssl/abc.com/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/abc.com/privkey.pem;

    location / {
    }
}
