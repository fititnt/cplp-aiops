echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit
##################### Diario de bordo: devel-fititnt-bravo #####################
# Notebook, 8 CPUs, 16GB RAM, 2x 640GB HD, Ubuntu Desktop 16.04 LTS, personal
#
# @see https://github.com/fititnt/cplp-aiops/issues/59
#
# DESCRIPTION: para inicializar o Tsuru (vide https://github.com/fititnt/cplp-aiops/issues/59)
#              é recomendado fazer de uma máquina remota (como a do gerente
#              administrador de sistemas) ou uma máquina especialmente criada
#              para este fim. Este diário de bordo apenas descreve como
#              reproduzir os passos iniciais para ter o servidor 
#              aguia-pescadora-charlie.etica.ai minimamente operacional
#
# Domain, extras:
#   (sem domínios externos configurados para acessar esta máquina)
#
# Login:
#   (login remoto não permitido, está é uma máquina que desenvolvedor acessa
#    fisicamente)
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
# SEÇÃO: PREPARAÇÃO PARA INICIALIZAR TSURU REMOTAMENTE                         #
#                                                                              #
# SEE:   https://github.com/fititnt/cplp-aiops/issues/59                       #
#                                                                              #
# TL;DR: por questão de clareza (e também por se aplicar a diversas máquinas)  #
#        alguns passos mais complexos nas máquinas locais serão detalhados aqui#
#        e não nas configurações dos servidores finais configurado             #
#                                                                              #
# AVISO: Estes passos não estarão tão detalhados como os do servidor remoto,   #
#        pois muitas configurações já estavam prontas. Porém pelo link para    #
#        documentações oficiais serão mencionados.                             #
#------------------------------------------------------------------------------#

#### DOCKER: Instalar Docker Engine ____________________________________________
# @see https://docs.docker.com/install/linux/docker-ce/ubuntu/

# Siga a documentação em https://docs.docker.com/install/linux/docker-ce/ubuntu/.
# Note que se sua distribuição não for exatamente esta, ainda assim encontrara
# documentação para outras distribuições linux e até mesmo para Windows.
#
# Aparentemente usuários de Windows e de Mac já vem com docker-machine
# instalado, mas não os de Ubuntu (meu caso aqui).

# Ao final, você deve ter algo como isto aqui
docker -v # Docker version 18.09.6, build 481bc77

#### DOCKER: Instalar Docker Machine ___________________________________________
# @see https://docs.docker.com/machine/install-machine/
# @see https://github.com/docker/machine/releases/

# Veja https://github.com/docker/machine/releases/ e instale a ultima versão.
# A seguir os comandos executados na versão mais atual em que se escreveu este
# guia

curl -L https://github.com/docker/machine/releases/download/v0.16.1/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

# Nota, o comando acima não funciona de primeira no fish (use bash e zsh)

# Execute o comando a seguir para ver se tem está com docker-machine operacional
docker-machine -v  # docker-machine version 0.16.1, build cce350d7

#### TSURU: Remover versões antigas do Tsuru client ____________________________

# Em fititnt-bravo já estava instalado uma versão antiga de tsuru-client (e que
# provavelmente era gerenciada pelo 'ppa:tsuru/ppa') Isto aqui remove esta
# versão antiga que tenha sido instalado pelo apt (porém não remove as
# instaladas manualmente)
sudo apt purge tsuru-client

#### TSURU: Instalar Tsuru client (requisito para instalar o tsuru em A.P. Charlie)
# A instação do Tsuru em https://docs.tsuru.io/stable/installing/using-tsuru-installer.html
# explica que a instalação dele é feita usando o tsuru-client
#
# tsuru-client em https://tsuru-client.readthedocs.org recomenda que, em Ubuntu,
# use o 'ppa:tsuru/ppa'. Porém esse PPA não só não tem pacote para o Ubuntu 18.04 LTS
# como os pacotes para o Ubuntu 16.04 (tsuru version 1.1.1) parecem
# desatualziados o suficiente em relação a opção oferecida em https://github.com/tsuru/tsuru-client/releases
# (ultima: 1.7.0-rc2 de 2019-02-22, ou a 1.6.0 de 2018-07-19).

cd ~/tmp

wget https://github.com/tsuru/tsuru-client/releases/download/1.6.0/tsuru_1.6.0_linux_amd64.tar.gz
tar -vzxf tsuru_1.6.0_linux_amd64.tar.gz
sudo mv tsuru /usr/local/bin

cd /root/tsuru-setup
rm tsuru_1.6.0_linux_amd64.tar.gz

#### TSURU: Autocomplete de Tsuru client (OPCIONAL) ____________________________

# TODO: considerar adicionar bash-completion além de apenas o bash
#      (fititnt, 2019-06-02 03:18 BRT)
cat misc/bash-completion
# Copie o conteúdo do arquivo acima para o .bashrc ou (Ubuntu 18.04) no
#  ~/.bash_aliases do usuário que usaria o tsuru
touch ~/.bash_aliases
cat misc/bash-completion >> ~/.bash_aliases

