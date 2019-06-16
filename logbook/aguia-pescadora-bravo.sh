echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

#################### Diario de bordo: aguia-pescadora-bravo ####################
# VPS (KVM), 2 vCPUs, 8GB RAM, 80GB SSD, Ubuntu Server 18.04 64bit, OVH (Canada)
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 2vCPUs
# RAM: 7786MB
# Disk: 80GB
#
# IPv4: 192.99.247.117
# IPv6: 2607:5300:201:3100:0:0:0:87fc
# Domain:
#   Full: aguia-pescadora-bravo.etica.ai
#   Short: apb.etica.ai
#
# Domain, extras:
#  - apb.etica.ai (TTL: 15 min)
#      - CNAME aguia-pescadora-bravo.etica.ai (sempre aponta para Bravo)
#  - usuario.apb.etica.ai (TTL: 15 min)
#      - CNAME aguia-pescadora-bravo.etica.ai (sempre aponta para Bravo)
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
#   ssh user@aguia-pescadora-bravo.etica.ai
#   mosh user@aguia-pescadora-bravo.etica.ai
#   ssh user@apb.etica.ai
#   mosh user@apb.etica.ai
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
sudo netstat -ntulp # Portas usadas
sudo lsof -i -P -n | grep LISTEN  # Portas usadas (processo & usuário)
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# SEÇÃO 0.1: Configuração inicial                                              #
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
sudo apt update
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

sudo update-locale LANG=pt_PT.utf8

### Criar Swap & ajusta Swappiness______________________________________________
# Se o sistema operacional ficar sem memória ram suficiênte, ele pode ter falha
# crítica. Diferente de windows, no Linux swap precisa ser especificada
# explícitamente. No caso da aguia-pescadora-bravo, tanto por estabilidade do
# sistema como para explicitamente permitir que usuários possam fazer tarefas
# eventualmente intensivas, vamos por 12GB de Swap (A RAM desse sistema é 8GB)
#
# AVISO: apesar de:
#
#        1) os discos SSD da OVH tenham uma performance fantástica
#        2) não seria incomum o uso de swap em tarefas pontuais de data science
#        3) todo usuário de aguia-pescadora-bravo esteja ciente que
#           eventualmente colegas podem usar usar muita CPU e muita RAM
#           e que não poderão reclamar de lentidão apps e afins
#
#        é uma boa prática de vizinhança
#
#        1) se for rodar tarefas pesadas por várias horas, esteja online
#        2) se puder escolher horários que menos pessoas estão usando, melhor
#        3) feche seus programas quando parar de usar, e se algo der errado
#           avise algum admin para dar um reinstart na máquina

## Cria um /swapfile de 12GB
# @see https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04
sudo fallocate -l 12G /swapfile
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

### Cotas de uso de arquivos por usuários e grupos de usuários__________________
## @see https://www.digitalocean.com/community/tutorials/how-to-set-filesystem-quotas-on-ubuntu-18-04

sudo apt update
sudo apt install quota

# Checa se já temos o kernel preparado. Em geral VMs não vem por padrão
find /lib/modules/`uname -r` -type f -name '*quota_v*.ko*'

# E realmente não veio. Vamos instalar
sudo apt install linux-image-extra-virtual

sudo vim /etc/fstab
# Troque
#   LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
# Por (e repare, não tem espaço entre as virgulas!):
#   LABEL=cloudimg-rootfs   /        ext4   usrquota,grpquota        0 0

# Isso força as ações no /etc/fstab entrarem em efeito imediatamente sem
# reiniciar
sudo mount -o remount /

# O comando a seguir exibira os parâmetros extras
cat /proc/mounts | grep ' / '

# Prepara sistema para ter cotas de arquivos por usuario e grupos de usuario
sudo quotacheck -ugm /
# O comando acima cria dois arquivos, /aquota.group e /aquota.user

# O comando torna ativo o monitoramento de cotas (que serao definidas logo...)
sudo quotaon -v /
# /dev/sda1 [/]: group quotas turned on
# /dev/sda1 [/]: user quotas turned on

# O comando a seguir gera um relatorio de uso do disco
sudo repquota -s /

## SOBRE CONFIGURAÇÕES EXTRAS DE COTAS DE ARQUIVOS
# Veja os detalhes extras em https://www.digitalocean.com/community/tutorials/how-to-set-filesystem-quotas-on-ubuntu-18-04
# Em especial, os seguintes items podem ser refinidos
#   - Soft limit: se passar desse limite, tem um período de tolerância até este
#       soft limit se tornar um hard limit. Note que arquivos não são deletados,
#       apenas o usuário é impedido de criar novo conteúdo até que volte ao
#       limite abaixo do soft limit
#   - Hard limit: se passar desse limite, o S.O. impede de escrever em disco
#   - Período de tolerância: tempo entre o soft limit se tornar hard limit

##### Rede [nmap, traceroute, dig (dnsutils)....] ______________________________
sudo apt install -y traceroute nmap dnsutils

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

# Vamos iniciar vnstat para rodar imediatamente, e também iniciar com sistema
sudo systemctl start vnstat
sudo systemctl enable vnstat

# O arquivo /etc/vnstat.conf deve estar marcado para nossa interface desejada
sudo vim /etc/vnstat.conf
# trocar eth0 pela network especifica
# default interface
# Interface "ens3"
# Para ver em tempo real o uso de rede

##### Mosh _____________________________________________________________________
# @see https://mosh.org
#  Mosh é uma ferramenta que pode ajudar quem tem conecção movel intermitente.
#  Note: sem ajustes extras (que não são feitos aqui) o uso de Mosh não
#        significa automaticamente redução do custo de banda, por isso pode
#        ser necessário testes extras
sudo apt install mosh

##### Sdkman ___________________________________________________________________
# @see https://sdkman.io/
# Sdkman é usado para gerenciar SDKs relacionadas a JVM, desde Java, Scala até
# Kotlin
## wget -O sdk.install.sh "https://get.sdkman.io"


#------------------------------------------------------------------------------#
# SEÇÃO 0.2: BENCHMARK DO SISTEMA                                              #
#                                                                              #
# TL;DR: Avalia performance da máquina virtual e de rede                       #
#        Essa VM mais do que decente pelo preço dela!!!                        #
#                                                                              #
# AVISO: Esta sessão pode ser ignorada completamente. Está aqui apenas para    #
#        administradores de sistemas curiosos com VMs e hardware dedicados em  #
#        datacenters novos                                                     #
#------------------------------------------------------------------------------#
# Nota: logs detalhados no aguia-pescadora-bravo-benchmarks.sh, aqui tem apenas
#       parte da informação

### Velocidade da internet
sudo apt-get install speedtest-cli
speedtest-cli

# Nota: as velocidades estão dentro do oferecido pela OVH (que é 100Mbit/s)
#       e isso é otimo considerando que é trafego ilimitado e mais do que
#       atende as necessidades que se pretende usar o aguia-pescadora.
# Download: 97.58 Mbit/s
# Upload: 4.04 Mbit/s

### @see https://www.shellhacks.com/disk-speed-test-read-write-hdd-ssd-perfomance-linux/

# @see https://linuxhint.com/check-ram-ubuntu/
sudo apt-get install memtester
# Nota: memtester nao retorna velocidade, apenas se memoria esta saudável.
#       melhor usar outros

### @see http://www.geekpills.com/operating-system/linux/linux-check-ram-speed-type

### @see https://askubuntu.com/questions/634513/cpu-benchmarking-utility-for-linux/634516#634516
### @see https://github.com/akopytov/sysbench#linux
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt install sysbench

## CPU, via sysbench
sysbench cpu run
# Resultado em aguia-pescadora-bravo-benchmarks.sh

## Memória RAM, via sysbench
sysbench memory run
# Resultado em aguia-pescadora-bravo-benchmarks.sh

## Disco SSH, via sysbench
#@see https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench

# O tamanho do arquivo de teste precisa ser muito maior que nossa RAM
# (que é 8GB), porém nosso disco tem livre 75GB. Vamos testar com 50GB
sysbench --test=fileio --file-total-size=50G prepare
sysbench --test=fileio --file-total-size=50G --file-test-mode=rndrw --max-requests=0 run
sysbench --test=fileio --file-total-size=50G cleanup

#------------------------------------------------------------------------------#
# SEÇÃO 1.0: USUÁRIOS DO SISTEMA - ETAPA DE CRIAÇÃO/EDIÇÃO                     #
# TL;DR: Cria os usuários de sistema, e outras customizações                   #
#------------------------------------------------------------------------------#

### Guia para ser feito por cada usuário de sistema (copie e cole), início
# Cria o usuario, inclusive diretorio home /home/UsernameDoUsuario
sudo adduser UsernameDoUsuario

# Este comando força usuario usar uma senha propria no próximo login.
# Uma alternativa seria já ter chaves publicas de cada usuario
sudo passwd -e UsernameDoUsuario

## Caso o usuario perca acesso ao sistema
sudo passwd UsernameDoUsuario

# Digite uma senha temporaria, então execute o seguinte para força-la temporaria
sudo passwd -e UsernameDoUsuario

# Pessoas tem dificuldade no primeiro login (ex.: quem usa Putty no Windows),
# Pe precisar de um prazo para trocar senha temporária. Isto aqui força isso
sudo passwd --warndays 7 UsernameDoUsuario

### Guia para ser feito por cada usuário de sistema (copie e cole), fim

#### Preparação antes de adicionar usuários ____________________________________

