######################  Diario de bordo: aguia-pescadora #######################
# 2 vCPUs, 1,5GB RAM, 30GB SSD (CloudAtCost)
# Ubuntu 16.04.2 LTS 64bit
# aguia-pescadora.etica.ai (104.167.109.226)
################################################################################


#### Preparação Inicial:

# Aviso: a recomendação a seguir sobre 'Swap + /boot' é extremanente especifica
# para uso na CloudAtCost. Outros provedores de VPSs tipicamente não requerem.

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

### Atualizar de Ubuntu 16.04.2 LTS para Ubuntu 18.04.02 LTS

sudo apt update
sudo apt upgrade
sudo apt autoremove
reboot

sudo apt update
sudo do-release-upgrade

#### Preparação Inicial:

sudo hostnamectl set-hostname aguia-pescadora.etica.ai

sudo vim /etc/hosts
## Adicione o seguinte ao /etc/hosts
# 127.0.0.1	aguia-pescadora

##### Usuarios de sistema, inicio
####
##
#

#### Padrao para copiar e colar para criar usuarios novos, inicio
# Cria o usuario, inclusive diretorio home /home/UsernameDoUsuario
sudo adduser UsernameDoUsuario

# Este comando força usuario usar uma senha propria no próximo login.
# Uma alternativa seria já ter chaves publicas de cada usuario
sudo passwd -e UsernameDoUsuario

#### Padrao para copiar e colar para criar usuarios novos, inicio

#### Usuarios adicionados ao aguia-pescadora.etica.ai, inicio
##
#
## fititnt
sudo adduser fititnt
sudo passwd -e fititnt

## kissabi
sudo adduser kissabi
sudo passwd -e kissabi

## loopchaves
sudo adduser loopchaves
sudo passwd -e loopchaves

## rodriguesjeff
sudo adduser rodriguesjeff
sudo passwd -e rodriguesjeff

## renatonerijr
sudo adduser renatonerijr
sudo passwd -e renatonerijr

## betafcc
sudo adduser betafcc
sudo passwd -e betafcc

## fcomarcosmabreu
sudo adduser fcomarcosmabreu
sudo passwd -e fcomarcosmabreu

## jefferson091
sudo adduser jefferson091
sudo passwd -e jefferson091
#
###
#### Usuarios adicionados ao aguia-pescadora.etica.ai, fim

#
##
####
##### Usuarios de sistema, fim