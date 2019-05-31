echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit
############### Diario de bordo: elefante-borneu-yul-01.etica.ai ###############
# VPS (KVM), 1 vCPU, 2GB RAM, 20GB SSD, Ubuntu Server 18.04 64bit, OVH, Canada
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 1 vCPU
# RAM: 2 GB
# Disk: 20 GB
#
# IPv4: 149.56.130.19
# IPv6: 2607:5300:0201:3100:0000:0000:0000:2f58
#
# Domain:
#   Full: elefante-borneu-yul-01.etica.ai (TTL: 15 min)
#   Short: ebyul01.etica.ai (TTL: 15 min)
#
# Domain, extras:
#   lb-ebyul.etica.ai (TTL: 2 min)
#   lb-eb.etica.ai (TTL: 2 min)
#
# Login:
#   ssh user@elefante-borneu-yul-01.etica.ai
#   mosh user@elefante-borneu-yul-01.etica.ai (TODO: install Mosh)
#   ssh user@ebyul01.etica.ai
#   mosh user@ebyul01.etica.ai (TODO: install Mosh)
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
ssh root@149.56.130.19

### Atualizar o sistema operacional_____________________________________________
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

### Define um hostname personalizado____________________________________________
sudo hostnamectl set-hostname elefante-borneu-yul-01

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 elefante-borneu-yul-01.etica.ai  elefante-borneu-yul-01

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
# TL;DR:  explicitamente define IP fixo de hostname e domínios completos       #
#         para os demais clusters (questão de performance e, em casos bem      #
#         especificos, de segurança) bem como reune as regras do firewall      #
#------------------------------------------------------------------------------#

##### /etc/hosts _______________________________________________________________

sudo vi /etc/hosts
## Adicione ao final do arquivo:
## Cluster, demais nos
###149.56.130.19	elefante-borneu-yul-01.etica.ai		elefante-borneu-yul-01
#149.56.130.66	elefante-borneu-yul-02.etica.ai		elefante-borneu-yul-02
#149.56.130.178	elefante-borneu-yul-03.etica.ai		elefante-borneu-yul-03

# Nota: teste ping de todas as maquinas para todas as demais. Nós vamos usar
# preferencialmente hostname elefante-borneu-yul-NN em vez de IPs. E estes IPs
# estão hardcored porque... bem, mesmo se usarmos dominio completo, isso poderia
# causar uma lentidão absurda em certos casos. E vale a pena não correr riscos
# (fititnt, 2019-05-26 14:35 BRT)

##### Firewall, configuração ___________________________________________________
# Nota 1: idealmente deveríamos ter uma rede privada, mas não temos dinheiro para
#         isso neste projeto comunitário.
# Nota 2: idealmente deveríamos ter um VPN. Isso pode ser configurado no futuro.
#
# Nota 3: caso fique preso do lado de fora (ex.: bloqueou a porta do SSH)
#         deve-se acessar via KVM.

# Checa status do firewall
sudo ufw status
sudo ufw status verbose
sudo ufw status numbered

#### Coneção liberada entre todas as portas dos nós do mesmo datacenter --------
# Estas configurações permitem todas as coneções entre os nós do cluster.
# Os demais itens são para acessos de outras máquinas
sudo ufw allow from 149.56.130.19 comment "*, elefante-borneu-yul-01.etica.ai"
sudo ufw allow from 149.56.130.66 comment "*, elefante-borneu-yul-02.etica.ai"
sudo ufw allow from 149.56.130.178 comment "*, elefante-borneu-yul-03.etica.ai"

#### SSH/mosh ------------------------------------------------------------------
# TODO: temporario, remover isto e restringir IPs (fititnt, 2019-05-28 16:32 BRT)
sudo ufw allow ssh comment "SSH, *, [TODO: restringir SSH no Cluster Elefante Borneu]"
sudo ufw allow mosh comment "Mosh, *, [TODO: restringir SSH no Cluster Elefante Borneu]"

#### MariaDB/MySQL -------------------------------------------------------------
# Sites de aplicação tem direito de acessar as porta específicas do MariaDB
sudo ufw allow from 104.167.109.226 to any port 3306 comment "MariaDB, aguia-pescadora-alpha.etica.ai"
sudo ufw allow from 192.99.247.117 to any port 3306 comment "MariaDB, aguia-pescadora-bravo.etica.ai"

#### MongoDB -------------------------------------------------------------------
## Sites de aplicação tem direito de acessar as porta específicas do MongoDB
# @see https://docs.mongodb.com/manual/reference/default-mongodb-port/
# @see https://docs.mongodb.com/manual/administration/security-checklist/
# @see https://docs.mongodb.com/manual/security/