## Cria base de /home2
# Em alguns casos, a /home/UsernameDoUsuario terá criptografia. Então vamos
# criar por padrão uma /home2/UsernameDoUsuario para que os guias de uso
# indiquem usar esta pasta para serviços que administradores poderiam dar
# suporte ao usuário sem precisar de senhas extras ou autorização prévia
# explícita
sudo mkdir /home2

#### Usuarios adicionados ______________________________________________________

### cdiegosr -------------------------------------------------------------------
sudo adduser cdiegosr
sudo passwd -e cdiegosr
sudo chsh -s /usr/bin/fish cdiegosr

### fcomarcosmabreu ------------------------------------------------------------
sudo adduser fcomarcosmabreu
sudo passwd -e fcomarcosmabreu

### fititnt --------------------------------------------------------------------
## Dominios customizados de fititnt (já adicionados na CloudFlare)
curl http://fititnt.apb.etica.ai
curl http://fititnt.lb-ap.etica.ai
curl http://php.fititnt.apb.etica.ai
curl http://php.fititnt.lb-ap.etica.ai
curl http://go.fititnt.apb.etica.ai
curl http://go.fititnt.lb-ap.etica.ai
curl http://js.fititnt.apb.etica.ai
curl http://js.fititnt.lb-ap.etica.ai
## Portas (Nota: apenas portas de aplicações 'mais permanentes')
# - 0.0.0.0:62000
# - 127.0.0.1:62001
#------------------------------------------------------------------------------#
sudo adduser fititnt
sudo passwd -e fititnt
sudo chsh -s /usr/bin/fish fititnt
sudo usermod -aG sudo fititnt

## Portas usadas
sudo lsof -i -P -n | grep LISTEN | grep fititnt

# Aviso: descrição da razão dessaes passos esta em usuariodeteste
sudo mkdir /home2/fititnt
sudo chown fititnt:fititnt /home2/fititnt
sudo chmod 751 /home2/fititnt

sudo usermod -a -G www-data fititnt

sudo -u fititnt mkdir /home2/fititnt/web
sudo -u fititnt mkdir /home2/fititnt/web/public_html
sudo -u fititnt mkdir /home2/fititnt/web/public_api
sudo -u fititnt mkdir /home2/fititnt/web/php
sudo -u fititnt mkdir /home2/fititnt/web/js

sudo -u fititnt echo "fititnt <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/fititnt/web/public_html/index.html" > /home2/fititnt/web/public_html/index.html
sudo -u fititnt echo "fititnt <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/fititnt/web/php/index.php <br><?php phpinfo(); ?>" > /home2/fititnt/web/php/index.php

sudo -u fititnt vim /home2/fititnt/web/js/app.js
# Adicione conteudo de https://nodejs.org/en/docs/guides/getting-started-guide/

sudo cp /etc/nginx/sites-available/EXEMPLO-USUARIO.abp.etica.ai.conf /etc/nginx/sites-available/fititnt.apb.etica.ai.conf

sudo vim /etc/nginx/sites-available/fititnt.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/fititnt.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d fititnt.apb.etica.ai
sudo certbot --nginx -d php.fititnt.apb.etica.ai
# Nota: neste site escolhido redirecionar todo trafico HTTP para HTTPS

sudo chown fititnt:fititnt -R /home2/fititnt

### loopchaves -----------------------------------------------------------------
sudo adduser loopchaves
sudo passwd -e loopchaves
sudo usermod -aG sudo loopchaves

## Dominios customizados de loopchaves (já adicionados na CloudFlare)
curl http://loopchaves.apb.etica.ai
curl http://loopchaves.lb-ap.etica.ai
curl http://php.loopchaves.apb.etica.ai
curl http://php.loopchaves.lb-ap.etica.ai
curl http://go.loopchaves.apb.etica.ai
curl http://go.loopchaves.lb-ap.etica.ai
curl http://python.loopchaves.apb.etica.ai
curl http://python.loopchaves.lb-ap.etica.ai

# Aviso: descrição da razão dessaes passos esta em usuariodeteste
sudo mkdir /home2/loopchaves
sudo chown loopchaves:loopchaves /home2/loopchaves
sudo chmod 751 /home2/loopchaves

sudo usermod -a -G www-data loopchaves

sudo -u loopchaves mkdir /home2/loopchaves/web
sudo -u loopchaves mkdir /home2/loopchaves/web/public_html
sudo -u loopchaves mkdir /home2/loopchaves/web/public_api
sudo -u loopchaves mkdir /home2/loopchaves/web/php

sudo -u loopchaves echo "loopchaves <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/loopchaves/web/public_html/index.html" > /home2/loopchaves/web/public_html/index.html
sudo -u loopchaves echo "loopchaves <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/loopchaves/web/php/index.php <br><?php phpinfo(); ?>" > /home2/loopchaves/web/php/index.php


sudo cp /etc/nginx/sites-available/EXEMPLO-USUARIO.abp.etica.ai.conf /etc/nginx/sites-available/loopchaves.apb.etica.ai.conf

sudo vim /etc/nginx/sites-available/loopchaves.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/loopchaves.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d loopchaves.apb.etica.ai
sudo certbot --nginx -d php.loopchaves.apb.etica.ai

sudo chown loopchaves:loopchaves -R /home2/loopchaves


### jefferson091 ---------------------------------------------------------------
sudo adduser jefferson091
sudo passwd -e jefferson091

sudo chsh -s /usr/bin/fish jefferson091

# Aviso: descrição da razão dessaes passos esta em usuariodeteste
sudo mkdir /home2/jefferson091
sudo chown jefferson091:jefferson091 /home2/jefferson091
sudo chmod 751 /home2/jefferson091

sudo usermod -a -G www-data jefferson091

## Dominios customizados de jefferson091 (já adicionados na CloudFlare)
curl http://jefferson091.apb.etica.ai
curl http://jefferson091.lb-ap.etica.ai

sudo -u jefferson091 mkdir /home2/jefferson091/web
sudo -u jefferson091 mkdir /home2/jefferson091/web/public_html

sudo -u jefferson091 echo "jefferson091 <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/jefferson091/web/public_html/index.html" > /home2/jefferson091/web/public_html/index.html

sudo cp /etc/nginx/sites-available/EXEMPLO-USUARIO.abp.etica.ai.conf /etc/nginx/sites-available/jefferson091.apb.etica.ai.conf

sudo vim /etc/nginx/sites-available/jefferson091.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/jefferson091.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d jefferson091.apb.etica.ai

sudo chown jefferson091:jefferson091 -R /home2/jefferson091

### rodriguesjeff ---------------------------------------------------------------
sudo adduser rodriguesjeff
sudo passwd -e rodriguesjeff

sudo chsh -s /usr/bin/fish rodriguesjeff

# Aviso: descrição da razão desses passos esta em usuariodeteste
sudo mkdir /home2/rodriguesjeff
sudo chown rodriguesjeff:rodriguesjeff /home2/rodriguesjeff
sudo chmod 751 /home2/rodriguesjeff

sudo usermod -a -G www-data rodriguesjeff

## Dominios customizados de rodriguesjeff (já adicionados na CloudFlare)
curl http://rodriguesjeff.apb.etica.ai
curl http://rodriguesjeff.lb-ap.etica.ai

sudo -u rodriguesjeff mkdir /home2/rodriguesjeff/web
sudo -u rodriguesjeff mkdir /home2/rodriguesjeff/web/public_html

sudo -u rodriguesjeff echo "rodriguesjeff <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/rodriguesjeff/web/public_html/index.html" > /home2/rodriguesjeff/web/public_html/index.html

sudo cp /etc/nginx/sites-available/EXEMPLO-USUARIO.abp.etica.ai.conf /etc/nginx/sites-available/rodriguesjeff.apb.etica.ai.conf

sudo vim /etc/nginx/sites-available/rodriguesjeff.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/rodriguesjeff.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d rodriguesjeff.apb.etica.ai

sudo chown rodriguesjeff:rodriguesjeff -R /home2/rodriguesjeff

### dreamfactory (Usuario não humano) -------------------------------------------
# @see https://github.com/fititnt/cplp-aiops/issues/52
#
# DOMINIO: dreamfactory.apb.etica.ai
#
sudo useradd -s /usr/bin/fish dreamfactory

sudo mkdir /home2/dreamfactory/
sudo chown dreamfactory:dreamfactory /home2/dreamfactory
sudo chmod 751 -R /home2/dreamfactory

# Prepara o /home2/User/bin para instalar binarios instalados em /home2/User/bin
# Esse caminho é adicionado or padrão ao bash no Ubuntu 18
sudo -u dreamfactory mkdir -p /home2/dreamfactory/bin
sudo -u dreamfactory ln -s /home2/dreamfactory/bin /home/dreamfactory/bin

# Prepara caminhos extras no path do usuario
sudo su dreamfactory

# Cria outros diretórios que serão usados por este usuario imediatamente
sudo -u dreamfactory  mkdir -p /home2/dreamfactory/web/dreamfactory
sudo -u dreamfactory  mkdir /home2/dreamfactory/log

# Cria worker PHP-FPM exclusivo baseado no www.conf
sudo cp /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/dreamfactory.conf
sudo vim /etc/php/7.2/fpm/pool.d/dreamfactory.conf
sudo php-fpm7.2 --test # Valide se configurações são validas (sim, esse nome)
sudo systemctl reload php7.2-fpm

# Prepara o NGinx
sudo cp /etc/nginx/sites-available/EXEMPLO-PROXY.abp.etica.ai.conf /etc/nginx/sites-available/dreamfactory.apb.etica.ai.conf
sudo vim/etc/nginx/sites-available/dreamfactory.apb.etica.ai.conf

