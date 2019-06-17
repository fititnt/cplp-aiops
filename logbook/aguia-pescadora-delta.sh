echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

################### Diario de bordo: aguia-pescadora-delta ###################
# VPS (KVM), 6 vCPUs, 16GB RAM, 400GB SSD, Ubuntu Server 18.04 64bit, Contabo (Germany)
#
# Datacenter: Contabo, Germany
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 6 vCPUs
# RAM: 16040 MB
# Disk: 400 GB
#
# IPv4: 173.249.10.99
# IPv6: 
# Domain:
#   Full: aguia-pescadora-delta.etica.ai (TTL: 15 min)
#   Short: apd.etica.ai (TTL: 15 min)
#
# -----------------------------------------------------------------------------#
# LICENSE: Public Domain
#   Except where otherwise noted, content on this server configuration and to
#   the extent possible under law, Emerson Rocha has waived all copyright and
#   related or neighboring rights to this work to Public Domain
#
# MAINTAINER: Emerson Rocha <rocha(at)ieee.org>
#   Keep in mind that several people help with suggestions, testing, bugfixes
#   and inspiration without get names noted in places that most software
#   developers look. I'm saying this in special for people who help over
#   Facebook discussions. Even the ones without a personal computer yet and/or
#   with limited access to internet.
#
# SECURITY:
#   Reporting a Vulnerability:
#   Send e-mail to Emerson Rocha: rocha(at)ieee.org.
################################################################################

### Primeiro login______________________________________________________________
# Você, seja por usuario + senha, ou por Chave SSH, normlamente terá que acessar
# diretamente como root. Excessões a esta regra (como VMs na AWS) geralmente
# implicam em logar em um usuario não-root e executar como sudo. Mas nesta da
# é por root mesmo nesse momento.
ssh root@173.249.10.99

### Atualizar o sistema operacional_____________________________________________
# O sistema operacional (neste caso, Ubuntu) normalmente não vai estar 100%
# atualizado. Os comandos abaixo são uma boa prática pra fazer imediatamente
sudo apt update
sudo apt upgrade -y
sudo apt autoremove

### Define um hostname personalizado____________________________________________
# O hostname padrão geralmente não faz muito sentido pra você e os usuparios
# da VPS. No nosso caso, era vps240016, como em root@vps240016.
# Nota: o domínio 'aguia-pescadora-bravo.etica.ai' já aponta para 192.99.247.117
sudo hostnamectl set-hostname aguia-pescadora-delta.etica.ai

# Edite /etc/hosts e adicione o hostname também apontando para 127.0.0.1
sudo vi /etc/hosts
## Adicione
# 127.0.0.1 aguia-pescadora-delta.etica.ai  aguia-pescadora-delta

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

## TODO: remover o language-pack-pt de Delta. Usuarios finais
#        não irão acessar o host, e até mesmo administradores tenderão
#        fortemente a apenas usar o Tsuru (fititnt, 2019-06-16 01:44 BRT)

### Criar Swap & ajusta Swappiness______________________________________________
## TODO: setup swap from 2GB (defalt from Contabo) to 16GB (fititnt, 2019-06-12 08:55 BRT)


### Não documentado ____________________________________________________________
sudo mkdir /backups