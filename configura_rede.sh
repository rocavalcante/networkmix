#!/bin/bash

#**********************************************#
# Script para configuracao de rede assistida
# Cliente: Prefeitura de Guarapuava
# Desenvolvido: Polilinux
# Versao 0.1
# Data 25/09/2017
#**********************************************#

#***********************************#
#     Configuracao kerberos
#   modificacao em /etc/krb5.conf
#***********************************#

getNomeMaquina()
{
	NMaquina=$(zenity --title="POC - NOME DA ESTACAO" --text "Insira o nome da estação" --entry --width="300")
	zenity --info --title="POC - NOME DA ESTACAO" --text=" Nome digitado: $NMaquina" --width="300"
	logger "POC:DEBIAN-PoliLinux coletado nome estacao = $NMaquina"
}

getDominio()
{
	Dominio=$(zenity --title="POC - DOMINIO" --text "Insira o dominio da rede" --entry --width="300")
	zenity --info --title="POC - DOMINIO" --text="Dominio digitado: $Dominio" --width="300"
	logger "POC:DEBIAN-PoliLinux coletado dominio da estacao = $Dominio"
}	

getUsuario()
{
	User=$(zenity --title="POC - Usuario" --text "Insira o usuario de login da rede" --entry --width="300") 
	zenity --info --title="POC - DOMINIO" --text="Usuario digitado: $User"
	logger "POC:DEBIAN-PoliLinux coletado usuário da estacão = $User"
}	
setDominio()
{
	zenity --info --title="POC - HOSTS" --text "Alterando arquivo de hosts aguarde" --width="300"
	sed -e "/127.0.1.1/a\\$IP	$Dominio" < /etc/hosts > /etc/hosts-mod
	sed "s/polilinux/$Dominio/g" /etc/hosts >> /etc/hosts-mod
	logger "POC:DEBIAN-PoliLinux setado arquivo /etc/hosts "
	cat /etc/hosts-mod | grep $Dominio
	sleep 3
	zenity --info --title="POC - HOSTS " --text "Alteracao feita com sucesso" --width="300"
	cp /etc/hosts-mod /etc/hosts
}

getIPAD()
{
	IP=$(zenity --title="POC - IP DNS" --text "Insira o endereço de IP do DNS" --entry --width="300")
	zenity --info --title="POC - DOMINIO" --text="IP: $IP" --width="300"
	logger "POC:DEBIAN-PoliLinux coletado IP do DNS = $IP"
		
}

setConf()
{
	zenity --info --title="POC - PACOTE PBIS" --text "Aguarde para digitar a senha de administrador" --width="300"
	#Executa o pacote pbis do powerbroke para configurar a estacao e o usuario na maquina

	sudo domainjoin-cli join --disable ssh $Dominio $User@$Dominio
	#Limpa arquivo de chamada de configuracao
	sudo rm /home/usuario/.config/autostart/configurarede.desktop
	logger "POC:DEBIAN-PoliLinux aplicando configuracoes de dominio"
}

bkpHosts()
{
	zenity --info --title="POC - BKP CONFIGURACOES" --text "Fazendo Backup do hosts, aguarde" --width="300"
	sudo cp /etc/hosts /etc/hosts.bkp
	logger "POC:DEBIAN-PoliLinux bkp do hosts feito"
	sleep 2
	zenity --info --title="POC - BKP CONFIGURACOES" --text "Backup realizado com sucesso" --width="300"
}
#*******************************************#
#
#                 MAIN
#
#*******************************************#

zenity --question --text "Deseja iniciar a configuração de rede?" --width="300";
var=$?
if [ $var == 0 ];
  then
	bkpHosts	
#	getNomeMaquina
	getUsuario
	getIPAD
	getDominio
	setDominio
	setConf
	cat /etc/hosts


elif [ $var == 1 ];
  then
																   		zenity --warning --title="POC:DEBIAN-PoliLinux" --text="Saindo do assistente" --width="300"
fi
	echo " "

