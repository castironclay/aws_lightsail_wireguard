#!/bin/bash

export WG_PKEY="${WG_PKEY}"
export WG_NETWORK="${WG_NETWORK}"
export SERVER_LINK_IPADDRESS="${SERVER_LINK_IPADDRESS}"
export LINK_NETMASK="${LINK_NETMASK}"
export NET_PORT="${NET_PORT}"
export ROUTER_ALLOWED_IPS="${ROUTER_ALLOWED_IPS}"
export PHONE_ALLOWED_IPS="${PHONE_ALLOWED_IPS}"
export ROUTER_KEY="${ROUTER_KEY}"
export PHONE_KEY="${PHONE_KEY}"

# get some system info
NET_IFACE=$(ls /sys/class/net/ | grep -Ev '^(wg[0-9]+|lo)$')

# Update and install
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get install -y wireguard iptables-persistent

# Unbound setup
apt-get install unbound unbound-host -y
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache

cat > /etc/unbound/unbound.conf <<EOF
server:
  num-threads: 4

  #Enable logs
  verbosity: 1

  #list of Root DNS Server
  root-hints: "/var/lib/unbound/root.hints"

  # use the root server's key for DNSSEC
  auto-trust-anchor-file: "/var/lib/unbound/root.key"

  #Respond to DNS requests on all interfaces
  interface: 0.0.0.0
  max-udp-size: 3072

  #Authorized IPs to access the DNS Server
  access-control: 0.0.0.0/0                 refuse
  access-control: 127.0.0.1                 allow
  access-control: ${WG_NETWORK}/24         allow

  #not allowed to be returned for public internet  names
  private-address: ${WG_NETWORK}/24

  # Hide DNS Server info
  hide-identity: yes
  hide-version: yes

  #Limit DNS Fraud and use DNSSEC
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-referral-path: yes

  #Add an unwanted reply threshold to clean the cache and avoid when possible a DNS Poisoning
  unwanted-reply-threshold: 10000000

  #Have the validator print validation failures to the log.
  val-log-level: 1

  #Minimum lifetime of cache entries in seconds
  cache-min-ttl: 1800

  #Maximum lifetime of cached entries
  cache-max-ttl: 14400
  prefetch: yes
  prefetch-key: yes
EOF
chown -R unbound:unbound /var/lib/unbound

# Add hostname to /etc/hosts localhost line
sed -i "s/\(127.0.0.1\slocalhost\)/\1 $(hostname)/g" /etc/hosts

systemctl disable systemd-resolved
systemctl stop systemd-resolved
systemctl enable unbound-resolvconf
systemctl enable unbound

# wireguard setup
cd /etc/wireguard

cat > wg0.conf <<EOF
[Interface]
PrivateKey = $WG_PKEY
Address = $SERVER_LINK_IPADDRESS/$LINK_NETMASK
ListenPort = $NET_PORT
SaveConfig = false
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE; iptables -t nat -A POSTROUTING -s $WG_NETWORK/$LINK_NETMASK -o $NET_IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $NET_IFACE -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o $NET_IFACE -j MASQUERADE; iptables -t nat -D POSTROUTING -s $WG_NETWORK/$LINK_NETMASK -o $NET_IFACE -j MASQUERADE

[Peer] # Router
PublicKey = $ROUTER_KEY
AllowedIPs = $ROUTER_ALLOWED_IPS

[Peer] # Phone
PublicKey = $PHONE_KEY
AllowedIPs = $PHONE_ALLOWED_IPS
EOF

# enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1
sed -i 's/\#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p
echo 1 | tee /proc/sys/net/ipv4/ip_forward

# start wireguard service
wg-quick up wg0
systemctl enable wg-quick@wg0

# Track VPN connection
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Enable VPN traffic on the listening port
iptables -A INPUT -p udp -m udp --dport $NET_PORT -m conntrack --ctstate NEW -j ACCEPT

# TCP & UDP recursive DNS traffic
iptables -A INPUT -s $WG_NETWORK/$LINK_NETMASK -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s $WG_NETWORK/$LINK_NETMASK -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT

# Allow forwarding of packets that stay in the VPN tunnel
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT

systemctl enable netfilter-persistent && netfilter-persistent save
reboot