# No meu caso, também uso zsh, então teria que adicionar conteudo a ~/.zshrc
vim ~/.zshrc
# Nota: não precisa fazer isso se você não tem instalado zsh ou se não quer que
#       zsh de autocomplete

#### TSURU: Criar arquivos padrões para iniciar Tsuru remotamente ______________

mkdir ~/tmp/tsuru
cd ~/tmp/tsuru

tsuru install-config-init

# O comando acima criará arquivos padrões no diretório atual
vim ~/tmp/tsuru/install-compose.yml
vim ~/tmp/tsuru/install-config.yml

# NOTA: as configurações dos arquivos estão em
#       (repositorio)/logbook/aguia-pescadora-charlie/__external-configs/tsuru-setup

#### TSURU: Customizações pré-instalação de aguia-pescadora-charlie.etica.ai ___
# @see https://docs.tsuru.io/1.6/installing/using-tsuru-installer.html

tsuru install-create -c install-config.yml -e install-compose.yml

# NOTA: eu não tenho certeza de como instala. Vai ser tentativa e erro
#       (fititnt, 2019-06-02 23:07 BRT)

# Crie um terceiro arquivo, vide https://docs.tsuru.io/1.6/installing/using-tsuru-installer.html
vim ~/tmp/tsuru/config.yml

# NOTA: o arquivo acima está em
#       (repositorio)/logbook/aguia-pescadora-charlie/__external-configs/tsuru-setup/config.yml
#       A chave SSH criada nele é adicionada no próximo passo, porém a privada,
#       por razões de segurança, não é adicionada ao repositório

#### CHAVE SSH: cria uma chave SSH sem password ________________________________
# @see https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# @see https://docs.tsuru.io/1.6/installing/using-tsuru-installer.html#

# A documentação do TSURU (ao menos para provedores de IaaS sem driver dedicado
# no docker-machine) que já exista um par de chave SSH que NÃO requer senha
# e que já esteja previamente autorizado para se conectar na máquina remota.
# Neste passo vamos criar uma em devel-fititnt-bravo

ssh-keygen -t rsa -b 4096 -C "aguia-pescadora-tsuru.no-reply@etica.ai" -f ~/.ssh/id_rsa-aguia-pescadora-tsuru

# Private key: ~/.ssh/id_rsa-aguia-pescadora-tsuru
# Public key: ~/.ssh/id_rsa-aguia-pescadora-tsuru.pub

#### CHAVE SSH: adiciona em aguia-pescadora.etica.ai ___________________________

cat ~/.ssh/id_rsa-aguia-pescadora-tsuru.pub
# Copie o conteúdo, logue em charlie
ssh root@aguia-pescadora-charlie.etica.ai

# cole o conteúdo ao final da ~/.ssh/authorized_keys
vim ~/.ssh/authorized_keys
exit

# Teste se a chave está funcionando. O Seguinte comando deve funcionar
# SEM pedir senha (nem de servidor remoto, nem de chave SSH)
ssh -i ~/.ssh/id_rsa-aguia-pescadora-tsuru root@aguia-pescadora-charlie.etica.ai

#### TSURU: edições prévias em config.yml e segunda tentativa _________________
# (A primeira tentativa foi usando 'tsuru install-create -c install-config.yml
# -e install-compose.yml', mas abortei enquanto ele parecia estar criando
# localmente e usando Virtualbox)

# Usando como base o 'Installing on already provisioned (or physical) hosts' de
# https://docs.tsuru.io/1.6/installing/using-tsuru-installer.html#installing-on-already-provisioned-or-physical-hosts
# criamos o config.yml
vim ~/tmp/tsuru/config.yml
# O conteúdo do arquivo acima está commitado em
# (repositorio)/logbook/aguia-pescadora-charlie/__external-configs/tsuru-setup/config.yml

# NOTA: o campo
#  generic-ssh-key: ["~/.ssh/id_rsa-aguia-pescadora-tsuru"]
#  deu erro se especificar caminho ~/.ssh, usando caminho absoluto
#  generic-ssh-key: ["/home/fititnt/.ssh/id_rsa-aguia-pescadora-tsuru"]

# NOTA: não estou 100% de como instala o tsuru no mesmo nó dos apps, porém
#       poderia ser uma boa ideia ele ficar em outra máquina (como a Bravo)
#       (fititnt, 2019-06-03 00:21 BRT)

# E então, tentamos executar usando as configurações
tsuru install-create -c config.yml

# CARALHO, funcionou com menos erros do que eu imaginava, veja em
# https://github.com/fititnt/cplp-aiops/issues/59
# O log de execução e alguns printscreens da primeira tentativa
# (e sim, a senha de admin foi trocada antes de divulgar publicamente)