#!/bin/bash
echo -----Phase 1: Key generation-----
if [ -f ~/.ssh/id_rsa.pub ]
then
	echo Already had!
else
	ssh-keygen -t rsa
	echo Satisfactory generation!
fi

valid='["y","n"]'
echo Do you want to save the public keys of the hosts?
echo Remember if you do that, this hosts can make ssh with you with out password [y/n] :
read option

while ! [[ $option =~ $valid ]]
do
	echo Bad option, try again[y/n]:
	read option
done


if [ $option == "y" ]
then
	echo -----Phase 2: Saved keys-----
	cd ~/.ssh/
	if [ -f known_hosts ]
	then
		echo Known_hosts already exists
	else
		touch known_hosts
	fi

	if [ -f authorized_keys ]
	then
		echo Authorized_keys already exists
	else
		touch authorized_keys
	fi

	known_hosts=$(cat known_hosts)
	authorized_keys=$(cat authorized_keys)
	cd ..
	cd ssh-utility-script

	while read host
	do
		read pass
		clave=$(ssh-keyscan -t rsa $host)
		if [[ $known_hosts =~ "$clave" ]]
		then
			echo $host Already exists in known_hosts
		else
			echo $clave >> ~/.ssh/known_hosts
		fi

		if [[ $authorized_keys =~ "$clave" ]]
		then
			echo $host Alredy exists in authorized_keys
		else
			echo $clave >> ~/.ssh/authorized_keys
		fi
	done < netInf
else
	echo -----Phase 2: Omited-----
fi

echo -----Phase 3: Share keys-----
while read host
do
	read pass
	sshpass -p $pass ssh-copy-id -i ~/.ssh/id_rsa.pub $host
done < netInf

echo -----Phase Demo: Verify ssh conection-----

if [ ! -d proof ]
then
	mkdir proof
fi

while read host
do
	read pass
	echo Copying proof directory in machine $host
	scp -r proof $host:/root
done < netInf
echo If everything went well, there should be a directory called proof on each of the hosts, check it

rmdir proof
