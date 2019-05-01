###############################  logbook: mamba  ###############################
# 2 vCPUs, 1GB RAM, 20GB SSD (CloudAtCost)
# Ubuntu 16.04.2 LTS 64bit
# mamba.kayen.ga (45.62.226.140)
################################################################################

### Atalhos Rápidos
## Acesso remoto
# ssh root@mamba.kayen.ga
# ssh kissabi@mamba.kayen.ga
# ssh fititnt@mamba.kayen.ga
## Para fazer acesso com chave privada (sem precisar redigitar senhas sempre)
# ssh-copy-id NOMEDOUSUARIO@mamba.kayen.ga
##
###

#### Preparação Inicial:

sudo hostnamectl set-hostname mamba.kayen.ga

vim /etc/hosts
# Add to hostfiles
# 127.0.0.1 mamba.kayen.ga

### Swap + /boot, inicio
## CloudAtCost, reduz swap padrão para aumentar /boot (permite atualizar kernel)
## @see http://www2.fugitol.com/2012/04/linux-resizing-boot-partition.html
## @see http://tabletuser.blogspot.com/2017/12/ubuntu-1604-resize-boot-partition-for.html (alternativa)

# Requisito previo: setar label na swap (por padrão vem sem label)
swaplabel -L SWAP-sda2 /dev/sda2

# Então seguir com os passos de http://www2.fugitol.com/2012/04/linux-resizing-boot-partition.html
fdisk -l
blkid /dev/sda1 /dev/sda2
swapoff -a
umount /boot
tune2fs -O ^has_journal /dev/sda1
# ***Siga os passos 6 até 13*** do site
# Nota: no passo 8, em vez de "42" escolha "2181119" (sem aspas)

# Nota: ao final do passo 12, deve ter algo como
#   Device     Boot    Start      End  Sectors  Size Id Type
#   /dev/sda1           2048  2181118  2179071    1G 83 Linux
#   /dev/sda2        2181119  4362239  2181121    1G 82 Linux swap / Solaris
#   /dev/sda3        4362240 20969471 16607232  7.9G 8e Linux LVM
#   /dev/sda4       20969472 40959999 19990528  9.5G 8e Linux LVM

# Nota: é ok aparecer o erro em vermelho "Re-reading the partition table failed.: Device or resource busy"

# Checa se o disco esta ok
e2fsck -f /dev/sda1

# Reinicar
reboot

# SSH no servidor...

# Reabilitar swap e terminar o processo
swapoff -a
mkswap -L SWAP-sda2 /dev/sda2
# swapon -a
swapon /dev/sda2 # Alterado para deixar explicito o lugar
umount /boot
e2fsck -f /dev/sda1 # Comando extra em relação a documentação 
resize2fs /dev/sda1
tune2fs -j /dev/sda1
mount /boot

## Caso swap falhe no reboot teste editar /etc/fstab e trocar linhas deixando UUUID=... explicito a /dev/sda2 Ex.:
## UUID=c9f61b59-95aa-45ab-ae18-ee968312edc4 none            swap    sw              0       0
# /dev/sda2       none            swap    sw              0       0

#
##
### Swap + /boot, fim

## Atualiza sistema operacional
sudo apt update
sudo apt upgrade -y

# Aplicações básicas. Não realmente essencial, mas torna vida mais simples
sudo apt install mosh htop tree -y

### UFW
## @see https://www.digitalocean.com/community/tutorials/how-to-setup-a-firewall-with-ufw-on-an-ubuntu-and-debian-cloud-server
sudo ufw allow ssh
sudo ufw allow ftp

### FTP
## @see https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-16-04
sudo apt install vsftpd

sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 990/tcp
sudo ufw allow 40000:50000/tcp
sudo ufw status

## Permitir e forçar conecções com criptografia forte via FTP
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
# Country Name (2 letter code) [AU]:AO
# State or Province Name (full name) [Some-State]:Cuanza Sul
# Locality Name (eg, city) []:Sumbe
# Organization Name (eg, company) [Internet Widgits Pty Ltd]:kayen.ga
# Organizational Unit Name (eg, section) []:
# Common Name (e.g. server FQDN or YOUR name) []:kayen.ga
# Email Address []:kissabiamigo@gmail.com


# Aviso: o arquivo /logbook/mamba/etc/vsftpd.conf contém alterações mais
#        detalhadas

## Arquivo /etc/vsftpd.conf
# Garanta que as seguintes linhas existam dessa forma e estejam descomendadas
write_enable=YES
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
pasv_min_port=40000
pasv_max_port=50000

## Anonymous FTP
# @see https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-anonymous-downloads-on-ubuntu-16-04
# @see https://www.cyberciti.biz/tips/configure-vsfptd-secure-connections-via-ssl-tls.html

sudo mkdir -p /var/ftp/pub
sudo chown nobody:nogroup /var/ftp/pub
sudo chown nobody:ftp-users /var/ftp/pub
# echo "vsftpd test file" | sudo tee /var/ftp/pub/test.txt
sudo chmod g+s /var/ftp/pub

# Usar isso para corrigir permissoes
sudo chgrp -R ftp-users /var/ftp/pub
sudo chmod -R g+w /var/ftp/pub
sudo chmod g+s /var/ftp/pub
sudo systemctl restart vsftpd
sudo systemctl restart nginx

# @see https://github.com/gibatronic/ngx-superbindex
# Adicionado "ngx-superbindex"

