echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit
############### Diario de bordo: elefante-borneu-yul-03.etica.ai ###############
# VPS (KVM), 1 vCPU, 2GB RAM, 20GB SSD, Ubuntu Server 18.04 64bit, OVH, Canada
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 1 vCPU
# RAM: 2 GB
# Disk: 20 GB
#
# IPv4: 149.56.130.178
# IPv6: 2607:5300:0201:3100:0000:0000:0000:6df7
#
# Domain:
#   Full: elefante-borneu-yul-03.etica.ai (TTL: 15 min)
#   Short: ebyul03.etica.ai (TTL: 15 min)
#
# Domain, extras:
#   lb-ebyul.etica.ai (TTL: 2 min)
#   lb-eb.etica.ai (TTL: 2 min)
#
# Login:
#   ssh user@elefante-borneu-yul-03.etica.ai
#   mosh user@elefante-borneu-yul-03.etica.ai (TODO: install Mosh)
#   ssh user@ebyul03.etica.ai
#   mosh user@ebyul03.etica.ai (TODO: install Mosh)
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
# SEÇÃO 0.1: Configuração inicial                                              #
# TL;DR: Isso é feito ao receber uma VPS do zero                               #
#------------------------------------------------------------------------------#

### Primeiro login______________________________________________________________
ssh root@149.56.130.178

### Atualizar o sistema operacional_____________________________________________
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

### Define um hostname personalizado____________________________________________
sudo hostnamectl set-hostname elefante-borneu-yul-03

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 elefante-borneu-yul-03.etica.ai  elefante-borneu-yul-03

### Define horário padrão de sistema_____________________________________________
sudo timedatectl set-timezone UTC

### Idioma padrão do servidor: português________________________________________
sudo apt install language-pack-pt language-pack-pt-base
sudo update-locale LANG=pt_PT.utf8

### Criar Swap & ajusta Swappiness______________________________________________
## Cria um /swapfile de 2GB
# @see https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04
sudo fallocate -l 2G /swapfile
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

# O arquivo /etc/vnstat.conf deve estar marcado para nossa interface desejada
sudo vim /etc/vnstat.conf
# trocar eth0 pela network especifica
# default interface
# Interface "ens3"
# Para ver em tempo real o uso de rede

# Vamos iniciar vnstat para rodar imediatamente, e também iniciar com sistema
sudo systemctl start vnstat
sudo systemctl enable vnstat

##### Mosh _____________________________________________________________________
# @see https://mosh.org
sudo apt install -y mosh

##### Rede [nmap, traceroute, dig (dnsutils)....] ______________________________
sudo apt install -y traceroute nmap dnsutils

#------------------------------------------------------------------------------#
# SEÇÃO 1: PREPARAÇÃO DOS SERVIDORES PARA OPERAREM EM CLUSTER                  #
# TL;DR:                                                                       #
#------------------------------------------------------------------------------#

sudo vi /etc/hosts
## Adicione ao final do arquivo:
## Cluster, demais nos
#149.56.130.19	elefante-borneu-yul-01.etica.ai		elefante-borneu-yul-01
###149.56.130.66	elefante-borneu-yul-02.etica.ai		elefante-borneu-yul-02
#149.56.130.178	elefante-borneu-yul-03.etica.ai		elefante-borneu-yul-03

# Nota: teste ping de todas as maquinas para todas as demais. Nós vamos usar
# preferencialmente hostname elefante-borneu-yul-NN em vez de IPs. E estes IPs
# estão hardcored porque... bem, mesmo se usarmos dominio completo, isso poderia
# causar uma lentidão absurda em certos casos. E vale a pena não correr riscos
# (fititnt, 2019-05-26 14:35 BRT)


#------------------------------------------------------------------------------#
# SEÇÃO 2: INSTALAÇÃO E CONFIGURAÇÃO DO MARIADB + GALERA CLUSTER               #
# TL;DR:                                                                       #
#------------------------------------------------------------------------------#

### MariaDB 10.3 stable
# @see https://downloads.mariadb.org/mariadb/repositories/#mirror=digitalocean-nyc&distro=Ubuntu&distro_release=bionic--ubuntu_bionic&version=10.3
# @see http://galeracluster.com/documentation-webpages/installmariadb.html

sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'

# Instala o MariaDB ja com galera
sudo apt install mariadb-server mariadb-client galera-3

# Execute o comando padrão de deixar mais seguro as opcoes padroes
mysql_secure_installation

# Entre como super usuario no console do mysql
mysql -u root -p

## Execute os seguintes comandos. O user é o que o HAProxy usara para testar
## se o servidor parece estar ok. E o IP é de onde ele fara isso
# CREATE USER 'haproxy@192.99.247.117';
# FLUSH PRIVILEGES;

## AVISO: neste momento os servidores ainda NÃO estão em cluster. Por isso
##        estamos tratando cada um individualmente.

sudo vim /etc/mysql/my.cnf
# Edite o arquivo acima conforme:
# @see http://galeracluster.com/documentation-webpages/configuration.html

sudo vim /etc/mysql/mariadb.conf.d/galera.cnf
# Edite o arquivo acima conforme:
# @see http://galeracluster.com/documentation-webpages/dbconfiguration.html

# Vamos desligar o MariaDB. Quando forem ligados, serão parte de um Cluster
# Master-Master :,)
sudo systemctl stop mysql

#------------------------------------------------------------------------------#
# SEÇÃO 3: INICIALIZAÇÃO DE UM NOVO CLUSTER                                    #
# TL;DR: Eu pessoalmente acho isso lindo. Não é o tipo de coisa que a gente    #
#        faz com frequência. (fititnt, 2019-05-26 19:18 BRT)                   #
#------------------------------------------------------------------------------#
## @see http://galeracluster.com/documentation-webpages/startingcluster.html#starting-the-first-cluster-node
## @see https://mariadb.com/kb/en/library/getting-started-with-mariadb-galera-cluster/#systemd-and-bootstrapping
## @see http://man7.org/linux/man-pages/man1/galera_new_cluster.1.html

# Sobre os arquivos de configuração ____________________________________________
# A documentação não foi feita passo a passo, segundo as documentações oficiais
# em mariadb.com e galeracluster.com é possível saber as variáveis mínimas que
# devem ser alteradas para que o MariaDB opere cluster. Note que os arquivos
# de configurações não explicitam qual dos nós será o primário, pois TODOS
# são nós primários. A única diferença é o comando usado para criar um cluster
# a primeira vez ou (em caso de falha crítica) reinicializar um cluster a
# partir do nó mais avançado.
#
# Estando os arquivos de configuração OK, exceto se houver problemas com
# firewall, o tempo entre inicializar o primeiro nó e adicionar os demais é
# baixo

# Cria o primeiro nó (cluster novo) ____________________________________________
# Como você não está recuperando de um cluster que falou (ou foi acidental ou
# propositalmente desligado todos os nós ao mesmo tempo) escolha uma das três
# instâncias para ser a criadora inicial. Todas as demais herdarão todos os
# bancos de dados InnoDB desta (e o que quer que tinha nelas antes,
# será destruído).
#
# No Cluster Elevante Bornéu a escolha foi elefante-borneu-yul-01

### ALERTA: NÃO EXECUTE ESTE COMANDO NOS DEMAIS NÓS! ISTO OCORRE APENAS UMA VEZ
###         DURANTE A CRIAÇÃO DE UM CLUSTER DO ZERO!
#
#    sudo galera_new_cluster
#

### Adiciona demias nós (cluster novo) _________________________________________
### Nos demais nós DEPOIS de um cluster já ter sido iniciado, os inicie
### como se fossem um MariaDB (MySQL) como qualquer outro:
#
#    sudo systemctl start mysql
#
### Note: a partir de agora, desde que o cluster inteiro não tenha caído, os
### passos de inicializar, parar e reiniciar são como um MariaDB comum, com a
### vantagem de que os clientes finais (que acessam via o HAProxy) não saberão
### se algum servidor ficou fora do ar. É lindo!

# @TODO: documentar o dia a dia no gerenciamento de um cluster (fititnt, 2019-05-27 20:19 BRT)