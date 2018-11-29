###############################  logbook: mamba  ###############################
# 2 vCPUs, 1GB RAM, 20GB SSD (CloudAtCost)
# Ubuntu 16.04.2 LTS 64bit
# mamba.kayen.ga (45.55.32.60)
###############################################################################

### Atalhos Rápidos
## Acesso remoto
# ssh root@mamba.kayen.ga
#
###

### Preparação Inicial:

## Aumentar tamanho de partição, metodo 1
# CloudAtCost, reduz swap padrão e aumenta /boot (permite atualizar kernel)
# @see http://tabletuser.blogspot.com/2017/12/ubuntu-1604-resize-boot-partition-for.html
fdisk -l /dev/sda*; blkid /dev/sd* && swapoff -a && umount /boot && tune2fs -O ^has_journal /dev/sda1 && echo -e "d\n2\nn\np\n2\n2181119\n\nt\n2\n82\nd\n1\nn\np\n1\n\n\np\nw" | fdisk /dev/sda && e2fsck -f /dev/sda1

# reboot
reboot

# Login (pode demorar uns 2 minutos)
ssh root@mamba.kayen.ga

## Depois de reiniciar, executar
swapoff -a && mkswap -L swap /dev/sda2 &&  umount /boot && e2fsck -f /dev/sda1 && resize2fs /dev/sda1 && tune2fs -j /dev/sda1 && mount /boot

## Aumentar tamanho de partição, metodo 1, fim

## Aumentar tamanho de partição, metodo 2, fim
# Seguir passos descritos na fonte original usada pelo tabletuser (passo 1)
# @see http://tabletuser.blogspot.com/2017/12/ubuntu-1604-resize-boot-partition-for.html

#
# Caso metodo 1 tenha falhado, siga o passo a passo manualmente, conforme 
# http://tabletuser.blogspot.com/2017/12/ubuntu-1604-resize-boot-partition-for.html


#
## Atualiza sistema operacional
sudo apt update
sudo apt upgrade -y

### Preparação Inicial, fim


# Aplicações básicas. Não realmente essencial, mas torna vida mais simples
sudo apt install mosh htop tree -y