### SSH, otimizações para reduzir uso de dados em conexção 3G
## @see https://superuser.com/questions/624720/how-much-data-does-ssh-typically-use/1199986#1199986
## @see ./mamba/etc/ssh/sshd_config

# Garanta os parametros a seguir no arquivo /etc/ssh/sshd_config do *SERVIDOR* Mamba
TCPKeepAlive no

# Garanta os parametros a seguir no arquivo ssh_config do cliente (o telefone que acessa o servidor):
ServerAliveInterval 180
ServerAliveCountMax 40
TCPKeepAlive no

#### Preparação Inicial, fim

#### Usuários, inicio
# Nota: o servidor real pode ter mais usuários do que os listados aqui

### kissabi
sudo adduser kissabi

### fititnt
sudo adduser fititnt

### pyladies
sudo adduser pyladies

### pyladies
sudo adduser loopchaves

groupadd ftp-users
usermod -a -G ftp-users kissabi
usermod -a -G ftp-users fititnt
usermod -a -G ftp-users loopchaves
usermod -a -G ftp-users www-data

### usuariodeteste
# Este usuário é usado para testar restrições a usuários
sudo adduser usuariodeteste

#### Usuários, fim

#### Acesso HTTP e HTTPS, início
###
##
#

### NGinx
## @see https://www.digitalocean.com/community/tutorials/como-instalar-o-nginx-no-ubuntu-16-04-pt
sudo apt install nginx
sudo ufw allow 'Nginx Full'

### Documentação de NGinx + Let's Encrypt em Ubuntu 16:
## @see https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx

# Linha de comando para obter certificados. Automaticamente já edita configurações do NGinx
sudo certbot --nginx -d kayen.ga -d mamba.kayen.ga -d www.kayen.ga -d pyladies.kayen.ga -d ftp.etica.ai

## PHP
# @see https://www.digitalocean.com/community/tutorials/como-instalar-linux-nginx-mysql-php-pilha-lemp-no-ubuntu-16-04-pt
# @see https://www.rosehosting.com/blog/how-to-install-php-7-3-on-ubuntu-16-04/
# Ubuntu 16 tem apenas php 7.0, aproveitar para instalar logo o 7.3
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
apt update

apt install php7.3 php7.3-fpm php7.3-common php7.3-gd

# O h5ai tem alguns requisitos extras, como imagemagick
sudo apt install php7.3-imagick
sudo apt install imagemagick
sudo install zip

# ffmpeg pro h5ai
# @see https://tecadmin.net/install-ffmpeg-on-linux/
sudo add-apt-repository ppa:jonathonf/ffmpeg-4
sudo apt update
sudo apt install ffmpeg

# Desabilitar file uploads &  cgi.fix_pathinfo=0
vim /etc/php/7.3/fpm/php.ini
# cgi.fix_pathinfo=0
# (...)
#; NOTA: file uploads desabilitdo por padrao; 
#file_uploads = Off

sudo systemctl restart php7.3-fpm

# Testar configuacao do NGinx sem reiniciar
sudo nginx -t
sudo systemctl reload nginx

## full reload
sudo systemctl restart php7.3-fpm && sudo systemctl reload nginx

#
##
###
#### Acesso HTTP e HTTPS, início

##### Configuração de websites, inicio
### @see https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04

### kissabi
sudo usermod -a -G www-data kissabi
sudo mkdir /home/kissabi/public_html
echo "kissabi" > /home/kissabi/public_html/index.html
sudo chown kissabi:www-data -R /home/kissabi/public_html
sudo chmod g+s /home/kissabi/public_html
sudo chmod 755 -R /home/kissabi/public_html

### pyladies
sudo usermod -a -G www-data pyladies
sudo mkdir /home/pyladies/public_html
echo "pyladies" > /home/pyladies/public_html/index.html
sudo chmod g+s /home/pyladies/public_html
sudo chmod 775 -R /home/pyladies/public_html

#
##
####
##### Configuração de websites, fim

#### Estatístiticas e logs, início
###
##
#

### VNstat
# @see https://www.howtoforge.com/tutorial/vnstat-network-monitoring-ubuntu/
sudo apt-get install vnstat
sudo apt-get install vnstati

ifconfig
# Escolha a network para iniciar monitoramento. Neste caso é ens32
vnstat -u -i ens32

## vnstat --iflist
#Available interfaces: ens32 (1000 Mbit) lo

sudo systemctl start vnstat
sudo systemctl enable vnstat

vim /etc/vnstat.conf
# trocar eth0 pela network especifica
# default interface
# Interface "ens32"
# Para ver em tempo real o uso de rede
vnstat -l


#
##
####
##### statístiticas e logs, fim

##### Gerenciamento do dia a dia, inicio
#### Iniciar, reiniciar, parar serviços, e status (ver se estão ativos)
### vsftpd (serviço de SFTP)
sudo systemctl start vsftpd
sudo systemctl restart vsftpd
sudo systemctl stop vsftpd
sudo systemctl status vsftpd


### NGinx (serviço web)
sudo systemctl start nginx
sudo systemctl restart nginx
sudo systemctl stop nginx
sudo systemctl status nginx

# comando especial reload: testar se confiração do NGinx não tem erros graves
sudo nginx -t

# comando especial reload: recarrega configurações SEM reiniciar serviço!
sudo systemctl reload nginx

# Acompanhar acessos
tail -f /var/log/nginx/access.log

# Acompanhar erros
tail -f /var/log/nginx/error.log

#
##
###
##### Gerenciamento do dia a dia, fim