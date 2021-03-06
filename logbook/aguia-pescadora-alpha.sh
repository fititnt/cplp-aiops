echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit
######################  Diario de bordo: aguia-pescadora #######################
# 2 vCPUs, 1,5GB RAM, 30GB SSD (CloudAtCost), Canadá
# Ubuntu 16.04.2 LTS 64bit
# aguia-pescadora.etica.ai (104.167.109.226)
#
# Sobre esta documentação de configuração de servidor:
#   License: Public Domain (não é preciso citar créditos ao copiar)
#
# Sobre como fazer login no servidor
#   Por terminal de comando:
#     ssh seuusuario@aguia-pescadora-alpha.etica.ai
#     mosh seuusuario@aguia-pescadora-alpha.etica.ai
#
#   Por programa gráfico:
#     Servidor: aguia-pescadora-alpha.etica.ai
#     Usuário: seuusuario
#     Porta: 22
#     Protocolo: "SSH", ou "SCP". Talvez "SFTP" (Aviso: não temos "FTP" aqui!)
#
################################################################################

#------------------------------------------------------------------------------#
#  ***Envie avisos de segurança para rocha(at)ieee.org sobre este servidor.***
# Porém tenha em mente alguns pontos:
#
#   1. Por decisão de projeto este servidor não tem o firewall padrão ligado.
#      - Motivo: é um servidor laboratório, e não é possível dar acesso root
#        para todos. Porém ajustes no servidor que não atrapalhem os usuários
#        são bem vindas
#      - Sugestão para quem quer replicar com firewall ligado:
#        https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04
#
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
ssh root@104.167.109.226


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

sudo hostnamectl set-hostname aguia-pescadora-alpha.etica.ai

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
sudo usermod -aG sudo fititnt

## kissabi
sudo adduser kissabi
sudo passwd -e kissabi

## loopchaves
sudo adduser loopchaves
sudo passwd -e loopchaves
sudo usermod -aG sudo loopchaves

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

##### Customização de motd (Mensagem do dia), inicio
### @see https://linuxconfig.org/how-to-change-welcome-message-motd-on-ubuntu-18-04-server
# Desliga mensagem padrão de ajuda do Ubuntu 18
sudo chmod +x /etc/update-motd.d/10-help-text

# Desliga mensagem remota da Canonical
vim /etc/default/motd-news
# altera ENABLED=1 para ENABLED=0

## Cria uma mensagem customizada nossa
sudo touch /etc/update-motd.d/11-aguia-pescadora
sudo chmod +x /etc/update-motd.d/11-aguia-pescadora

vim /etc/update-motd.d/11-aguia-pescadora
# customizar...

# @TODO testar melhor bugs no motd customizado (fititnt, 2019-05-16 03:56 BRT)


##### Comando de ajuda do servidor
touch /usr/local/bin/ajuda
sudo chmod +x  /usr/local/bin/ajuda

vim /usr/local/bin/ajuda
# customizar aqui... o arquivo esta commitado no repositorio

##
####
##### Customização de motd (Mensagem do dia), fim

##### Ambientes de desenvolvimento / Linguagens de programação, inicio

##### Ambientes de desenvolvimento / Linguagens de programação
#### C/C++
# @see https://linuxconfig.org/how-to-install-gcc-the-c-compiler-on-ubuntu-18-04-bionic-beaver-linux
#

sudo apt install gcc build-essential
#  The following NEW packages will be installed:
#    binutils binutils-common binutils-x86-64-linux-gnu build-essential cpp cpp-7 dpkg-dev fakeroot g++ g++-7 gcc gcc-7 gcc-7-base libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan4 libatomic1
#    libbinutils libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdpkg-perl libfakeroot libfile-fcntllock-perl libgcc-7-dev libgomp1 libisl19 libitm1 liblsan0 libmpc3 libmpx2 libquadmath0 libstdc++-7-dev libtsan0 libubsan0
#    linux-libc-dev make manpages-dev

#### NodeJS
###
##
#
# @see https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-18-04
sudo apt install nodejs
sudo apt install npm

# @TODO: considerar dar mais opções. Ou então deixar que o usuario escolha versões exatas, e aqui permanecer o padrao de sistema (fititnt, 2019-05-16 05:59 BRT)

