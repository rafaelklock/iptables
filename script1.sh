#!/bin/sh


iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FOSRWARD ACCEPT


echo "Regra Porta 5070 - Clientes Rede NET Nao Registram na 5060"
iptables -t nat -A PREROUTING -i eno2 -p udp --dport 5070 -j REDIRECT --to-port 5060


echo "Bloqueio de Friendly Scanner"
iptables -A INPUT -p udp -m udp --dport 5060 -m string --string "friendly-scanner" --algo bm --to 500 -j LOG --log-prefix '** SIP ATTACK **'
iptables -A INPUT -p udp -m udp --dport 5060 -m string --string "friendly-scanner" --algo bm --to 500 -j DROP


echo "Libera loopback"
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I INPUT -i lo -j ACCEPT
iptables -I INPUT -s 127.0.0.1 -j ACCEPT


echo "Liberando Hosts de Provedores VOIP"
iptables -A INPUT -s 199.87.121.0/24 -j ACCEPT
iptables -A INPUT -s 199.87.121.15/32 -j ACCEPT



echo "Liberando Hosts confiaveis"
iptables -A INPUT -s 148.72.153.72/32 -j ACCEPT



echo "Bloqueio SMTP"
iptables -A INPUT -p tcp --dport 25 -j LOG --log-prefix '** BLOQUEIO SMTP **'
iptables -A INPUT -p tcp --dport 25 -j DROP

echo "Bloqueio Mysql e Postgres"
iptables -A INPUT -p tcp --dport 5432 -j LOG --log-prefix '** BLOQUEIO POSTGRESQL **'
iptables -A INPUT -p tcp --dport 5432 -j DROP

iptables -A INPUT -p tcp --dport 3306 -j LOG --log-prefix '** BLOQUEIO MYSQL **'
iptables -A INPUT -p tcp --dport 3306 -j DROP

echo "Bloqueio Asterisk e ast_Manager"
iptables -A INPUT -p udp --dport 5060 -j LOG --log-prefix '** BLOQUEIO ASTERISK **'
iptables -A INPUT -p udp --dport 5060 -j DROP

iptables -A INPUT -p tcp --dport 5038 -j LOG --log-prefix '** BLOQUEIO ASTERISK **'
iptables -A INPUT -p tcp --dport 5038 -j DROP



echo "Reiniciando Fail2Ban"
systemctl restart fail2ban
