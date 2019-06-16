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
# SEÇÃO TSURU: ADIÇÃO DA CHAVE SSH PARA SER CONFIGURADO REMOTAMENTE            #
#                                                                              #
# AVISO: veja devel-fititnt-bravo.sh para saber como a chave foi criada        #
#------------------------------------------------------------------------------#

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7erwMfyTSO7xn8axjAp2NTbBHjDVdu+6J17ZjX3Rs55dy3Vsqmq4kBIq3qxShabfY6h5nW3ccc86hGy8coXjPCblyloAKlG0RKkRo7/sGjsl3jv8i0gZVLU/H8pjaLLGhRWca2ToJAPJTlnFk/VrCMvH6PCHca7X70j88uE6UR5W1nax94kzcyOf/65mQDx7dHYVVyBL+Rgn0CHS4Di8Z0PSbwn1dVA0S4JW1z1DZ/5AYdhOBCfPkDvj4trTr9lmJIn/6KnOX+MIMzViHtxZw3dg8VHcZxd2PeiJ/THZZ3Z34Bv60jEwyjZMNKB6fqz4mAGkHH8bAXMS4m6gZXw6TaPZk84x3t9rJnzWhPaUYOkPL9dgcZ8m+FmeUxKkJgdo10AqZAMVdboYEKhL4Uv9JvZrt/VdkM6C2FqIDEddm6TWnqZiteeLtCl0EU5PMxsfQUncHkRihya6R1Brysu5lvTGEvW1qoobONowT3ED2F5aDTPlyscTr4ogKXAJda+jI5oIGxkf2QaKzhdJlt76KktQRVlOQVYJeKcVOB853IVMSJvIpP09YReaibrxdSYeazu+SswqNK7ux7S3Xb82PtSu7jtJtiiCdU6zfCLkWPAmoqP8N3m1q2lw4VvXxvLeUp79n3cv+kabG0UpE2csyJArSX/eyUF7+6F9QWQo4ow== aguia-pescadora-tsuru.no-reply@etica.ai" >> ~/.ssh/authorized_keys

#------------------------------------------------------------------------------#
# SEÇÃO TSURU: CONFIGURAÇÃO INICIAL                                            #
#                                                                              #
# AVISO: veja devel-fititnt-bravo.sh                                           #
#------------------------------------------------------------------------------#

# Veja devel-fititnt-bravo.sh.

#------------------------------------------------------------------------------#
# SEÇÃO TSURU: CONFIGURAÇÃO DO GANDALF                                         #
#                                                                              #
# ISSUES: - Deploy de apps usando `git push` (discussão geral) #60             #
#             - https://github.com/fititnt/cplp-aiops/issues/60                #
#------------------------------------------------------------------------------#
# @see https://docs.tsuru.io/stable/installing/gandalf.html
# @see https://docs.tsuru.io/stable/managing/repositories.html

curl -s https://packagecloud.io/install/repositories/tsuru/stable/script.deb.sh | sudo bash
sudo apt install gandalf-server

# NOTA: Que estranho. O Gandalf tem um repositório dedicado no packagecloud.io
#       porém a documentação oficial do Tsuru para Ubuntu ainda recomenda
#       aquele PPA super desatualizado. Se for isso mesmo vale a pena avisar
#       o uptstream (fititnt, 2019-06-03 02:40 BRT)

apt policy tsuru-client
#tsuru-client:
#  Installed: (none)
#  Candidate: 1.6.0
#  Version table:
#     1.6.0 500
#        500 https://packagecloud.io/tsuru/stable/ubuntu bionic/main amd64 Packages
#     1.5.1 500
#        500 https://packagecloud.io/tsuru/stable/ubuntu bionic/main amd64 Packages

# NOTA: Yep. E a versão é exatamente a que foi instalada manualmente.
#       Provavelmente devo remover a versão manual de fititnt-bravo e de
#       aguia-pescadora-charlie.etica.ai (fititnt, 2019-06-03 02:45 BRT)

## Instala o Galdalf (conforme https://docs.tsuru.io/stable/installing/gandalf.html)
sudo apt install gandalf-server
# Reading package lists... Done
# Building dependency tree
# Reading state information... Done
# E: Unable to locate package gandalf-server

