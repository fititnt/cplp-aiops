echo "Este diário de bordo foi feito para ser visualizado, nao executado assim!"
exit

################### Diario de bordo: aguia-pescadora-charlie ###################
# VPS (KVM), 1 vCPUs, 4GB RAM, 40GB SSD, Ubuntu Server 18.04 64bit, OVH (Canada)
#
# Datacenter: OVH, Canada
# Type: Virtual Machine, KVM
# OS: Ubuntu Server 18.04 LTS 64bit
# CPU: 1vCPUs
# RAM: 3848 MB
# Disk: 80GB
#
# IPv4: 192.99.69.2
# IPv6: 2607:5300:0201:3100:0000:0000:0000:0398
# Domain:
#   Full: aguia-pescadora-charlie.etica.ai
#   Short: apc.etica.ai
#
# Domain, extras:
#  - apc.etica.ai (TTL: 15 min)
#      - CNAME aguia-pescadora-charlie.etica.ai (sempre aponta para Charlie)
#  - usuario.apc.etica.ai (TTL: 15 min)
#      - CNAME aguia-pescadora-charlie.etica.ai (sempre aponta para Charlie)
#      - Veja https://github.com/fititnt/cplp-aiops/issues/35
#  - lb-ap.etica.ai (TTL: 2 min)
#      - Balanceamento de carga via Round-robin DNS.
#      - Veja github.com/fititnt/cplp-aiops/issues/40
#  - usuario.lb-ap.etica.ai (TTL: 2 min)
#      - CNAME lb-ap.etica.ai (Balanceamento de carga via Round-robin DNS)
#      - Veja github.com/fititnt/cplp-aiops/issues/35
#      - Veja github.com/fititnt/cplp-aiops/issues/40
#
# Login:
#   ssh user@aguia-pescadora-charlie.etica.ai
#   mosh user@aguia-pescadora-charlie.etica.ai
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
# SECURITY:
#   Reporting a Vulnerability:
#   Send e-mail to Emerson Rocha: rocha(at)ieee.org.
################################################################################
