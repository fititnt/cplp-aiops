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

#### Instalar Docker ___________________________________________________________
# @see https://docs.docker.com/install/linux/docker-ce/ubuntu/

# Siga a documentação em https://docs.docker.com/install/linux/docker-ce/ubuntu/.
# Note que se sua distribuição não for exatamente esta, ainda assim encontrara
# documentação para outras distribuições linux e até mesmo para Windows.
#
# Aparentemente usuários de Windows e de Mac já vem com docker-machine
# instalado, mas não os de Ubuntu (meu caso aqui).