sudo ln -s /etc/nginx/sites-available/dreamfactory.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d dreamfactory.apb.etica.ai

# Cria uma página de teste (use para testar o PHP)
echo "dreamfactory <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/dreamfactory/web/dreamfactory/index.php <br><?php phpinfo(); ?>" | sudo -u dreamfactory tee /home2/dreamfactory/web/dreamfactory/index.php

# Move o diretório de teste para outra pasta. Pode-se voltar atras para testar o PHP info depois
sudo -u dreamfactory mv /home2/dreamfactory/web/dreamfactory/ /home2/dreamfactory/web/dreamfactory-phpinfo

# NOTA: agora vamos logar como usuario. Ele vai usar um composer próprio e
#       algumas customizações são muito específicas
sudo su
su - dreamfactory

cd /home2/dreamfactory/

# NOTA: temporariamente usando composer global. Será necessario documentar como
#       um usuário local pode sobrescrever todos os binários, e deixar de forma
#       intuitiva (fititnt, 2019-05-29 23:48 BRT)
## Instala composer
## @see https://getcomposer.org/download/
### php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
### php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
### php composer-setup.php --install-dir=bin --filename=composer
### php -r "unlink('composer-setup.php');"


## Seguimos agora o passo a passo da wiki oficial
# @see http://wiki.dreamfactory.com/DreamFactory/Installation

# sudo apt install php-mongodb (Instala php-mongo 1.3.4, porém o dreamfactory requer ext-mongodb ^1.5.0)
# Precisamos instalar versão de PECL
sudo apt install php-dev php-pear
sudo pecl install mongodb
sudo sh -c 'echo "extension=mongodb.so" > /etc/php/7.2/mods-available/mongodb.ini'
sudo phpenmod mongodb

git clone https://github.com/dreamfactorysoftware/dreamfactory.git /home2/dreamfactory/web/dreamfactory/
cd /home2/dreamfactory/web/dreamfactory/
composer install --no-dev

## Preparar banco de dados em Elefante Borneu
# mysql -u root -p
# CREATE DATABASE dreamfactory;
# GRANT ALL PRIVILEGES ON dreamfactory.* to 'dreamfactoryadmin'@'%' IDENTIFIED BY 'YOUR_PASSWORD_HERE';
# FLUSH PRIVILEGES;
# quit

php artisan df:env
php artisan df:setup

sudo chown -R dreamfactory:dreamfactory /home2/dreamfactory/web/dreamfactory/storage/ /home2/dreamfactory/web/dreamfactory/bootstrap/cache/
sudo chmod -R 2775 /home2/dreamfactory/web/dreamfactory/storage/ /home2/dreamfactory/web/dreamfactory/bootstrap/cache/

## Atalhos úteis nesta conta

# Error logs
tail -f /home2/dreamfactory/log/fpm-php.dreamfactory.log

# Corrige as permissões para serem exclusivas deste usuário
sudo chown dreamfactory:dreamfactory -R /home2/dreamfactory

# Desativa logar diretamente nesta conta (dai requer sudo para usá-la)
sudo chsh -s /bin/false dreamfactory

# Reativa logar diretamente nesta conta
sudo chsh -s /usr/bin/fish dreamfactory

### compilebot (Usuario não humano) --------------------------------------------
# Usuario sem senha, criado para permitir testes. Usuarios com poder de sudo
# poderão acessar esta conta
#
# DOMINIO: compilebot.api.apb.etica.ai
#
sudo useradd -r -s /bin/false compilebot

# Cria o home do usuario (usuario sem home pode ter algumas dificuldades ao usar alguns pacotes, como composer)
sudo mkhomedir_helper compilebot

sudo mkdir -p /home2/compilebot/web/api
sudo mkdir /home2/compilebot/log

cp /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/compilebot.conf

sudo vim /etc/php/7.2/fpm/pool.d/compilebot.conf

sudo php-fpm7.2 --test # Valide se configurações são validas (sim, esse nome)
sudo systemctl reload php7.2-fpm

sudo vim /etc/nginx/sites-available/compilebot.api.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/compilebot.api.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d compilebot.api.apb.etica.ai

sudo -u compilebot echo "compilebot <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/compilebot/web/api/index.php <br><?php echo 'whoiam:' . exec('whoami'); phpinfo(); ?>" > /home2/compilebot/web/api/index.php
sudo chown compilebot:compilebot -R /home2/compilebot

#### botpress ------------------------------------------------------------------
# ISSUE: Botpress #55 https://github.com/fititnt/cplp-aiops/issues/54
# ISSUE: Chatbots / Chatops (discussão geral) #54 https://github.com/fititnt/cplp-aiops/issues/54
# DOMINIOS:
#           - botpress.apb.etica.ai
#           - botpress.lb-ap.etica.ai

sudo adduser botpress
sudo chsh -s /usr/bin/fish botpress

# Apaga senha do usuario (gerencie usando sudo)
sudo passwd -d botpress

sudo mkdir /home2/botpress/
sudo chown botpress:botpress /home2/botpress
sudo chmod 751 -R /home2/botpress

### usuariodeteste -------------------------------------------------------------
# Usuario sem senha, criado para permitir testes. Usuarios com poder de sudo
# poderão acessar esta conta
sudo useradd -r -s /bin/false usuariodeteste

# Adiciona o usuario ao grupo www-data. Isso pode ser necessario em alguns casos
sudo usermod -a -G www-data usuariodeteste

# Prepara Home2 do usuario
sudo mkdir /home2/usuariodeteste
sudo chown usuariodeteste:usuariodeteste /home2/usuariodeteste
sudo chmod 751 /home2/usuariodeteste

# Em Home2, prepara diretórios comuns para sair usando apps web

sudo -u usuariodeteste mkdir /home2/usuariodeteste/web
sudo -u usuariodeteste mkdir /home2/usuariodeteste/web/public_html
sudo -u usuariodeteste mkdir /home2/usuariodeteste/web/public_api
sudo -u usuariodeteste mkdir /home2/usuariodeteste/web/php

sudo -u usuariodeteste echo "usuariodeteste <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/usuariodeteste/web/public_html/index.html" > /home2/usuariodeteste/web/public_html/index.html
sudo -u usuariodeteste echo "usuariodeteste <br>Servidor comunitario: http://aguia-pescadora-bravo.etica.ai <br>Arquivo: /home2/usuariodeteste/web/php/index.php <br><?php echo 'whoiam:' . exec('whoami'); phpinfo(); ?>" > /home2/usuariodeteste/web/php/index.php

sudo vim /etc/nginx/sites-available/usuariodeteste.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/usuariodeteste.apb.etica.ai.conf /etc/nginx/sites-enabled/

sudo nginx -t
# Se o comando acima falhar:
#    sudo rm /etc/nginx/sites-enabled/usuariodeteste.apb.etica.ai.conf
# Se ele não falhou, de reload no NGinx
sudo systemctl reload nginx

# Corrige permissões que por acaso tenham ficado para tras
sudo chown usuariodeteste:usuariodeteste -R /home2/usuariodeteste

## Dominios customizados de usuariodeteste (já adicionados na CloudFlare)
curl http://usuariodeteste.apb.etica.ai
curl http://usuariodeteste.lb-ap.etica.ai
curl http://php.usuariodeteste.apb.etica.ai
curl http://php.usuariodeteste.lb-ap.etica.ai
curl http://go.usuariodeteste.apb.etica.ai
curl http://go.usuariodeteste.lb-ap.etica.ai
curl http://python.usuariodeteste.apb.etica.ai
curl http://python.usuariodeteste.lb-ap.etica.ai
curl http://js.usuariodeteste.apb.etica.ai
curl http://js.usuariodeteste.lb-ap.etica.ai

## Certificado HTTPS para usuariodeteste
# Linha de comando para obter certificados. Automaticamente já edita configurações do NGinx
# Nota: o subdominio de lb-ap via HTTPS ainda não sera adicionado, veja https://github.com/fititnt/cplp-aiops/issues/35#issuecomment-495508373
sudo certbot --nginx -d usuariodeteste.apb.etica.ai
sudo certbot --nginx -d php.usuariodeteste.apb.etica.ai

#------------------------------------------------------------------------------#
# SEÇÃO 1.1: USUÁRIOS DO SISTEMA - MENSAGENS INFORMATIVAS                      #
#                                                                              #
# TL;DR: Modelo padrão para copiar e colar e informar os usuários desde        #
#        servidor sobre criação de conta, edição, etc.                         #
#                                                                              #
# AVISO: esta sessão pode ser ignorada. Está aqui se você pretende realmente   #
#        dar acesso a contas SSHs para usuários novos terem uma visão geral.   #
#        Está aqui porque um ds propósitos dos servidores Águia Pescadora é    #
#        dar acesso a usuários em um sistema Linux Ubuntu Server (e "mais      #
#        simples" do que o github.com/fititnt/chatops-wg 2018/01 que usava     #
#        Docker)                                                               #
#------------------------------------------------------------------------------#

##### Conta de usuário criada __________________________________________________
# Nota: começa inclua no inicio "```bash" e no fim "``"
# Inicio
: '

