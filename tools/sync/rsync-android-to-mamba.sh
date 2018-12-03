# Sincronizar pasta local em celular Android com servidor remoto, via rsync

# Android 4.0+: (?)
# Android 5.0+: Pode-se usar Termux (https://termux.com/)

# Sincroniza pasta do celular Android com site www.kayen.ga
rsync -tir /storage/sdcard0/mamba/kissabi/ kissabi@mamba.kayen.ga:/home/kissabi/public_html

# Sincroniza pasta do celular Android com site pyladies.kayen.ga
rsync -tir /storage/sdcard0/mamba/pyladies/ kissabi@mamba.kayen.ga:/home/pyladies/public_html
