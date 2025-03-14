#!/bin/bash
# auth: wolf-li
# date: 2025-2-6
# description: text to speak

if [[ $# -eq  0 ]];then
	echo "no args !!!"
	exit 1
fi

function help() {
	echo "Usage:"
	echo "  -d 中文        create voice mp3 file using input data"
	echo "  -f filename    create voice mp3 file using file"
}

date_now=$(date +%Y-%m-%d_%H-%M-%S)
result_file=$date_now.mp3

case "$1" in
	-d )
		say -v Tingting $2  -o $date_now.acc
 	;;
	-f )
		say -v meijia -f $2 -o $date_now.acc
	;;
	-h )
		help
	;;
	* )
		echo "not support that args !!!"
		help
	;;
esac

if [[ -f $date_now.acc  ]];then
	mv $date_now.acc $result_file
	echo "create file $result_file"
fi