```bash
#### Dados da sua conta NomeUsuario em https://aguia-pescadora-bravo.etica.ai

### Seus dados
# Usuário: NomeUsuario
# Senha (temporaria): troque-me@NomeUsuario#OutrosCaracteresAqui
# fscrypt + Linux-PAM em /home/NomeUsuario: NÃO
# Servidor: aguia-pescadora-bravo.etica.ai
# Servidor: apb.etica.ai

### Atalhos para fazer login
## Via interface de linha de comando ("CLI"), use uma das opções
# SSH:
ssh NomeUsuario@aguia-pescadora-bravo.etica.ai
ssh NomeUsuario@apb.etica.ai

# Mosh: (Mobile Shell), alternativa para internet intermitente, veja mosh.org
mosh NomeUsuario@aguia-pescadora-bravo.etica.ai
mosh NomeUsuario@apb.etica.ai

# Dropbear: opção não instalada neste momento
# Multi-Factor Authentication (i.e. 2FA): opção não instalada neste momento

## Comando para trocar sua senha de usuario a qualquer momento:
passwd

### Seus sites
# Nota: estes domínios são padrões criados para dar um início rápido. Porém
#       nos fortemente recomendamos você poder usar seus próprios domínios
#       customizados, de modo que possa usá-los até mesmo fora de nossos
#       servidores comunitários
#
# - http://NomeUsuario.apb.etica.ai (HTTP, principal, apontado para Bravo)
# - https://NomeUsuario.apb.etica.ai (HTTPS, principal, apontado para Bravo)
# - http://NomeUsuario.lb-ap.etica.ai (HTTP, principal, balanceador de carga)
#     - Veja: https://github.com/fititnt/cplp-aiops/issues/40

############################ GUIA RÁPIDO AO USUÁRIO ############################
##### Programas úteis para usar ________________________________________________
# NOTA: existem outras opções; aqui são recomendações que podemos dar ajuda
#       extra caso tenha problema.
#
#### Android
## Android 1.6+
# - Via CLI (inclui terminal, login SSH e suporte a geração de chaves privadas)
#     - ConnectBot
#         - Recomendado! Mesmo que tenha Android 5.0 e Termux
#         - <https://play.google.com/store/apps/details?id=org.connectbot>
## Android 5.0+
# - Via CLI (inclui terminal, login SSH e suporte a geração de chaves privadas)
#     - Termux
#         - Terminal amigável (até mais do que os de Windows e certos Linux!)
#         - <https://play.google.com/store/apps/details?id=com.termux>
#         - pkg install openssh
#
#### Linux
# - Login SSH:
#     - openssh
#
#### MacOS
# - Login SSH:
#     - Seu terminal padrão provavelmente já tem ssh instalado (requer feedback)
#
#### Windows
# - Login SSH (já com emulador de terminal inclusos)
#     - Git For Windows <https://gitforwindows.org/> (Ideal)
#     - Putty <https://www.putty.org/> (alternativa)
#
##### Perguntas frequêntes _____________________________________________________
### Não estou conseguindo logar na máquina, mesmo com esse guia
# - Fale com a pessoa que entregou os seus dados (e sim, isso é comum)
#
### Perdi minha senha de usuario, e agora? (sem fscrypt)
# - Solicite a um administrador resetar sua senha para uma temporária
#
### Perdi minha senha de usuario, e agora? (com fscrypt)
# - Solicite a um administrador resetar sua senha para uma temporária. Note que:
#      - Arquivos: /home/NomeUsuario: permanecerão encriptados com senha antiga
#      - Arquivos: /home2/NomeUsuario: acessíveis
#      - Arquivos seus em outros diretórios: acessíveis
# - Nota: mesmo com fscrypt ativado sua chave privada, 2FA, etc não são usados
#   como senha na encriptação do seu /home/NomeUsuario
### Perdi minha senha de usuario, e agora? (com fscrypt)
# - Solicite a um administrador resetar sua senha para uma temporária. Note que:
#      - Arquivos: /home/NomeUsuario: permanecerão encriptados com senha antiga
#      - Arquivos: /home2/NomeUsuario: acessíveis
#      - Arquivos seus em outros diretórios: acessíveis
# - Nota: mesmo com fscrypt ativado sua chave privada, 2FA, etc não são usados
#   como senha na encriptação do seu /home/NomeUsuario
### Perdi minha senha de root, e agora?
# - Fale com outro usuário com acesso root
# - Se todos os usuários perderem acesso root, é preciso fazer acesso via KVM,
#   vide https://docs.ovh.com/pt/vps/utilizar_o_kvm_para_um_servidor_vps/
```

'
# Fim

#------------------------------------------------------------------------------#
# SEÇÃO 2.0: EDITORES DE TEXTO, EDITORES DE CÓDIGO, IDES                       #
#                                                                              #
# TL;DR: Programas do lado do servidor que permitem  programar                 #
#------------------------------------------------------------------------------#

##### Emacs ____________________________________________________________________
# @see https://www.gnu.org/s/emacs/
# @see https://www.emacswiki.org/emacs/NovatoNoEmacs
# ...

sudo apt install emacs

# Resultado do comando acima:
# (...)
#
# Serão instalados os seguintes NOVOS pacotes:
#   adwaita-icon-theme at-spi2-core dconf-gsettings-backend dconf-service emacs emacs25 emacs25-bin-common emacs25-common emacs25-el emacsen-common fontconfig fontconfig-config fonts-dejavu-core fonts-droid-fallback fonts-noto-mono
#   ghostscript glib-networking glib-networking-common glib-networking-services gsettings-desktop-schemas gsfonts gtk-update-icon-cache hicolor-icon-theme humanity-icon-theme imagemagick-6-common libasound2 libasound2-data
#   libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2 libcairo2 libcolord2 libcroco3 libcups2 libcupsfilters1 libcupsimage2 libdatrie1 libdconf1
#   libepoxy0 libfftw3-double3 libfontconfig1 libgd3 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-bin libgdk-pixbuf2.0-common libgif7 libgraphite2-3 libgs9 libgs9-common libgtk-3-0 libgtk-3-bin libgtk-3-common libharfbuzz0b libice6 libijs-0.35
#   libjbig0 libjbig2dec0 libjpeg-turbo8 libjpeg8 libjson-glib-1.0-0 libjson-glib-1.0-common liblcms2-2 liblockfile-bin liblockfile1 liblqr-1-0 libltdl7 libm17n-0 libmagickcore-6.q16-3 libmagickwand-6.q16-3 libotf0 libpango-1.0-0
#   libpangocairo-1.0-0 libpangoft2-1.0-0 libpaper-utils libpaper1 libpixman-1-0 libproxy1v5 librest-0.7-0 librsvg2-2 librsvg2-common libsm6 libsoup-gnome2.4-1 libsoup2.4-1 libthai-data libthai0 libtiff5 libwayland-client0
#   libwayland-cursor0 libwayland-egl1 libwebp6 libx11-xcb1 libxcb-render0 libxcb-shm0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxft2 libxi6 libxinerama1 libxkbcommon0 libxpm4 libxrandr2 libxrender1 libxt6 libxtst6 m17n-db
#   poppler-data ubuntu-mono x11-common
# 0 pacotes actualizados, 115 pacotes novos instalados, 0 a remover e 0 não actualizados.
# É necessário obter 64,7 MB de arquivos.
# Após esta operação, serão utilizados 239 MB adicionais de espaço em disco.

##### Nano _____________________________________________________________________
# @see https://www.nano-editor.org/

# Nota: Nano já veio instalado com o Ubuntu 18.04. Por isso não há comandos aqui

# @TODO considerar configurações extras do Nano, como realce de sintaxe. Vou
#       ser sincero e admitir que eu nunca precisei ir a fundo em configuração
#       do Nano (fititnt, 2019-05-18 21:01 BRT)

##### NeoVim ___________________________________________________________________
# @see https://neovim.io/
# @see https://www.youtube.com/watch?v=kZDT10nFiTY

## Instalando NeoVim do PPA, que já tem o 0.3+ (O do Ubuntu 18.04 é 0.2)
# @see https://github.com/neovim/neovim/wiki/Installing-Neovim#ubuntu
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim

# Resultado do comando acima:
# (...)
#
# Serão instalados os seguintes NOVOS pacotes:
#   libjs-sphinxdoc libluajit-5.1-2 libluajit-5.1-common libmsgpackc2 libtermkey1 libunibilium4 libvterm0 neovim neovim-runtime python-concurrent.futures python-greenlet python-msgpack python-neovim python-six python-trollius
#   python3-greenlet python3-msgpack python3-neovim
# 0 pacotes actualizados, 18 pacotes novos instalados, 0 a remover e 5 não actualizados.
# É necessário obter 5494 kB de arquivos.
# Após esta operação, serão utilizados 24,1 MB adicionais de espaço em disco.
# Deseja continuar? [S/n]


##### Vi/Vim ___________________________________________________________________

# Nota: Vi/Vim  já veio instalado com o Ubuntu 18.04. Por isso não há comandos aqui

# @TODO considerar configurações extras do Vi/Vim, como realce de sintaxe. Vou
#       ser sincero e admitir que eu nunca precisei ir a fundo em configuração
#       do Vi/Vim. O máximo que já fiz foi copiar configurações de alguém mais
#       hardcore do que eu (fititnt, 2019-05-18 21:01 BRT)

# @TODO considerar por vim-sensible como padrão https://github.com/tpope/vim-sensible
#       (fititnt, 2019-05-20 06:55 BRT)

