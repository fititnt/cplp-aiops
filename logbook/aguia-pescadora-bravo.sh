echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

#################### Diario de bordo: aguia-pescadora-bravo ####################
# VPS (KVM), 2 vCPUs, 8GB RAM, 80GB SSD, Ubuntu Server 18.04 64bit, CloudAtCost (Canada)
#
# Datacenter: CloudAtCost, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 2vCPUs
# RAM: 7786MB
# Disk: 80GB
#
# IPv4: 192.99.247.117
# IPv6: 2607:5300:201:3100:0:0:0:87fc
# Domain:
#   Full: aguia-pescadora-bravo.etica.ai (apb.etica.ai)
#   Short: apb.etica.ai
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
################################################################################

#------------------------------------------------------------------------------#
# SEÇÃO: Configuração inicial                                                  #
# TL;DR: Isso é feito ao receber uma VPS do zero                               #
#------------------------------------------------------------------------------#

### Primeiro login______________________________________________________________
# Você, seja por usuario + senha, ou por Chave SSH, normlamente terá que acessar
# diretamente como root. Excessões a esta regra (como VMs na AWS) geralmente
# implicam em logar em um usuario não-root e executar como sudo. Mas nesta da
# é por root mesmo nesse momento.
ssh root@192.99.247.117

### Atualizar o sistema operacional_____________________________________________
# O sistema operacional (neste caso, Ubuntu) normalmente não vai estar 100%
# atualizado. Os comandos abaixo são uma boa prática pra fazer imediatamente
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

### Define um hostname personalizado____________________________________________
# O hostname padrão geralmente não faz muito sentido pra você e os usuparios
# da VPS. No nosso caso, era vps240016, como em root@vps240016.
# Nota: o domínio 'aguia-pescadora-bravo.etica.ai' já aponta para 192.99.247.117
sudo hostnamectl set-hostname aguia-pescadora-bravo.etica.ai

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 aguia-pescadora-bravo.etica.ai  aguia-pescadora-bravo
