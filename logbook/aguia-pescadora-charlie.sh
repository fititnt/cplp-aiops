echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

################### Diario de bordo: aguia-pescadora-charlie ###################
# VPS (KVM), 1 vCPUs, 4GB RAM, 40GB SSD, Ubuntu Server 18.04 64bit, OVH (Canada)
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 1 vCPUs
# RAM: 3848 MB
# Disk: 40 GB
#
# IPv4: 192.99.69.2
# IPv6: 2607:5300:0201:3100:0000:0000:0000:0398
# Domain:
#   Full: aguia-pescadora-charlie.etica.ai
#   Short: apc.etica.ai
#
# Domain, extras:
#  - apc.etica.ai (TTL: 15 min)
#      - CNAME aguia-pescadora-charlie.etica.ai (sempre aponta para Charlie)
#  - usuario.apc.etica.ai (TTL: 15 min)
#      - CNAME aguia-pescadora-charlie.etica.ai (sempre aponta para Charlie)
#      - Veja https://github.com/fititnt/cplp-aiops/issues/35
#  - lb-ap.etica.ai (TTL: 2 min)
#      - Balanceamento de carga via Round-robin DNS.
#      - Veja github.com/fititnt/cplp-aiops/issues/40
#  - usuario.lb-ap.etica.ai (TTL: 2 min)
#      - CNAME lb-ap.etica.ai (Balanceamento de carga via Round-robin DNS)
#      - Veja github.com/fititnt/cplp-aiops/issues/35
#      - Veja github.com/fititnt/cplp-aiops/issues/40
#
# Login:
#   ssh user@aguia-pescadora-charlie.etica.ai
#   mosh user@aguia-pescadora-charlie.etica.ai
#   ssh user@abp.etica.ai
#   mosh user@abp.etica.ai
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

### Primeiro login______________________________________________________________
# Você, seja por usuario + senha, ou por Chave SSH, normlamente terá que acessar
# diretamente como root. Excessões a esta regra (como VMs na AWS) geralmente
# implicam em logar em um usuario não-root e executar como sudo. Mas nesta da
# é por root mesmo nesse momento.
ssh root@192.99.69.2

### Atualizar o sistema operacional_____________________________________________
# O sistema operacional (neste caso, Ubuntu) normalmente não vai estar 100%
# atualizado. Os comandos abaixo são uma boa prática pra fazer imediatamente
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

### Define um hostname personalizado____________________________________________
# O hostname padrão geralmente não faz muito sentido pra você e os usuparios
# da VPS. No nosso caso, era vps240016, como em root@vps240016.
# Nota: o domínio 'aguia-pescadora-bravo.etica.ai' já aponta para 192.99.247.117
sudo hostnamectl set-hostname aguia-pescadora-charlie.etica.ai

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 aguia-pescadora-charlie.etica.ai  aguia-pescadora-charlie

### Define horário padrão de sistema_____________________________________________
# Vamos definir como horário padrão de servidor o UTC.
# Motivo 1: para aplicações de usuário, é mais fácil calcular a partir do horário
#           Zulu
# Motivo 2: Este servidor será acessado por pessoas de diversos países, não
#           apenas falantes de português que são do Brasil (e que, aliás, o
#           próprio Brasil tem mais de um fuso horário)
sudo timedatectl set-timezone UTC

### Idioma padrão do servidor: português________________________________________
# Vamos definir o idioma padrão (e também outras configurações de localização)
# para o português
# Motivo 1: aguia-pescadora é voltada para pessoas falantes de português
# Motivo 2: mesmo que pessoas administradoras do servidor saibam inglês as
#           pessoas que criam aplicações (principalmente as que usam ferramentas
#           com menos abstrações, como as por shell) poderiam ter mais
#           dificuldades, e nosso foco aqui é facilitar para todo mundo
sudo apt install language-pack-pt language-pack-pt-base

### Criar Swap & ajusta Swappiness______________________________________________
## Cria um /swapfile de 4GB
# @see https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04
sudo fallocate -l 4G /swapfile
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

#------------------------------------------------------------------------------#
# SEÇÃO TSURU / CONFIGURAÇÃO INICIAL                                           #
# TL;DR: Isso é feito ao receber uma VPS do zero                               #
#------------------------------------------------------------------------------#
# @see https://github.com/tsuru/tsuru
# @see https://tsuru-client.readthedocs.io

# Esta sessão é totalmente como usuário root
sudo su
sudo cd ~

### Tsuru client (requisito para instalar o tsuru) _____________________________
# A instação do Tsuru em https://docs.tsuru.io/stable/installing/using-tsuru-installer.html
# explica que a instalação dele é feita usando o tsuru-client
#
# tsuru-client em https://tsuru-client.readthedocs.org recomenda que, em Ubuntu,
# use o 'ppa:tsuru/ppa'. Porém esse PPA não só não tem pacote para o Ubuntu 18.04 LTS
# como os pacotes para o Ubuntu 16.04 (tsuru version 1.1.1) parecem
# desatualziados o suficiente em relação a opção oferecida em https://github.com/tsuru/tsuru-client/releases
# (ultima: 1.7.0-rc2 de 2019-02-22, ou a 1.6.0 de 2018-07-19).

mkdir /root/tsuru-setup
cd /root/tsuru-setup

wget https://github.com/tsuru/tsuru-client/releases/download/1.6.0/tsuru_1.6.0_linux_amd64.tar.gz
tar -vzxf tsuru_1.6.0_linux_amd64.tar.gz
mv tsuru /usr/local/bin

cd /root/tsuru-setup
rm tsuru_1.6.0_linux_amd64.tar.gz

# TODO: considerar adicionar bash-completion além de apenas o bash
#      (fititnt, 2019-06-02 03:18 BRT)
cat misc/bash-completion
# Copie o conteúdo do arquivo acima para o .bashrc ou (Ubuntu 18.04) no
#  ~/.bash_aliases do usuário que usaria o tsuru
touch ~/.bash_aliases
cat misc/bash-completion >> ~/.bash_aliases

### Cria arquivos de especificação do tsuru ____________________________________
sudo tsuru install-config-init
# O comando acima criará arquivos padrões no diretório atual

vim /root/tsuru-setup/install-compose.yml
vim /root/tsuru-setup/install-config.yml

### Continuar...
# @see https://docs.tsuru.io/stable/installing/using-tsuru-installer.html#installing-on-already-provisioned-or-physical-hosts
# @see https://docs.docker.com/machine/overview/
# @see https://dev.to/zac_siegel/using-docker-machine-to-provision-a-remote-docker-host-1267