#------------------------------------------------------------------------------#
# SEÇÃO 3.0: AMBIENTES DE DESENVOLVIMENTO: REQUISITOS DE MULTIPLOS AMBIENTES   #
#                                                                              #
# TL;DR: Certos ambientes de linguagens de programação tem dependências comuns #
#        até mesmo para interpretar/compilar um hello world. Você verá aqui:   #
#            - Gerenciadores de pacotes (os usados por mais de uma linguagem)  #
#            - Gerenciadores de SDKs                                           #
#                                                                              #
# AVISO: esta sessão pode ser ignorada completamente quando:                   #
#            - Não são dependência de linguagem que você usa da [SEÇÃO 4.0]    #
#            - Você optou por instalar um ambiente da [SEÇÃO 4.0] sem depender #
#              explicitamente destes requisitos usando algum guia externo      #
#                                                                              #
# PROTIP: se está com pressa, rode a [SEÇÃO 4.0] nas linguagens que quer usar  #
#         e só volte para ler esta [SEÇÃO 3.0] se comandos falharem. Lembre-se #
#         que este guia foi escrito de forma não linear                        #
#------------------------------------------------------------------------------#

##### C/C++ (quando usado para compilar outros pacotes do fonte) _______________
# @TODO explicar que C/C++ da [SEÇÃO 4.0] poderia ser requisito
#      (fititnt, 2019-05-23 04:51 BRT)

##### Mono _____________________________________________________________________
# @see https://github.com/fititnt/cplp-aiops/issues/36
# Ambientes de desenvolvimento potencialmente afetados:
#     - C#
#     - F#
#     - (listar explicitamente outros aqui...)

# @see https://www.mono-project.com/download/stable/#download-lin-ubuntu
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
sudo apt install mono-devel

# Resultado do comando anterior:
# (...)
# Serão instalados os seguintes NOVOS pacotes:
#   ca-certificates-mono cli-common libexif12 libgdiplus libmono-2.0-dev libmono-accessibility4.0-cil libmono-btls-interface4.0-cil libmono-cairo4.0-cil libmono-cecil-private-cil libmono-cil-dev libmono-codecontracts4.0-cil
#   libmono-compilerservices-symbolwriter4.0-cil libmono-corlib4.5-cil libmono-cscompmgd0.0-cil libmono-csharp4.0c-cil libmono-custommarshalers4.0-cil libmono-data-tds4.0-cil libmono-db2-1.0-cil libmono-debugger-soft4.0a-cil
#   libmono-http4.0-cil libmono-i18n-cjk4.0-cil libmono-i18n-mideast4.0-cil libmono-i18n-other4.0-cil libmono-i18n-rare4.0-cil libmono-i18n-west4.0-cil libmono-i18n4.0-all libmono-i18n4.0-cil libmono-ldap4.0-cil
#   libmono-management4.0-cil libmono-messaging-rabbitmq4.0-cil libmono-messaging4.0-cil libmono-microsoft-build-engine4.0-cil libmono-microsoft-build-framework4.0-cil libmono-microsoft-build-tasks-v4.0-4.0-cil
#   libmono-microsoft-build-utilities-v4.0-4.0-cil libmono-microsoft-build4.0-cil libmono-microsoft-csharp4.0-cil libmono-microsoft-visualc10.0-cil libmono-microsoft-web-infrastructure1.0-cil libmono-oracle4.0-cil
#   libmono-parallel4.0-cil libmono-peapi4.0a-cil libmono-posix4.0-cil libmono-rabbitmq4.0-cil libmono-relaxng4.0-cil libmono-security4.0-cil libmono-sharpzip4.84-cil libmono-simd4.0-cil libmono-smdiagnostics0.0-cil
#   libmono-sqlite4.0-cil libmono-system-componentmodel-composition4.0-cil libmono-system-componentmodel-dataannotations4.0-cil libmono-system-configuration-install4.0-cil libmono-system-configuration4.0-cil
#   libmono-system-core4.0-cil libmono-system-data-datasetextensions4.0-cil libmono-system-data-entity4.0-cil libmono-system-data-linq4.0-cil libmono-system-data-services-client4.0-cil libmono-system-data-services4.0-cil
#   libmono-system-data4.0-cil libmono-system-deployment4.0-cil libmono-system-design4.0-cil libmono-system-drawing-design4.0-cil libmono-system-drawing4.0-cil libmono-system-dynamic4.0-cil libmono-system-enterpriseservices4.0-cil
#   libmono-system-identitymodel-selectors4.0-cil libmono-system-identitymodel4.0-cil libmono-system-io-compression-filesystem4.0-cil libmono-system-io-compression4.0-cil libmono-system-json-microsoft4.0-cil
#   libmono-system-json4.0-cil libmono-system-ldap-protocols4.0-cil libmono-system-ldap4.0-cil libmono-system-management4.0-cil libmono-system-messaging4.0-cil libmono-system-net-http-formatting4.0-cil
#   libmono-system-net-http-webrequest4.0-cil libmono-system-net-http4.0-cil libmono-system-net4.0-cil libmono-system-numerics-vectors4.0-cil libmono-system-numerics4.0-cil libmono-system-reactive-core2.2-cil
#   libmono-system-reactive-debugger2.2-cil libmono-system-reactive-experimental2.2-cil libmono-system-reactive-interfaces2.2-cil libmono-system-reactive-linq2.2-cil libmono-system-reactive-observable-aliases0.0-cil
#   libmono-system-reactive-platformservices2.2-cil libmono-system-reactive-providers2.2-cil libmono-system-reactive-runtime-remoting2.2-cil libmono-system-reactive-windows-forms2.2-cil
#   libmono-system-reactive-windows-threading2.2-cil libmono-system-reflection-context4.0-cil libmono-system-runtime-caching4.0-cil libmono-system-runtime-durableinstancing4.0-cil
#   libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime-serialization4.0-cil libmono-system-runtime4.0-cil libmono-system-security4.0-cil libmono-system-servicemodel-activation4.0-cil
#   libmono-system-servicemodel-discovery4.0-cil libmono-system-servicemodel-internals0.0-cil libmono-system-servicemodel-routing4.0-cil libmono-system-servicemodel-web4.0-cil libmono-system-servicemodel4.0a-cil
#   libmono-system-serviceprocess4.0-cil libmono-system-threading-tasks-dataflow4.0-cil libmono-system-transactions4.0-cil libmono-system-web-abstractions4.0-cil libmono-system-web-applicationservices4.0-cil
#   libmono-system-web-dynamicdata4.0-cil libmono-system-web-extensions-design4.0-cil libmono-system-web-extensions4.0-cil libmono-system-web-http-selfhost4.0-cil libmono-system-web-http-webhost4.0-cil
#   libmono-system-web-http4.0-cil libmono-system-web-mobile4.0-cil libmono-system-web-mvc3.0-cil libmono-system-web-razor2.0-cil libmono-system-web-regularexpressions4.0-cil libmono-system-web-routing4.0-cil
#   libmono-system-web-services4.0-cil libmono-system-web-webpages-deployment2.0-cil libmono-system-web-webpages-razor2.0-cil libmono-system-web-webpages2.0-cil libmono-system-web4.0-cil
#   libmono-system-windows-forms-datavisualization4.0a-cil libmono-system-windows-forms4.0-cil libmono-system-windows4.0-cil libmono-system-workflow-activities4.0-cil libmono-system-workflow-componentmodel4.0-cil
#   libmono-system-workflow-runtime4.0-cil libmono-system-xaml4.0-cil libmono-system-xml-linq4.0-cil libmono-system-xml-serialization4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libmono-tasklets4.0-cil
#   libmono-webbrowser4.0-cil libmono-webmatrix-data4.0-cil libmono-windowsbase4.0-cil libmono-xbuild-tasks4.0-cil libmonosgen-2.0-1 libmonosgen-2.0-dev libnunit-cil-dev libnunit-console-runner2.6.3-cil
#   libnunit-core-interfaces2.6.3-cil libnunit-core2.6.3-cil libnunit-framework2.6.3-cil libnunit-mocks2.6.3-cil libnunit-util2.6.3-cil mono-4.0-gac mono-csharp-shell mono-devel mono-gac mono-llvm-support mono-llvm-tools mono-mcs
#   mono-roslyn mono-runtime mono-runtime-common mono-runtime-sgen mono-xbuild msbuild msbuild-libhostfxr msbuild-sdkresolver referenceassemblies-pcl
# 0 pacotes actualizados, 169 pacotes novos instalados, 0 a remover e 10 não actualizados.
# É necessário obter 77,8 MB de arquivos.
# Após esta operação, serão utilizados 349 MB adicionais de espaço em disco.

## NOTA: demorou uns 4-7 minutos em Bravo. Teve que compilar algumas coisas
#        Apesar de ter 2 cores, a compilação usou apenas 1 (e ficou 100%)
#        no momento de compilar (fititnt, 2019-05-23 04:03 BRT)

# @TODO descobrir como rodar hello world de VB.net e C#. Numa olhada
#       rápida na internet, seria algo como 'dotnet run' mas parece
#       seria outro site para instalar isso

# @TODO: criar os hello world no repositório de tutoriais, vide
#        https://www.mono-project.com/docs/getting-started/mono-basics/
#        (fititnt, 2019-05-23 BRT)

##### Snap _____________________________________________________________________
# @see https://snapcraft.io/
#
# Ambientes de desenvolvimento potencialmente afetados:
#     - Go

# Nota, snap já veio instalado no Ubuntu Server 18.04, porém o caminho
# '/snap/bin' não está adicionada em /etc/environment para ser carregado por
# padrão.

sudo cp /etc/environment /etc/environment.bkp

sudo echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' > /etc/environment

sudo snap install --classic go

