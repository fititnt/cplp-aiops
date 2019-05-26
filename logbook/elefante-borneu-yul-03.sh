echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit
############### Diario de bordo: elefante-borneu-yul-03.etica.ai ###############
# VPS (KVM), 1 vCPU, 2GB RAM, 20GB SSD, Ubuntu Server 18.04 64bit, OVH, Canada
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 1 vCPU
# RAM: 2 GB
# Disk: 20 GB
#
# IPv4: 149.56.130.178
# IPv6: 2607:5300:0201:3100:0000:0000:0000:6df7
#
# Domain:
#   Full: elefante-borneu-yul-03.etica.ai (TTL: 15 min)
#   Short: ebyul03.etica.ai (TTL: 15 min)
#
# Domain, extras:
#   lb-ebyul.etica.ai (TTL: 2 min)
#   lb-eb.etica.ai (TTL: 2 min)
#
# Login:
#   ssh user@elefante-borneu-yul-03.etica.ai
#   mosh user@elefante-borneu-yul-03.etica.ai (TODO: install Mosh)
#   ssh user@ebyul03.etica.ai
#   mosh user@ebyul03.etica.ai (TODO: install Mosh)
#
# -----------------------------------------------------------------------------#
# LICENSE: Public Domain
#   Except where otherwise noted, content on this server configuration and to
#   the extent possible under law, Emerson Rocha has waived all copyright and
#   related or neighboring rights to this work to Public Domain
#
# MAINTAINER: Emerson Rocha <rocha(at)ieee.org>
#   Keep in mind that several people help with suggestions, bugfixes and
#   inspiration and inspire without get names noted in places that software
#   developers look. I'm saying this in special for people who help over
#   Facebook discussions. Even the ones without a personal computer yet.
# SECURITY:
#   Reporting a Vulnerability:
#   Send e-mail to Emerson Rocha: rocha(at)ieee.org.
################################################################################

#------------------------------------------------------------------------------#
# SEÇÃO 0.1: Configuração inicial                                              #
# TL;DR: Isso é feito ao receber uma VPS do zero                               #
#------------------------------------------------------------------------------#

### Primeiro login______________________________________________________________
ssh root@149.56.130.178

### Atualizar o sistema operacional_____________________________________________
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

### Define um hostname personalizado____________________________________________
sudo hostnamectl set-hostname elefante-borneu-yul-03

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 elefante-borneu-yul-03.etica.ai  elefante-borneu-yul-03

### Define horário padrão de sistema_____________________________________________
sudo timedatectl set-timezone UTC

### Idioma padrão do servidor: português________________________________________
sudo apt install language-pack-pt language-pack-pt-base
sudo update-locale LANG=pt_PT.utf8

### Criar Swap & ajusta Swappiness______________________________________________
## Cria um /swapfile de 2GB
# @see https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
ls -lh /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

## Ajusta swappness (tendência do SO a fazer swap)
# 100 = preferir fazer swap agressivamente (deixar memoria ram livre)
# 0 = só fazer swap em caso de urgência (deixa RAM o mais ocupada possivel)
cat /proc/sys/vm/swappiness
# O padrão vem com 60, vamos por em 10 (para so faze swap em casos mais criticos)

sudo sysctl vm.swappiness=10

vim /etc/sysctl.conf
# Adciona 'vm.swappiness=10' (sem aspas) no final do arquivo

## Cache Pressure
cat /proc/sys/vm/vfs_cache_pressure
# 100, vamos alterar para 50

vim /etc/sysctl.conf
# Adciona 'vm.vfs_cache_pressure=50' (sem aspas) no final do arquivo

##### VNstat [configuração inicial] ____________________________________________
# VNstat é uma ferramenta super eficiente que permite monitorar uso de rede
# ao longo do mês
# @see https://www.howtoforge.com/tutorial/vnstat-network-monitoring-ubuntu/

sudo apt install vnstat vnstati

# O comando a seguir deve ser usado para decidir qual a interface a monitorar
ifconfig
# Escolha a network para iniciar monitoramento. Neste caso é ens3

vnstat -u -i ens3

## vnstat --iflist
# Available interfaces: ens3 lo

# O arquivo /etc/vnstat.conf deve estar marcado para nossa interface desejada
sudo vim /etc/vnstat.conf
# trocar eth0 pela network especifica
# default interface
# Interface "ens3"
# Para ver em tempo real o uso de rede

# Vamos iniciar vnstat para rodar imediatamente, e também iniciar com sistema
sudo systemctl start vnstat
sudo systemctl enable vnstat