sudo ufw allow from 104.167.109.226 to any port 27017 comment "MongoDB, aguia-pescadora-alpha.etica.ai"
sudo ufw allow from 192.99.247.117 to any port 27017 comment "MongoDB, aguia-pescadora-bravo.etica.ai"

#### Redis -------------------------------------------------------------------
## Sites de aplicação tem direito de acessar as porta específicas do Redis
# @see https://redis.io/topics/security
# @see http://antirez.com/news/96 (Leia isso)

sudo ufw allow from 104.167.109.226 to any port 6379 comment "Redis, aguia-pescadora-alpha.etica.ai"
sudo ufw allow from 192.99.247.117 to any port 6379 comment "Redis, aguia-pescadora-bravo.etica.ai"

##### Firewall, ativação _______________________________________________________
sudo ufw enable

##### Firewall, correção _______________________________________________________

#### Opção de remoção via regra ------------------------------------------------
ufw delete (...regra...)

#### Opção de remoção numero da regra ------------------------------------------
# Exibe as regras com numeros
sudo ufw status numbered

# Delete a regra via o numero dela (obtido com comando anterior)
sudo ufw delete XXXX

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

## @TODO usuário (ainda que sem acesso especial) haproxy foi liberado para todos
##       os hosts em que o firewall não protege. Não é algo crítico, porém
##       deve ser revisado pelo menos por restrição de DNS reverso ou IP
##       explícito. Uma opção adicional seria criar um usuário de checagem para
##       cada load balancer (fititnt, 2019-05-28 21:47)

## Execute os seguintes comandos. O user é o que o HAProxy usara para testar
## se o servidor parece estar ok. E o IP é de onde ele fara isso
# CREATE USER 'haproxy@%';
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

### PHPMyAdmin (configurar armazenamento, opcional) ____________________________
# Aplicavel em: caso use PHPMyAdmin como interface para acessar o cluster
#
# Mensagem de erro no rodapé do PHPMyAdmin: "A configuração de armazenamento phpMyAdmin não está completamente configurada, algumas funcionalidades adicionais foram desactivadas. Saiba porquê."
#
# Resposta: clique no botão, e deixe criar as tabelas. Elas são replicadas
#           nos demais nós do Cluster. Isto é necessário apenas primeira vez.
#           pode ser feito pelo próprio PHPMyAdmin

#------------------------------------------------------------------------------#
# SEÇÃO 3: RE-INICIALIZAÇÃO DE CLUSTER EXISTENTE                               #
# TL;DR: Um cluster que já existe por algum motivo foi ficou completamente     #
#        desligado.                                                            #
#------------------------------------------------------------------------------#

# @TODO melhorar descrição destes comandos (fititnt, 2019-05-27 19:13 BRT)

## Processo de restaurar o cluster (reinício seguro)

#Desligar o mariadb em TODAS as máquinas, executando isso em cada uma:
systemctl stop mariadb #pede gentilmente pras porcarias terminarem

# [esperar uns 20 segundos APÓS o comando retornar]
killall -u mysql -9 # mata porcarias que não tenham morrido

# Escolher uma nova máquina para ser a DONOR/PRIMARY e rodar nessa máquina o seguinte comando. Esse comando já inicia o MariaDB, não precisa usar o systemctl.
sudo galera_new_cluster

#Ligar as outras máquinas, uma por vez, só partindo pra próxima após ter CERTEZA que essa ligou corretamente, executando esse comando nas outras máquinas.
systemctl start mariadb

# Dá pra acompanhar em tempo real o início do MariaDB com o seguinte comando (use um novo terminal na mesma máquina)::
journalctl -u mariadb.service -f

# Se quiser rolar para logs mais antigos, retire o -f (não é atualizado em tempo real):
journalctl -u mariadb.service

# A máquina vai ter iniciado e sincronizado corretamente quando a seguinte mensagem aparecer no log:
## WSREP: Synchronized with group, ready for connections

# Possíveis problemas que podem acontecer:
# Timeout do systemd: algumas vezes o rsync demora muito tempo. Não faço ideia do porque. Pare TODAS as máquinas e reinicie o procedimento desde o começo.

#Coisas interessantes para verificar DENTRO do mysql:
#    Host sendo usado:
#        > show variables like 'hostname';
#    Número de conexões ATIVAS no momento:
#        > show status like 'Threads_connected';
#    Número de queries RODANDO no momento:
#        > show status like 'Threads_running';
#    QUAIS queries estão rodando no momento:
#        > show processlist;
#    Estatísticas sobre conexões:
#        > show status like ‘Conn%’;
#    Número de nodos no cluster:
#        > show status like 'wsrep_cluster_size';
#    Estado do nodo ATUAL em relação ao cluster:
#        > show status like 'wsrep_local_state_comment';
#    Estado do protocolo de replicação:
#        > show status like 'wsrep_evs_state';