#------------------------------------------------------------------------------#
# SEÇÃO 4.0: AMBIENTES DE DESENVOLVIMENTO: LINGUAGENS DE PROGRAMAÇÃO           #
#                                                                              #
# TL;DR: Configurações específicas de interpretadores e/ou compiladores        #
#                                                                              #
# PROTIP: se você seguiu a PROTIP da [SEÇÃO 3.0] (de ignorá-la completamente)  #
#         e algo aqui falhar, você pode optar por ler a [SEÇÃO 3.0] ou         #
#         pesquisar uma solução mais específica e exclusiva apenas para sua    #
#         linguagem.                                                           #
#------------------------------------------------------------------------------#

## Ambientes a serem considerados...
# Julia (nao tem package manager oficial) https://julialang.org
# Rust https://www.rust-lang.org/tools/install
# Conda (multiplos usuarios; nao vai ser trivial)
#   <https://medium.com/@pjptech/installing-anaconda-for-multiple-users-650b2a6666c6>
#   <https://www.digitalocean.com/community/tutorials/how-to-install-anaconda-on-ubuntu-18-04-quickstart>
#   <https://stackoverflow.com/questions/48871289/how-to-share-an-anaconda-python-environment-between-multiple-users>
#   <https://medium.freecodecamp.org/why-you-need-python-environments-and-how-to-manage-them-with-conda-85f155f4353c>
#   <https://docs.anaconda.com/anaconda/install/>
#   <https://hub.docker.com/r/continuumio/anaconda3/dockerfile>
# ML .Net
#   - <https://dotnet.microsoft.com/learn/machinelearning-ai/ml-dotnet-get-started-tutorial/install>

##### C/C++ ____________________________________________________________________
# Inclui bibliotecas extras para compilar outras ferramentas

## @see https://linuxconfig.org/how-to-install-gcc-the-c-compiler-on-ubuntu-18-04-bionic-beaver-linux

sudo apt install gcc build-essential
# Serão instalados os seguintes NOVOS pacotes:
#  binutils binutils-common binutils-x86-64-linux-gnu build-essential cpp cpp-7 dpkg-dev fakeroot g++ g++-7 gcc gcc-7 gcc-7-base libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan4 libatomic1 libbinutils
#  libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdpkg-perl libfakeroot libfile-fcntllock-perl libgcc-7-dev libgomp1 libisl19 libitm1 liblsan0 libmpc3 libmpx2 libquadmath0 libstdc++-7-dev libtsan0 libubsan0 linux-libc-dev make
#  manpages-dev
#
#  É necessário obter 37,1 MB de arquivos.
#  Após esta operação, serão utilizados 161 MB adicionais de espaço em disco.

##### Go _______________________________________________________________________
# @see https://golang.org/
# @see https://github.com/golang/go/wiki/Ubuntu

# Esta forma instala versão mais atual estável de Go.
sudo snap install --classic go

##### JavaScript/NodeJS ________________________________________________________
#

# @see https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-18-04
sudo apt install nodejs
# Resultado:
# (...)
# Serão instalados os seguintes NOVOS pacotes:
#    libc-ares2 libhttp-parser2.7.1 nodejs nodejs-doc
#  É necessário obter 5606 kB de arquivos.
#  Após esta operação, serão utilizados 24,7 MB adicionais de espaço em disco.

sudo apt install npm
# Resultado:
# (...)
# Serão instalados os seguintes NOVOS pacotes:
#   gyp libjs-async libjs-inherits libjs-node-uuid libjs-underscore libssl1.0-dev libuv1-dev node-abbrev node-ansi node-ansi-color-table node-archy node-async node-balanced-match node-block-stream node-brace-expansion
#   node-builtin-modules node-combined-stream node-concat-map node-cookie-jar node-delayed-stream node-forever-agent node-form-data node-fs.realpath node-fstream node-fstream-ignore node-github-url-from-git node-glob node-graceful-fs
#   node-gyp node-hosted-git-info node-inflight node-inherits node-ini node-is-builtin-module node-isexe node-json-stringify-safe node-lockfile node-lru-cache node-mime node-minimatch node-mkdirp node-mute-stream node-node-uuid
#   node-nopt node-normalize-package-data node-npmlog node-once node-osenv node-path-is-absolute node-pseudomap node-qs node-read node-read-package-json node-request node-retry node-rimraf node-semver node-sha node-slide
#   node-spdx-correct node-spdx-expression-parse node-spdx-license-ids node-tar node-tunnel-agent node-underscore node-validate-npm-package-license node-which node-wrappy node-yallist nodejs-dev npm
# 0 pacotes actualizados, 71 pacotes novos instalados, 0 a remover e 0 não actualizados.
# É necessário obter 4176 kB de arquivos.
# Após esta operação, serão utilizados 23,6 MB adicionais de espaço em disco.

# @TODO considerar documentar aos usuarios iniciantes como eles podem usar
#       versões mais customizadas caso as de sistema não sejam suficientes
#       (fititnt, 2019-05-18 21:21 BRT)

##### Lisp _____________________________________________________________________
# @see https://lisp-lang.org/
# @see https://lisp-lang.org/learn/getting-started/
# Hello World:
#   sbcl --script lisp.lsp

sudo apt-get install sbcl
# Resultado:
# (...)
# Serão instalados os seguintes NOVOS pacotes:
#   binfmt-support sbcl
# 0 pacotes actualizados, 2 pacotes novos instalados, 0 a remover e 8 não actualizados.
# É necessário obter 8632 kB de arquivos.
# Após esta operação, serão utilizados 47,7 MB adicionais de espaço em disco

##### PHP ______________________________________________________________________
# @see https://github.com/fititnt/cplp-aiops/issues/7
# @see https://github.com/fititnt/cplp-aiops/issues/41
# @see https://php.net/
# @see https://www.php.net/manual/pt_BR/

## PHP 7.2
sudo apt install php-cli php-common
# Resultado do comando acima:
# (...)
# Serão instalados os seguintes NOVOS pacotes:
#   libsodium23 php-cli php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline
# 0 pacotes actualizados, 8 pacotes novos instalados, 0 a remover e 0 não actualizados.
# É necessário obter 2644 kB de arquivos.
# Após esta operação, serão utilizados 12,7 MB adicionais de espaço em disco.

# @TODO adicionar multiplas versões de PHP, não apenas a 7.2
#       (fititnt, 2019-05-18 21:22 BRT)

## PHP 7.2, para web -----------------------------------------------------------
# @see https://github.com/fititnt/cplp-aiops/issues/7
sudo apt install php-fpm

sudo systemctl start php7.2-fpm
sudo systemctl enable php7.2-fpm
# AVISO: o sistema tem um PHP-FPM padrão que roda com www-data, que pode servir
#        para casos simples. Porém o recomendado é que cada usuário e projeto
#        tenha seu próprio worker de PHP-FPM

# Nota: arquivo /etc/php/7.2/fpm/pool.d/www.conf pode precisar de ajuste para
#       usar o log a seguir
sudo touch /var/log/fpm-php.www.log
sudo chown www-data:www-data /var/log/fpm-php.www.log

## Acompanhar logs de erros comuns (usados caso usuario não especifique)
sudo tail -f /var/log/fpm-php.www.log
sudo tail -f /etc/nginx/error.log
sudo tail -f /etc/nginx/access.log

## Composer --------------------------------------------------------------------
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

sudo rm composer-setup.php

# @TODO: implementar alguma forma de auto update no binario do composer padrão
#        de sistema (mesmo que os usuários possam sobrescrever)
#        (fititnt, 2019-05-29 23:46 BRT)

##### Python ___________________________________________________________________
# @see https://www.python.org/
# @see https://pypi.org/
# @see https://docs.python.org/3/

## Testes previos antes de instalar o python...
## python --version
# Python 2.7.15rc1
#
## python2 --version
# Python 2.7.15rc1
#
## python3 --version
# Python 3.6.7

# NOTA: O ubuntu 18.04 já vem com Python 3 instalado por padrão em vez do 2.7
#       Vamos procurar deixar com que 'python' tenda a retornar a versão sempre
#       mais recente, porém dar alternativa de ter pelo menos python 2.7.
#       Exceto se isso for quebrar mais coisas... (fititnt, 2019-05-18 21:36 BRT)

# @TODO ver com mais calma versoes padroes do python. Ja se tem disponivel
#       nos repositorios principais a 3.7 (fititnt, 2019-05-18 21:40 BRT)

##### R ________________________________________________________________________
# @see https://www.r-project.org/
# @see https://pt.wikipedia.org/wiki/R_(linguagem_de_programa%C3%A7%C3%A3o)
# @see https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-18-04
# @see https://cran.r-project.org/bin/linux/ubuntu/README.html

# R vai requerer adicionar um repositorio que não é tão atualizado no Ubuntu
# Isto aqui prepara para importar o repositório oficial
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt update