# NOTA: O Tsuru 1.6.0 está disponível no Ubunu 18.04, mas não o Gandalf. Tem que
#       considerar reportar mais de um repositório
#       (fititnt, 2019-06-03 02:58 BRT)

# NOTA: reportado em https://github.com/tsuru/gandalf/issues/216

# Podemos considerar instalar do código fonte, porém nesse momento vou ver
# outras ações, como configurar o Tsuru melhor antes de usar o Gandalf
# (fititnt, 2019-06-03 03:20 BRT)

#------------------------------------------------------------------------------#
# SEÇÃO TSURU: USUÁRIOS INICIAIS                                               #
#                                                                              #
# TL;DR:  Cria os usuários, grupos e permissões iniciais                       #
#------------------------------------------------------------------------------#
# @see https://tsuru-client.readthedocs.io/en/latest/reference.html
# Ajuda sobre como criar usuarios
tsuru help user-create

# Cria admins (isso pede senhas, criar temporária para os demais)
tsuru user-create rocha@ieee.org
tsuru user-create felipecchaves@gmail.com
tsuru user-create kayenga@outlook.pt
tsuru user-create cdiego@criacorpo.com.br
tsuru user-create uriel29@gmail.com
tsuru user-create jefferson.soares09@gmail.com

tsuru user-create testing-no-reply@etica.ai # Usuario (idealmente) temporario
                                            # com permissão total. Demais
                                            # administradores idealmente
                                            # devem usar seu próprio usuario

# Usuários não administradores
tsuru user-create {email de github.com/rodriguesJeff}

# Lista usuarios criados
tsuru user-list

tsuru team-create administracao
tsuru team-create padrao

# Lista times
tsuru team-list

# Lista todas as permissões
tsuru permission-list

tsuru role-assign AllowAll rocha@ieee.org
tsuru role-assign AllowAll felipecchaves@gmail.com
tsuru role-assign AllowAll kayenga@outlook.pt
tsuru role-assign AllowAll cdiego@criacorpo.com.br
tsuru role-assign AllowAll uriel29@gmail.com
tsuru role-assign AllowAll jefferson.soares09@gmail.com
tsuru role-assign AllowAll testing-no-reply@etica.ai

# Lista pools
tsuru pool-list
# theonepool

# Libera geral para poder usar a theonepool (só temos ela)
tsuru pool-constraint-set theonepool team "*"

#------------------------------------------------------------------------------#
# SEÇÃO TSURU: PLATAFORMAS                                                     #
#------------------------------------------------------------------------------#
# @see Lista de plataformas padrões do Tsuru: https://github.com/tsuru/platforms
# @see Exemplos de uso destas: https://github.com/tsuru/platforms/tree/master/examples

## Prepara plataforma Cordova
tsuru platform-add cordova

## Prepara plataforma Elixir
tsuru platform-add elixir

## Prepara plataforma Go
tsuru platform-add go

## Prepara plataforma Java
tsuru platform-add java

## Prepara plataforma NodeJS
tsuru platform-add nodejs

## Prepara plataforma PHP
tsuru platform-add php

## Prepara plataforma Python
tsuru platform-add python

## Prepara plataforma Ruby
tsuru platform-add ruby

## Prepara plataforma static
tsuru platform-add static

#------------------------------------------------------------------------------#
# SEÇÃO: POR CATALOGAR...                                                      #
#                                                                              #
#------------------------------------------------------------------------------#


## Isso em devel-fititnt-bravo
# mkdir -p ~/tmp/tsuru/ola-mundo
# cd ~/tmp/tsuru/ola-mundo
# echo "<?php phpinfo(); ?>" > index.php
# tsuru app-create ola-mundo-php php # Error: You must provide a team to execute this action.
# tsuru help app-create
# tsuru app-create ola-mundo-php php --team padrao
# tsuru app-info --app ola-mundo-php
# tsuru app-deploy -a ola-mundo-php .
# Veja http://ola-mundo-php.192.99.69.2.nip.io/
# :D

# TODO: considerar demonstração com chatbot como o
#       https://pypi.org/project/chatbotAI/ (fititnt, 2019-06-03 06:18 BRT)


# TODO: considerar uso de APIs como
#       https://blog.rapidapi.com/top-search-apis/ (fititnt, 2019-06-03 06:24 BRT)

