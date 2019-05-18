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

#------------------------------------------------------------------------------#
# SEÇÃO: Benchmark do sistema                                                  #
# TL;DR: Avalia performance da máquina virtual e de rede                       #
#        Essa VM mais do que decente pelo preço dela!!!                        #
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
# SEÇÃO: USUÁRIOS DO SISTEMA                                                   #
# TL;DR: Cria os usuários de sistema, e outras customizações                   #
#------------------------------------------------------------------------------#

### Guia para ser feito por cada usuário de sistema (copie e cole), início
# Cria o usuario, inclusive diretorio home /home/UsernameDoUsuario
sudo adduser UsernameDoUsuario

# Este comando força usuario usar uma senha propria no próximo login.
# Uma alternativa seria já ter chaves publicas de cada usuario
sudo passwd -e UsernameDoUsuario
### Guia para ser feito por cada usuário de sistema (copie e cole), fim

## fititnt
sudo adduser fititnt
sudo passwd -e fititnt

## loopchaves
sudo adduser loopchaves
sudo passwd -e loopchaves


#------------------------------------------------------------------------------#
# SEÇÃO: EDITORES DE TEXTO, EDITORES DE CÓDIGO, IDES                           #
# TL;DR: Programas do lado do servidor que permitem  programar                 #
#------------------------------------------------------------------------------#

# ...

#------------------------------------------------------------------------------#
# SEÇÃO: AMBIENTES DE DESENVOLVIMENTO DE LINGUAGENS DE PROGRAMAÇÃO             #
# TL;DR: Configurações específicas de interpretadores e/ou compiladores        #
#------------------------------------------------------------------------------#

# ...