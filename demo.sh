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

	for i in $@
	do
		clave=$(ssh-keyscan -t rsa $i)
		if [[ $known_hosts =~ "$clave" ]]
		then
			echo $i Already exist in known_hosts
		else
			echo $clave >> ~/.ssh/known_hosts
		fi

		if [[ $authorized_keys =~ "$clave" ]]
		then
			echo $i Alredy exist in authorices_keys
		else
			echo $clave >> ~/.ssh/authorized_keys
		fi
	done
else
	echo -----Phase 2: Omited-----
fi

echo -----Phase 3: Share keys-----
for i in $@
do
	sshpass -f pass ssh-copy-id -i ~/.ssh/id_rsa.pub $i
	let count=count+1
done

echo -----Phase Demo: proof ssh conection-----

if [ ! -d proof ]
then
	mkdir proof
fi

for i in $@
do
	echo Copying proof directory in machine $i
	scp -r proof $i:/root
	echo Check that the directory was created before continuing
	read -p "Press enter to continue"
	ssh $i 'rmdir /root/proof'

done

rmdir proof
