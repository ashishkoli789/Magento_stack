FROM nginx:1.26-bookworm

RUN groupadd -g 1001 clp && \
    useradd -u 1001 -g clp -m -s /bin/bash test-ssh

RUN mkdir -p /var/cache/nginx /var/run /etc/nginx/ssl && \
    chown -R test-ssh:clp /var/cache/nginx /var/run /etc/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