sudo apt install r-base
# Resultado do comando acima:
# (...)
# Serão instalados os seguintes NOVOS pacotes:
#   bzip2-doc gfortran gfortran-7 gir1.2-harfbuzz-0.0 icu-devtools libauthen-sasl-perl libblas-dev libblas3 libbz2-dev libdata-dump-perl libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libencode-locale-perl
#   libfile-basedir-perl libfile-desktopentry-perl libfile-listing-perl libfile-mimeinfo-perl libfont-afm-perl libfontenc1 libgfortran-7-dev libgfortran4 libgl1 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libglib2.0-bin libglib2.0-dev
#   libglib2.0-dev-bin libglvnd0 libglx-mesa0 libglx0 libgraphite2-dev libharfbuzz-dev libharfbuzz-gobject0 libharfbuzz-icu0 libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl
#   libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libicu-dev libicu-le-hb-dev libicu-le-hb0 libiculx60 libio-html-perl libio-socket-ssl-perl libipc-system-simple-perl libjpeg-dev
#   libjpeg-turbo8-dev libjpeg8-dev liblapack-dev liblapack3 libllvm7 liblwp-mediatypes-perl liblwp-protocol-https-perl liblzma-dev libmailtools-perl libncurses5-dev libnet-dbus-perl libnet-http-perl libnet-smtp-ssl-perl
#   libnet-ssleay-perl libpciaccess0 libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libpng-dev libpng-tools libreadline-dev libsensors4 libtcl8.6 libtie-ixhash-perl libtimedate-perl libtinfo-dev libtk8.6 libtry-tiny-perl liburi-perl
#   libwww-perl libwww-robotrules-perl libx11-protocol-perl libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-shape0 libxcb-sync1 libxml-parser-perl libxml-twig-perl libxml-xpathengine-perl libxmu6 libxshmfence1
#   libxss1 libxv1 libxxf86dga1 libxxf86vm1 perl-openssl-defaults pkg-config python3-distutils python3-lib2to3 r-base r-base-core r-base-dev r-base-html r-cran-boot r-cran-class r-cran-cluster r-cran-codetools r-cran-foreign
#   r-cran-kernsmooth r-cran-lattice r-cran-mass r-cran-matrix r-cran-mgcv r-cran-nlme r-cran-nnet r-cran-rpart r-cran-spatial r-cran-survival r-doc-html r-recommended unzip x11-utils x11-xserver-utils xdg-utils zip zlib1g-dev
# 0 pacotes actualizados, 135 pacotes novos instalados, 0 a remover e 2 não actualizados.
# É necessário obter 97,2 MB de arquivos.
# Após esta operação, serão utilizados 416 MB adicionais de espaço em disco.

#------------------------------------------------------------------------------#
# SEÇÃO 4.5: AMBIENTES DE DESENVOLVIMENTO: ACESSO A BANDOS DE DADOS EXTERNOS   #
#                                                                              #
# TL;DR: Alguns bancos de dados permitem instalar pacotes para gerenciamento   #
#        por linha de comando sem precisar instalar o próprio banco de dados   #
#------------------------------------------------------------------------------#

##### MariaDB (apenas cliente) _________________________________________________
### O objetivo aqui é ter do lado do cliente os pacotes mínimos para contectar
### ao cluster Elevante Bornéu
# @see elefante-borneu-yul-01.sh (arquivo de configuração dos Elevante Bornéu)

sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'

# Em Águia Pescadora devemos instalar APENAS os cliente de MariaDB/MySQL
sudo apt install mariadb-client

## Teste se o usuario do haproxy consegue acessar
mysql -h elefante-borneu-yul-01.etica.ai -u haproxy

##### MongoDB lado do cliente (mongodb-org-shell, mongodb-org-tools) ___________
# AVISO: instale APENAS 'mongodb-org-shell' e 'mongodb-org-tools'. Não é
#        necessário instalar 'mongodb-org-server' ou o 'mongodb-org'

## Configurar pacotes
# @see https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb-community-edition-using-deb-packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt update

sudo apt install mongodb-org-shell mongodb-org-tools

# Teste conexcao
mongo --host elefante-borneu-yul-01.etica.ai:27017

##### Redis lado do cliente (redis-tools) ______________________________________
sudo apt install redis-tools

#### Testar com redis-cli
redis-cli
ping
# Resposta deve ser: PONG
set test "It's working!"
get test
# Resposta deve ser "It's working!"

# Nota: pode testar também especificando o host (util para testar o HAProxy)
# redis-cli -h elefante-borneu-yul-01.etica.ai

#------------------------------------------------------------------------------#
# SEÇÃO 5.0: BALANCEAMENTO DE CARGA PARA SERVIÇOS EXTERNOS COM HAPROXY         #
#                                                                              #
# TL;DR: alguns serviços importantes não são instalados nesta máquina, mas em  #
#        algum servidor externo. Estratégias com uso de HAProxy podem permitir #
#        abstração dessa complexidade para os usuarios                         #
#------------------------------------------------------------------------------#

##### HAProxy __________________________________________________________________

sudo apt install haproxy

vim /etc/haproxy/haproxy.cfg
# Fazer ajustes...

vim /etc/nginx/sites-available/haproxy.apb.etica.ai.conf
# Adicione todas as customizacoes no arquivo acima...

sudo ln -s /etc/nginx/sites-available/haproxy.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d haproxy.apb.etica.ai

##### HAProxy, como testar atualizacoes ANTES de implementar -------------------

# Use o comando a seguir para testar se o arquivo /etc/haproxy/haproxy.cfg
# poderá impedir que dar reload cause falha critica
sudo haproxy -f /etc/haproxy/haproxy.cfg -c
#sudo service haproxy configtest

# Então aplique usando reload (melhor do que usar sudo systemctl restart haproxy)
sudo systemctl reload haproxy

## Teste se o usuario do haproxy consegue acessar
mysql -h elefante-borneu-yul-01.etica.ai -u haproxy

#------------------------------------------------------------------------------#
# SEÇÃO 5.5: FERRAMENTAS PARA GERENCIAMENTO ADMINISTRATIVO DE DADOS            #
#                                                                              #
# TL;DR: PHPMyAdmin, etc                                                       #
#                                                                              #
# URLS: - https://phpmyadmin.apb.etica.ai/                                     #
#------------------------------------------------------------------------------#

#### PHPMyAdmin ________________________________________________________________
### @see https://github.com/fititnt/cplp-aiops/issues/53

## Vamos usar o que vem por padrão no Ubuntu 18.04
# @see https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-18-04
# @see https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-ubuntu-16-04

sudo apt install phpmyadmin

sudo cp /etc/php/7.2/fpm/pool.d/USUARIO.conf.EXEMPLO /etc/php/7.2/fpm/pool.d/phpmyadmin.conf
sudo vim /etc/php/7.2/fpm/pool.d/phpmyadmin.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo php-fpm7.2 --test # Valide se configurações são validas (sim, esse nome)
sudo systemctl reload php7.2-fpm

sudo cp /etc/nginx/sites-available/EXEMPLO-PROXY.abp.etica.ai.conf /etc/nginx/sites-available/phpmyadmin.apb.etica.ai.conf
sudo vim /etc/nginx/sites-available/phpmyadmin.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/phpmyadmin.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t  # Valide se configurações NGinx são validas (sim, esse nome)
sudo systemctl reload nginx

sudo certbot --nginx -d phpmyadmin.apb.etica.ai

## Hotfix erro "Warning in ./libraries/sql.lib.php#613 count(): Parameter must be an array or an object that implements Countable"
# @see https://stackoverflow.com/questions/48001569/phpmyadmin-count-parameter-must-be-an-array-or-an-object-that-implements-co/50536059#50536059
# Caso tenha esse erro execute uma vez logo após instalação:
sudo sed -i "s/|\s*\((count(\$analyzed_sql_results\['select_expr'\]\)/| (\1)/g" /usr/share/phpmyadmin/libraries/sql.lib.php


# TODO: por alguma proteção, mesmo que simples, para evitar bruteforce de bots
#       em https://phpmyadmin.apb.etica.ai/ (fititnt, 2019-05-21 00:23 BRT)

#------------------------------------------------------------------------------#
# SEÇÃO 6.0: GERENCIAMENTO DE PROCESSOS                                        #
#                                                                              #
# TL;DR: caso alguns usuários queiram que algo rode ao reiniciar o sistema ou  #
#        periodicamente esta seção do documento dá uma alternativa genérica    #
#        de gerenciamento e monitoramento                                      #
#------------------------------------------------------------------------------#

##### Monit ____________________________________________________________________
# @see https://github.com/fititnt/cplp-aiops/issues/44

# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-monit
sudo apt install monit

sudo systemctl enable monit
sudo systemctl start monit

vim /etc/nginx/sites-available/monit.abp.etica.ai.conf
# Adicione as configurações do monit...
sudo vim /etc/nginx/sites-available/monit.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

# Aqui criamos uma pasta "compartilhada" para depois permitir que usuarios
# possam editar algumas coisas no que o monit monitora
sudo mkdir -p /home2/_compartilhado

sudo vim /home2/_compartilhado/ips-aceitavelmente-confiaveis.conf
# NOTA: restrição baseada apenas em IPs deve ser feita com muito cuidado.
#       no nosso caso qualquer pessoa poderia acessar o monitoramento do Monit
#       via localhost, o que implica todos que tem acesso de conta SSH comum.
#       Isso não chega a ser um problema se confiamos nas pessoas, mas é algo
#       que precisa aplicações que eles e que dão acesso simulando localhost
#       podem dar problema. (fititnt, 2019-05-25 09:56 BRT)

sudo ln -s /etc/nginx/sites-available/monit.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d monit.apb.etica.ai

# Copia alguns arquivos padroes do monit e os habilita
sudo ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled

sudo systemctl reload monit

# Aqui criamos uma pasta "compartilhada" para depois permitir que usuarios
# possam editar algumas coisas no que o monit monitora
sudo mkdir -p /home2/_compartilhado/monit/conf-enabled/

##### Supervisord ____________________________________________________________________
# @see https://github.com/fititnt/cplp-aiops/issues/44

# @see http://supervisord.org/installing.html
sudo apt-cache show supervisor
# Candidato: 3.3.1-1.1 (versão mais seria a 4.0.3)

sudo apt install supervisor
sudo systemctl enable supervisor
sudo systemctl start supervisor

