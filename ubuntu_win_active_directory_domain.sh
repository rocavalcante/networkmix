#!/bin/bash

## Integrar Ubuntu 16.04 32/64Bits no Windows Active Directory Domain – Fullest Integration
## Fonte https://gist.github.com/jniltinho/da0ef938ece852f57faa502c788a82a4


### Primeira Etapa ----------------------------------------------------------------------------
## Voce precisa mudar a linha abaixo
MY_DOMAIN="mydomain.local"

GET_ARCH=$(getconf LONG_BIT)

PBIS_OPEN="https://github.com/BeyondTrust/pbis-open/releases/download/8.5.2"
PBIS_FILE="pbis-open-8.5.2.265.linux.x86_64.deb.sh"


if [ "$GET_ARCH" -eq "32" ]; then
   PBIS_OPEN="https://github.com/BeyondTrust/pbis-open/releases/download/8.5.2"
   PBIS_FILE="pbis-open-8.5.2.265.linux.x86.deb.sh"
fi

cd /tmp/
wget -c $PBIS_OPEN/${PBIS_FILE}
chmod +x $PBIS_FILE
./$PBIS_FILE
rm -f $PBIS_FILE

### Configurar o Systemd ------------------------------------
cp /etc/pbis/redhat/lwsmd.service /lib/systemd/system/
sed -i "s|PrivateTmp=true|PrivateTmp=false|" /lib/systemd/system/lwsmd.service
/etc/init.d/lwsmd stop
update-rc.d -n -f lwsmd remove
systemctl daemon-reload
systemctl start lwsmd.service
systemctl enable lwsmd.service
cd /etc/systemd/system
ln -s /lib/systemd/system/lwsmd.service

shutdown now -r
### Fim da Primeira Etapa ---------------------------------------------------------------------

### Segunda Etapa ----------------------------------------------------------------------------
### Apos reiniciar execute os comandos abaixo como root:
MY_DOMAIN="mydomain.local"
/opt/pbis/bin/domainjoin-cli join $MY_DOMAIN administrator@$MY_DOMAIN
shutdown now -r
### Fim da Segunda Etapa ---------------------------------------------------------------------


### Terceira Etapa ----------------------------------------------------------------------------
### Apos reiniciar execute os comandos abaixo como root:
MY_DOMAIN="mydomain.local"
/opt/pbis/bin/config AssumeDefaultDomain true
/opt/pbis/bin/config UserDomainPrefix $MY_DOMAIN
/opt/pbis/bin/config LoginShellTemplate /bin/bash
/opt/pbis/bin/config HomeDirTemplate %H/%D/%U
/opt/pbis/bin/update-dns
/opt/pbis/bin/ad-cache --delete-all
sed -i "s|session\toptional\tpam_lsass.so|session [success=ok default=ignore] pam_lsass.so|" /etc/pam.d/common-session


### Para regras de sudo para Admins e Devs:
### Aqui voce precisa mudar o mydomain
echo '%mydomain\\linuxadmins ALL=(ALL:ALL) ALL' >> /etc/sudoers
echo '%mydomain\\linuxdevs ALL=(ALL:ALL) ALL' >> /etc/sudoers


### Para Corrigir Tela de Login
if [ -f "/usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf" ];then
echo 'allow-guest=false
greeter-show-remote-login=false
greeter-show-manual-login=true' >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
fi

shutdown now -r
### Fim da Terceira Etapa ---------------------------------------------------------------------

## Dica
## Caso você efetue o Upgrade no Ubuntu e por algum motivo seja alterado os arquivos do /etc/pam.d/
## Dessa forma o login no AD não vai mais funcionar.
## Então execute o comando abaixo como root, responda sim/yes e depois reinicie o Desktop.
## domainjoin-cli configure --enable pam
## http://serverfault.com/questions/630746/pbis-open-ad-authentication-stops-working-on-ubuntu-with-errors-user-accout-ha

## LINKS:
## http://askubuntu.com/questions/452904/likewise-open-14-04-other-easy-way-to-connect-ad
## http://www.kiloroot.com/add-ubuntu-14-04-lts-server-to-a-windows-active-directory-domain-fullest-integration/
## http://download1.beyondtrust.com/Technical-Support/Downloads/PowerBroker-Identity-Services-Open-Edition/?Pass=True
