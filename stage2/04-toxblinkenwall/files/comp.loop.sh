#! /bin/bash

cd

while [ true ]; do

	sleep 10
	cd

	if [ -f ./compile_me.txt ]; then
		bash ./_compile_loop.sh
	fi
done
