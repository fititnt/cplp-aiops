echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit
############### Diario de bordo: elefante-borneu-yul-01.etica.ai ###############
# VPS (KVM), 1 vCPU, 2GB RAM, 20GB SSD, Ubuntu Server 18.04 64bit, OVH, Canada
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 1 vCPU
# RAM: 2 GB
# Disk: 20 GB
#
# IPv4: 149.56.130.19
# IPv6: 2607:5300:0201:3100:0000:0000:0000:2f58
################################################################################

#------------------------------------------------------------------------------#
# SEÇÃO 0.1: Configuração inicial                                              #
# TL;DR: Isso é feito ao receber uma VPS do zero                               #
#------------------------------------------------------------------------------#

### Primeiro login______________________________________________________________
ssh root@149.56.130.19

### Atualizar o sistema operacional_____________________________________________
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

### Define um hostname personalizado____________________________________________
sudo hostnamectl set-hostname elefante-borneu-yul-01

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 elefante-borneu-yul-01.etica.ai  elefante-borneu-yul-01

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