# Aqui criamos uma pasta "compartilhada" para depois permitir que usuarios
# possam editar algumas coisas no que o supervisord monitora
sudo mkdir -p /home2/_compartilhado/supervisor/conf-enabled

sudo systemctl reload supervisor

sudo vim /etc/nginx/sites-available/supervisor.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/supervisor.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d supervisor.apb.etica.ai

#------------------------------------------------------------------------------#
# SEÇÃO: ROTAS PARA AGUIA PESCADORA CHARLIE                                    #
# TL;DR: Algumas aplicações estão em aguia-pescadora-charlie.etica.ai. E neste #
#        momento vamos fazer a terminação HTTPS aqui mesmo                     #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# SEÇÃO: AJUDA AO USUARIO                                                      #
# TL;DR: Lista como é documentado ao usuario final o que este servidor         #
#        oferece. Em geral é uma forma de documentar as IDEs e todos os        #
#        interpretadores/compiladores de linguagens de programação             #
#------------------------------------------------------------------------------#


sudo cp /etc/nginx/sites-available/EXEMPLO-PROXY.abp.etica.ai.conf /etc/nginx/sites-available/api.cplpaiopsbot.etica.ai.conf

sudo vim /etc/nginx/sites-available/api.cplpaiopsbot.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/api.cplpaiopsbot.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d api.cplpaiopsbot.etica.ai


##### ansi2html ________________________________________________________________
# Esse script converte uma saída de terminal para HTML. É usado para dar a
# usuários que não estão logados o que o comando ajuda retornaria
# Instalar https://github.com/pixelb/scripts/blob/master/scripts/ansi2html.sh
# em
vim /usr/local/bin/ansi2html
sudo chmod +x  /usr/local/bin/ansi2html

##### Comando de ajuda do servidor _____________________________________________
touch /usr/local/bin/ajuda
sudo chmod +x  /usr/local/bin/ajuda

vim /usr/local/bin/ajuda
# customizar aqui... o arquivo esta commitado no repositorio

### ATENÇÃO: toda vez que atualizar o script, rode isso para atualizar o HTML
/usr/local/bin/ajuda | ansi2html --bg=dark -p > /var/www/html/ajuda.html

sudo lshw -html > /var/www/html/lshw.html

#------------------------------------------------------------------------------#
# SEÇÃO: HTTP/HTTPS PADRÃO                                                     #
# TL;DR: Documenta o uso de NGinx e afins como proxy reverso a aplicações      #
#        internas. Os colaboradores podem solicitar endereços customizados     #
#        (como domínios de todo gratuitos no freenom.com) que incluimos também #
#        nas configurações do servidor                                         #
#------------------------------------------------------------------------------#

##### Sites Habilitados neste servidor _________________________________________
# Cada usuário, mesmo sem acesso sudo (super usuário) pode chamar aplicações
# em portas acima da 1024, como em http://apb.etica.ai:3000. A lista a seguir
# são ou padrão de sistema, ou que usuários pediram para rotear via HTTP e HTTPS
# para uma de suas aplicações internas.
#
# - http://aguia-pescadora-bravo.etica.ai
# - https://aguia-pescadora-bravo.etica.ai
# - http://apb.etica.ai
# - https://apb.etica.ai

##### NGinx ____________________________________________________________________
## @see http://nginx.org/
## @see https://www.digitalocean.com/community/tutorials/como-instalar-o-nginx-no-ubuntu-16-04-pt
sudo apt install nginx
# sudo ufw allow 'Nginx Full' # Firewall desabilitado especialmente neste servidor

### Como Proteger o Nginx com o Let's Encrypt no Ubuntu 18.04:
## @see https://www.digitalocean.com/community/tutorials/como-proteger-o-nginx-com-o-let-s-encrypt-no-ubuntu-18-04-pt
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx

# Linha de comando para obter certificados. Automaticamente já edita configurações do NGinx
sudo certbot --nginx -d aguia-pescadora-bravo.etica.ai -d apb.etica.ai


### Userdir
# @see https://github.com/fititnt/cplp-aiops/issues/35

vim /etc/nginx/sites-available/usuario.apb.etica.ai.conf
# Adicione as configurações desejadas neste servidor no arquivo acima...

# Depois de o arquivo estar minimamente ok, use o comando a seguir
# para criar um link simbolico dele para diretório em que o NGinx realmente
# irá ler o arquivo
sudo ln -s /etc/nginx/sites-available/usuario.apb.etica.ai.conf /etc/nginx/sites-enabled/

# Antes de efetivamente habilitar, use o comando a seguir para testar se
# configurações estão ok.
sudo nginx -t
# Se o comando acima falhar, faça:
# 1. edite /etc/nginx/sites-available/userdir.conf e resolva em pouco tempo
# 2. apague o link simbolico (não o seu arquivo de rascunho) para evitar que se
#    outra pessoa reiniciar o servidor o seu rascunho efetivamente de problemas:
#       - rm /etc/nginx/sites-enabled/userdir.conf
#    Então teste nomamente com 'sudo nginx -t' para ver se não daria problemas

# reload nginx: Aplicar alterações nas configurações sem reiniciar o NGinx
sudo systemctl reload nginx

# PROTIP: acompanhe os arquivos a seguir para debugar
#             tail -f /var/log/nginx/access.log
#             tail -f /var/log/nginx/error.log
#         Em geral o principal motivo de erro serão permissões de arquivo e de
#         diretório até o respectivo arquivo

### Portas internas ____________________________________________________________
# Subdomínios padronizados com HTTP/HTTPS para portas comuns
# ISSUE: https://github.com/fititnt/cplp-aiops/issues/57

vim /etc/nginx/sites-available/PORTAS-INTERNAS.apb.etica.ai.conf
# Adicione as configurações desejadas neste servidor no arquivo acima...
sudo ln -s /etc/nginx/sites-available/PORTAS-INTERNAS.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx \
  -d 2000.apb.etica.ai \
  -d 3000.apb.etica.ai \
  -d 4000.apb.etica.ai \
  -d 5000.apb.etica.ai \
  -d 6000.apb.etica.ai \
  -d 7000.apb.etica.ai \
  -d 8000.apb.etica.ai \
  -d 8080.apb.etica.ai \
  -d 8888.apb.etica.ai \
  -d 9000.apb.etica.ai

#------------------------------------------------------------------------------#
# SEÇÃO: ADMINISTRAÇÃO DO DIA A DIA                                            #
# TL;DR: Atalhos para algumas rotinas comuns do dia a dia de administrador de  #
#        sistemas, como atalhos para ver logs de acesso, rotinas para          #
#        reiniciar tarefas que tendem a dar problemas, etc.                    #
#------------------------------------------------------------------------------#

### Monitorar rede em tempo real ______________________________________________#
## Vnstat
# @see https://www.howtoforge.com/tutorial/vnstat-network-monitoring-ubuntu/
vnstat -l


#------------------------------------------------------------------------------#
# SEÇÃO: OUTROS                                                                #
# TL;DR: Itens ainda não formalmente documentados e/ou em período de teste     #
#------------------------------------------------------------------------------#

### Fish ("the friendly interactive shel" ______________________________________
# ...
apt-get install fish

### Grafana ____________________________________________________________________
# @see https://github.com/fititnt/cplp-aiops/issues/50

# @see https://grafana.com/docs/installation/debian/#apt-repository
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update
sudo apt-get install grafana

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server

sudo systemctl enable grafana-server.service

sudo cp /etc/nginx/sites-available/EXEMPLO-PROXY.abp.etica.ai.conf /etc/nginx/sites-available/grafana.apb.etica.ai.conf

sudo vim /etc/nginx/sites-available/grafana.apb.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/grafana.apb.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d grafana.apb.etica.ai


#------------------------------------------------------------------------------#
# SEÇÃO: BACKUP                                                                #
#------------------------------------------------------------------------------#
# @see https://github.com/fititnt/cplp-aiops/issues/5#issuecomment-501605356
# Conforme descrito no issue 5 (cplp-aiops/issues/5) vamos preparar um backup
# de tudo que esta VM tem para caso os usuários não tenham algo e queiram
# recuperar depois

sudo mkdir /backup
tar -cvpzf backup.tar.gz --exclude=/backup.tar.gz --one-file-system / 

## Backup FULL (completo do sistema operaconal)
# https://help.ubuntu.com/community/BackupYourSystem/TAR
cd /
tar -cvpzf aguia-pescadora-bravo_2019-06-13-FULL.tar.gz --exclude=/aguia-pescadora-bravo_2019-06-13-FULL.tar.gz --exclude=/swapfile --one-file-system /

# root@aguia-pescadora-bravo:/# ls -lha /aguia-pescadora-bravo_2019-06-13-FULL.tar.gz 
# -rw-r--r-- 1 root root 2,2G jun 13 09:04 /aguia-pescadora-bravo_2019-06-13-FULL.tar.gz

## Backup completo será movido para Delta para caso usuários não tenham feito
## uma cópia de seus dados, mas precise delas no futuro
## Neste momento não vamos usar backup encriptado, pois ainda não há dados sensiveis
scp aguia-pescadora-bravo_2019-06-13-FULL.tar.gz ssh root@aguia-pescadora-delta.etica.ai:/backups

# root@aguia-pescadora-bravo:/# scp aguia-pescadora-bravo_2019-06-13-FULL.tar.gz ssh root@aguia-pescadora-delta.etica.ai:/backups
# (...)
# aguia-pescadora-bravo_2019-06-13-FULL.tar.gz         100% 2247MB  10.7MB/s   03:30
