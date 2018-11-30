###############################  logbook: mamba  ###############################
# 2 vCPUs, 1GB RAM, 20GB SSD (CloudAtCost)
# Ubuntu 16.04.2 LTS 64bit
# mamba.kayen.ga (45.62.226.140)
###############################################################################

### Atalhos Rápidos
## Acesso remoto
# ssh root@mamba.kayen.ga
#
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
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 990/tcp
sudo ufw allow 40000:50000/tcp
sudo ufw status

## Arquivo /etc/vsftpd.conf
# Garanta que as seguintes linhas existam dessa forma e estejam descomendadas
write_enable=YES

#### Preparação Inicial, fim

#### Usuários, inicio

### kissabi
sudo adduser kissabi

sudo mkdir /home/kissabi/ftp
sudo chown nobody:nogroup /home/kissabi/ftp
sudo chmod a-w /home/kissabi/ftp
sudo ls -la /home/kissabi/ftp

sudo mkdir /home/kissabi/ftp/files
sudo chown kissabi:kissabi /home/kissabi/ftp/files
sudo ls -la /home/kissabi/ftp

echo "vsftpd test file" | sudo tee /home/kissabi/ftp/files/test.txt

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