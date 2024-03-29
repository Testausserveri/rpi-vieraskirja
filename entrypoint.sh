#!/bin/bash

if [ ! -w "/sys" ] ; then
    echo "[Error] Not running in privileged mode."
    exit 1
fi

if [ ! "${INTERFACE}" ] ; then
    echo "[Error] An interface must be specified."
    exit 1
fi

true ${AP_ADDR:=192.168.4.1}
true ${SSID:=Vieraskirja}
true ${CHANNEL:=11}
true ${HW_MODE:=g}

if [ ! -f "/etc/hostapd.conf" ] ; then
    cat > "/etc/hostapd.conf" <<EOF
interface=${INTERFACE}
${DRIVER+"driver=${DRIVER}"}
ssid=${SSID}
hw_mode=${HW_MODE}
channel=${CHANNEL}
wmm_enabled=1

# Activate channel selection for HT High Througput (802.11an)

${HT_ENABLED+"ieee80211n=1"}
${HT_CAPAB+"ht_capab=${HT_CAPAB}"}

# Activate channel selection for VHT Very High Througput (802.11ac)

${VHT_ENABLED+"ieee80211ac=1"}
${VHT_CAPAB+"vht_capab=${VHT_CAPAB}"}
EOF

fi

# Setup interface and restart DHCP service
ip link set ${INTERFACE} up
ip addr flush dev ${INTERFACE}
ip addr add ${AP_ADDR}/24 dev ${INTERFACE}

# NAT settings
echo "NAT settings ip_dynaddr, ip_forward"

for i in ip_dynaddr ip_forward ; do
  if [ $(cat /proc/sys/net/ipv4/$i) -eq 1 ] ; then
    echo $i already 1
  else
    echo "1" > /proc/sys/net/ipv4/$i
  fi
done

cat /proc/sys/net/ipv4/ip_dynaddr
cat /proc/sys/net/ipv4/ip_forward

iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

iptables -t nat -D PREROUTING -d 192.168.4.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:3000
iptables -t nat -I PREROUTING -d 192.168.4.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:3000

echo "Configuring DHCP server .."

cat > "/etc/dnsmasq.conf" <<EOF
interface=wlan0      # Use the require wireless interface - usually wlan0
dhcp-range=192.168.4.2,192.168.4.255,255.255.255.0,15m
address=/#/192.168.4.1 # Redirect all domains (the #) to the address 192.168.4.1 (the server on the (Pi)
EOF

echo "Starting DHCP server .."
dnsmasq

# Capture external docker signals
trap 'true' SIGINT
trap 'true' SIGTERM
trap 'true' SIGHUP

echo "Starting HTTP server ..."
node /bin/http.js &

echo "Starting HostAP daemon ..."
/usr/sbin/hostapd /etc/hostapd.conf &

wait $!

echo "Removing iptables rules..."

iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -D PREROUTING -d 192.168.4.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:3000