#------------------------------------------------------------------------------#
# SEÇÃO 3: TAREFAS DO DIA A DIA EM MARIADB / GALERA CLUSTER                    #
# TL;DR:                                                                       #
#------------------------------------------------------------------------------#

## IMPORTANTE: comandos DDL (CREATE, USER, GRANT) são replicados no cluster
##             porém comandos que exitam as tabelas mysam não são. Ou seja
##             UPDATE/INSERT direto na tabela de sistema mysql precisa ser feito
##             em TODOS os nós.

#### Trocar senha de usuário comum _____________________________________________
# @see http://galeracluster.com/documentation-webpages/userchanges.html

# Execute os comandos EM TODOS OS NÓS (não pode ser apenas um deles)
# SET PASSWORD FOR 'username'@'%' = PASSWORD('newpassword');
# FLUSH PRIVILEGES;

#### Alterar permissões de usuario já existente ________________________________
# Nota: este comando pode ser em qualquer nó. Ele passa para os demais

# GRANT ALL ON databasename.* TO 'username'@'%';

#------------------------------------------------------------------------------#
# SEÇÃO MONGODB: 1. INSTALAÇÃO E CONFIGURAÇÃO INICIAL                          #
# TL;DR: ...                                                                   #
#------------------------------------------------------------------------------#
# @see https://github.com/fititnt/cplp-aiops/issues/48

# @see https://www.mongodb.com/
# @see https://www.hostinger.com.br/tutoriais/instalar-mongodb-ubuntu
# @see https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-18-04
# @see https://docs.mongodb.com/manual/core/replica-set-high-availability/
# @see https://computingforgeeks.com/how-to-setup-mongodb-replication-on-ubuntu-18-04-lts/
# @see https://docs.mongodb.com/manual/tutorial/backup-and-restore-tools/
# @see https://medium.com/@vvangemert/mongodb-cluster-haproxy-and-the-failover-issue-285c1523628f
# @see https://www.mongodb.com/blog/post/active-active-application-architectures-with-mongodb

# TODO: adicionar no issue do GitHub:
# @see https://docs.mongodb.com/manual/administration/security-checklist/
# @see https://docs.mongodb.com/manual/security/

## Configurar pacotes
# @see https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb-community-edition-using-deb-packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt update

sudo apt install mongodb-org

sudo systemctl start mongod
sudo systemctl enable mongod

#------------------------------------------------------------------------------#
# SEÇÃO MONGODB: 1. INICIALIZAÇÃO DE CLUSTER MONGODB                           #
# TL;DR:                                                                       #
#------------------------------------------------------------------------------#
# @see https://medium.com/@rossbulat/deploy-a-3-node-mongodb-3-6-replica-set-with-x-509-authentication-self-signed-certificates-d539fda94db4
# @see https://www.alibabacloud.com/blog/high-availability-mongodb-cluster-configuration-solutions_490866


#------------------------------------------------------------------------------#
# SEÇÃO REDIS: 1. INSTALAÇÃO E CONFIGURAÇÃO INICIAL                            #
# TL;DR: Explica como instalar um Redis simples, sem modo cluster habilitado   #
#------------------------------------------------------------------------------#
# @see https://github.com/fititnt/cplp-aiops/issues/51
# @see https://redis.io/topics/quickstart

# @see https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04
sudo apt update
sudo apt install redis-server

sudo vim /etc/redis/redis.conf
# Altere
#    supervised no
# Para:
#    supervised systemd

sudo systemctl restart redis.service
#sudo systemctl enable redis #Bug: Failed to enable unit: Refusing to operate on linked unit file redis.service

sudo systemctl status redis

### Testar Redis (simples, sem ser cluster) ____________________________________
# Por padrão, redis-cli tentará conectar na instância instalada localmente

redis-cli
ping
# Resposta deve ser: PONG
set test "It's working!"
get test
# Resposta deve ser "It's working!"
exit

#------------------------------------------------------------------------------#
# SEÇÃO REDIS: 2. INICIALIZAÇÃO DE CLUSTER REDIS                               #
# TL;DR:                                                                       #
#------------------------------------------------------------------------------#
# @see https://redis.io/topics/cluster-tutorial

# TODO: ler com calma o https://redis.io/topics/cluster-tutorial. Porém
#       comparado a um banco de dados SQL tradicional mesmo se bem configurado
#       existem casos em que Redis não tem consitência nos writes. Ou seja, nós
#       não temos como prometer algo que nem os desenvolvedores garantem. Por
#       isso podemos deixar ajutes de fato no Redis apenas quando houver uso
#       em alguma aplicação de usuário (fititnt, 2019-05-28 20:51)