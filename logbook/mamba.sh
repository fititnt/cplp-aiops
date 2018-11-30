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

# TODO: revisar no futuro se o aviso de segurança abaixo poderá ser removido
#       ao simplesmente revisar com calma as configurações
#       (fititnt, 2018-11-30 03:37 BRST)

## AVISO DE SEGURANÇA SOBRE CONFIGURAÇÕES FTP, inicio
# A documentação de referência da digital ocean (bem como outros locais)
# tendem a sugerir que o usuário FTP não tenha permissão até mesmo de alterar
# arquivos do seu próprio diretório /home/NomeDoUsuario pois, em situações
# muito específicas, seria possível que uma conta FTP comum poderia comprometer
# segurança de servidor inteiro. Sugestões de melhoria são bem vindas, porém
# note que, ao menos inicialmente, prefere-se dar flexibilidade aos usuários
# e restringir numero de pessoas e recomendar boas práticas de segurança a elas
# para mitigar incidentes com contas comprometidas.
## AVISO DE SEGURANÇA SOBRE CONFIGURAÇÕES FTP, fim

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



#### Preparação Inicial, fim

#### Usuários, inicio
# Nota: o servidor real pode ter mais usuários do que os listados aqui

### kissabi
sudo adduser kissabi

### fititnt
sudo adduser fititnt

### fititnt
sudo adduser pyladies

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

#
##
###
#### Acesso HTTP e HTTPS, início

##### Configuração de websites, inicio
### @see https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04

### kissabi
sudo mkdir /home/kissabi/public_html
echo "kissabi" > /home/kissabi/public_html/index.html
sudo chown kissabi:kissabi -R /home/kissabi/public_html

### pyladies
sudo mkdir /home/pyladies/public_html
echo "pyladies" > /home/pyladies/public_html/index.html
sudo chown pyladies:pyladies -R /home/pyladies/public_html

#
##
####
##### Configuração de websites, fim

##### Gerenciamento do dia a dia, inicio
#### Iniciar, reiniciar, parar serviços, e status (ver se estão ativos)
### vsftpd (serviço de SFTP)
sudo systemctl start vsftpd
sudo systemctl restart vsftpd
sudo systemctl stop vsftpd
sudo systemctl status vsftpd
#
##
###
##### Gerenciamento do dia a dia, fim