#### PHP
###
##
# PHP 7.2
sudo apt install php-cli php-common

# @TODO por padrão instala o 7.2 (que assim como python nem é a ultima); considerar melhorar mais opções disso (fititnt, 2019-05-16 04:39 BRT)

#### Python
###
##
# Python3 no Ubuntu 18.04 (ele já vem instalado, mas como python3)
apt install python3

# Python 2.7 no Ubuntu 18.04 (ele já vem instalado, mas como python3)
apt install python-minimal

# @TODO ver com mais calma versoes padroes do python (fititnt, 2019-05-16 03:56 BRT)

##### Ambientes de desenvolvimento / Linguagens de programação, fim

##### Editores de texto / Editores de código via terminal, inicio
####
##
#
#### Emacs
sudo apt install emacs

#### nano
# Já veio instalado com o Ubuntu 18.04

#### NeoVim
# @see https://neovim.io/
# @see https://www.youtube.com/watch?v=kZDT10nFiTY

# @TODO considerar instalar o NeoVim, que em tese seria mais amigável que o Vim (fititnt, 2019-05-16 06:27 BRT)

#### vi/ vim
# Já vieram instalados com o  Ubuntu 18.04

#
##
###
##### Editores de texto / Editores de código via terminal, inicio

##### Jogos de terminal, inicio
####
###
##
# @see https://www.ubuntupit.com/top-20-best-linux-terminal-console-games-that-you-can-play-right-now/

### bastet
sudo apt-get install bastet

### BSD Games
## see https://github.com/vattam/BSDGames
sudo apt-get install bsdgames

### Dunnet (easter egg do Emacs)
emacs -batch -l dunnet

### greed
sudo apt-get install greed

### moon-buggy
sudo apt-get install moon-buggy

### NetHack
# @see https://www.nethack.org/
sudo apt-get install nethack-console

### nsnake
sudo apt-get install nsnake

### ninvaders
sudo apt-get install ninvaders

### nudoku
sudo apt-get install nudoku

### Tron (multiplayer, via SSH)
# ssh sshtron.zachlatta.com

### zangband
sudo apt-get install zangband

##
###
##### Jogos de terminal, fim

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

vim /etc/nginx/sites-available/haproxy.apa.etica.ai.conf
# Adicione todas as customizacoes no arquivo acima...

sudo ln -s /etc/nginx/sites-available/haproxy.apa.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx -d haproxy.apa.etica.ai

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
# - http://aguia-pescadora-alpha.etica.ai
# - https://aguia-pescadora-alpha.etica.ai
# - http://apa.etica.ai
# - https://apa.etica.ai

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

sudo vim /etc/nginx/sites-available/aguia-pescadora-alpha.etica.ai.conf
# Adicione todas as customizacoes deste usuario no arquivo acima...

sudo ln -s /etc/nginx/sites-available/aguia-pescadora-alpha.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Linha de comando para obter certificados. Automaticamente já edita configurações do NGinx
sudo certbot --nginx -d aguia-pescadora-alpha.etica.ai -d apa.etica.ai


### Userdir
# Userdir não implementado em Alpha

### Portas internas ____________________________________________________________
# Subdomínios padronizados com HTTP/HTTPS para portas comuns
# ISSUE: https://github.com/fititnt/cplp-aiops/issues/57

vim /etc/nginx/sites-available/PORTAS-INTERNAS.apa.etica.ai.conf
# Adicione as configurações desejadas neste servidor no arquivo acima...
sudo ln -s /etc/nginx/sites-available/PORTAS-INTERNAS.apa.etica.ai.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

sudo certbot --nginx \
  -d 2000.apa.etica.ai \
  -d 3000.apa.etica.ai \
  -d 4000.apa.etica.ai \
  -d 5000.apa.etica.ai \
  -d 6000.apa.etica.ai \
  -d 7000.apa.etica.ai \
  -d 8000.apa.etica.ai \
  -d 8080.apa.etica.ai \
  -d 8888.apa.etica.ai \
  -d 9000.apa.etica.ai


# PROTIP: acompanhe os arquivos a seguir para debugar
#             tail -f /var/log/nginx/access.log
#             tail -f /var/log/nginx/error.log
#         Em geral o principal motivo de erro serão permissões de arquivo e de
#         diretório até o respectivo arquivo



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