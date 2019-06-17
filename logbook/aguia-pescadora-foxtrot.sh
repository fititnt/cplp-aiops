echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

################### Diario de bordo: aguia-pescadora-foxtrot ###################
# VPS (KVM), 4 vCPUs, 8GB RAM, 200GB SSD, Ubuntu Server 18.04 64bit, Contabo (Germany)
#
# Datacenter: Contabo, Germany
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 4 vCPUs
# RAM: 7976 MB
# Disk: 200 GB
#
# IPv4: 167.86.127.225
# IPv6: 
# Domain:
#   Full: aguia-pescadora-foxtrot.etica.ai (TTL: 15 min)
#   Short: apf.etica.ai (TTL: 15 min)
#
# -----------------------------------------------------------------------------#
# LICENSE: Public Domain
#   Except where otherwise noted, content on this server configuration and to
#   the extent possible under law, Emerson Rocha has waived all copyright and
#   related or neighboring rights to this work to Public Domain
#
# MAINTAINER: Emerson Rocha <rocha(at)ieee.org>
#   Keep in mind that several people help with suggestions, testing, bugfixes
#   and inspiration without get names noted in places that most software
#   developers look. I'm saying this in special for people who help over
#   Facebook discussions. Even the ones without a personal computer yet and/or
#   with limited access to internet.
#
# SECURITY:
#   Reporting a Vulnerability:
#   Send e-mail to Emerson Rocha: rocha(at)ieee.org.
################################################################################

### Primeiro login______________________________________________________________
# Você, seja por usuario + senha, ou por Chave SSH, normlamente terá que acessar
# diretamente como root. Excessões a esta regra (como VMs na AWS) geralmente
# implicam em logar em um usuario não-root e executar como sudo. Mas nesta da
# é por root mesmo nesse momento.
ssh root@167.86.127.225

### Atualizar o sistema operacional_____________________________________________
# O sistema operacional (neste caso, Ubuntu) normalmente não vai estar 100%
# atualizado. Os comandos abaixo são uma boa prática pra fazer imediatamente
sudo apt update
sudo apt upgrade -y
sudo apt autoremove

### Define um hostname personalizado____________________________________________
# O hostname padrão geralmente não faz muito sentido pra você e os usuparios
# da VPS. No nosso caso, era vps240016, como em root@vps240016.
# Nota: o domínio 'aguia-pescadora-bravo.etica.ai' já aponta para 192.99.247.117
sudo hostnamectl set-hostname aguia-pescadora-foxtrot.etica.ai

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 aguia-pescadora-foxtrot.etica.ai  aguia-pescadora-foxtrot

### Define horário padrão de sistema_____________________________________________
# Vamos definir como horário padrão de servidor o UTC.
# Motivo 1: para aplicações de usuário, é mais fácil calcular a partir do horário
#           Zulu
# Motivo 2: Este servidor será acessado por pessoas de diversos países, não
#           apenas falantes de português que são do Brasil (e que, aliás, o
#           próprio Brasil tem mais de um fuso horário)
sudo timedatectl set-timezone UTC

### Criar Swap & ajusta Swappiness______________________________________________
## TODO: setup swap from 2GB (defalt from Contabo) to 8GB (fititnt, 2019-06-16 01:44 BRT)

## Já temos uma Swap de 2GB
# root@aguia-pescadora-delta:/# ls -lh /swapfile
# -rw------- 1 root root 2.0G Jun 12 11:05 /swapfile

## @see https://bogdancornianu.com/change-swap-size-in-ubuntu/
## @see https://askubuntu.com/questions/1075505/how-do-i-increase-swapfile-in-ubuntu-18-04/1075516#1075516

## Cria um /swapfile de 4GB
# @see https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04
# @see https://askubuntu.com/questions/1075505/how-do-i-increase-swapfile-in-ubuntu-18-04/1075516#1075516

# TODO: descobrir configurações para rodar Tsuru em produção que estejam
#       relacionadas a swap. Numa olhada rápida ao menos quando usado
#        Kubernetes (que NÃO é nosso caso) os desenvolvedores desativam
#        funcionamento em sistemas com Swap sem parametro especial, vide
#        https://github.com/kubernetes/kubernetes/issues/53533
#        (fititnt, 2019-06-17 02:16 BRT)

### Adiciona chave (pelo menos um super admin) _________________________________
## Cheque se já existe o arquivo authorized_keys
ls -lha /root/.ssh/authorized_keys

## Caso não exista, crie
sudo mkdir -p /root/.ssh/
sudo chmod 700 /root/.ssh/
sudo touch /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys

## Troque para chave publica de cada um dos administradores, o arquivo PUB
#    cat ~/.ssh/id_rsa.pub
# Neste caso usado para inicializar ao menos o
#   cat ~/.ssh/id_rsa-rocha-eticaai-2019.pub
sudo echo "ssh-rsa (...chave...)== email@dominio.tdl" >> /root/.ssh/authorized_keys

## Reveja as chaves em /root/.ssh/authorized_keys e tenha certeza que esta tudo
## como deveria
sudo cat /root/.ssh/authorized_keys

#------------------------------------------------------------------------------#
# SEÇÃO TSURU: ADIÇÃO DA CHAVE SSH PARA SER CONFIGURADO REMOTAMENTE            #
#                                                                              #
# AVISO: veja devel-fititnt-bravo.sh para saber como a chave foi criada        #
#------------------------------------------------------------------------------#
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7erwMfyTSO7xn8axjAp2NTbBHjDVdu+6J17ZjX3Rs55dy3Vsqmq4kBIq3qxShabfY6h5nW3ccc86hGy8coXjPCblyloAKlG0RKkRo7/sGjsl3jv8i0gZVLU/H8pjaLLGhRWca2ToJAPJTlnFk/VrCMvH6PCHca7X70j88uE6UR5W1nax94kzcyOf/65mQDx7dHYVVyBL+Rgn0CHS4Di8Z0PSbwn1dVA0S4JW1z1DZ/5AYdhOBCfPkDvj4trTr9lmJIn/6KnOX+MIMzViHtxZw3dg8VHcZxd2PeiJ/THZZ3Z34Bv60jEwyjZMNKB6fqz4mAGkHH8bAXMS4m6gZXw6TaPZk84x3t9rJnzWhPaUYOkPL9dgcZ8m+FmeUxKkJgdo10AqZAMVdboYEKhL4Uv9JvZrt/VdkM6C2FqIDEddm6TWnqZiteeLtCl0EU5PMxsfQUncHkRihya6R1Brysu5lvTGEvW1qoobONowT3ED2F5aDTPlyscTr4ogKXAJda+jI5oIGxkf2QaKzhdJlt76KktQRVlOQVYJeKcVOB853IVMSJvIpP09YReaibrxdSYeazu+SswqNK7ux7S3Xb82PtSu7jtJtiiCdU6zfCLkWPAmoqP8N3m1q2lw4VvXxvLeUp79n3cv+kabG0UpE2csyJArSX/eyUF7+6F9QWQo4ow== aguia-pescadora-tsuru.no-reply@etica.ai" >> ~/.ssh/authorized_keys

## Reveja as chaves em /root/.ssh/authorized_keys e tenha certeza que esta tudo
## como deveria
sudo cat /root/.ssh/authorized_keys
