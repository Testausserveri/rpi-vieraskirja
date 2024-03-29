FROM node:alpine

WORKDIR /bin/

RUN apk update && apk add bash hostapd dnsmasq iptables dhcp && rm -rf /var/cache/apk/*
RUN npm install express

RUN echo "" > /var/lib/dhcp/dhcpd.leases
ADD http.js /bin/http.js
ADD entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]

