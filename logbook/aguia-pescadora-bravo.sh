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
# Login:
#   ssh user@aguia-pescadora-bravo.etica.ai
#   mosh user@aguia-pescadora-bravo.etica.ai
#   ssh user@abp.etica.ai
#   mosh user@abp.etica.ai
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

### Traceroute e afins _________________________________________________________
sudo apt install traceroute

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

## Caso o usuario perca acesso ao sistema
sudo passwd UsernameDoUsuario
# Digite uma senha temporaria, então execute o seguinte para força-la temporaria
sudo passwd -e UsernameDoUsuario


### Guia para ser feito por cada usuário de sistema (copie e cole), fim

## cdiegosr
sudo adduser cdiegosr
sudo passwd -e cdiegosr
sudo chsh -s /usr/bin/fish cdiegosr

## fititnt
sudo adduser fititnt
sudo passwd -e fititnt
sudo chsh -s /usr/bin/fish fititnt
sudo usermod -aG sudo fititnt

## loopchaves
sudo adduser loopchaves
sudo passwd -e loopchaves
sudo usermod -aG sudo loopchaves


#------------------------------------------------------------------------------#
# SEÇÃO: EDITORES DE TEXTO, EDITORES DE CÓDIGO, IDES                           #
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
# SEÇÃO: AMBIENTES DE DESENVOLVIMENTO DE LINGUAGENS DE PROGRAMAÇÃO             #
# TL;DR: Configurações específicas de interpretadores e/ou compiladores        #
#------------------------------------------------------------------------------#

## Ambientes a serem considerados...
# F# https://fsharp.org/use/linux/
# Julia (nao tem package manager oficial) https://julialang.org
# Rust https://www.rust-lang.org/tools/install
# Conda (multiplos usuarios; nao vai ser trivial)
#   <https://medium.com/@pjptech/installing-anaconda-for-multiple-users-650b2a6666c6>
#   <https://www.digitalocean.com/community/tutorials/how-to-install-anaconda-on-ubuntu-18-04-quickstart>
#   <https://stackoverflow.com/questions/48871289/how-to-share-an-anaconda-python-environment-between-multiple-users>
#   <https://medium.freecodecamp.org/why-you-need-python-environments-and-how-to-manage-them-with-conda-85f155f4353c>
#   <https://docs.anaconda.com/anaconda/install/>
#   <https://hub.docker.com/r/continuumio/anaconda3/dockerfile>

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
# @see https://php.net/
# @see https://www.php.net/manual/pt_BR/

# PHP 7.2
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
# SEÇÃO: AJUDA AO USUARIO                                                      #
# TL;DR: Lista como é documentado ao usuario final o que este servidor         #
#        oferece. Em geral é uma forma de documentar as IDEs e todos os        #
#        interpretadores/compiladores de linguagens de programação             #
#------------------------------------------------------------------------------#

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
# temp...
# O que estiver a partir daqui são comandos que foram realizadas e ainda não
# foram propriamente documentados (fititnt, 2019-05-19 05:04 BRT)
apt-get install fish
