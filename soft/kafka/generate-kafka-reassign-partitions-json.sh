#!/bin/bash
# date: 05-17-2024
# auth: wolf-li
# description:
#   generate the json file for kafka reassign partitions
# usage: 
#   ./script kafka-server:port

if [[ $# -eq 1 ]];then
  ip_port_regex='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	if [[ "$1" =~ $ip_port_regex ]]; then
		kafka-topics.sh --bootstrap-server $1 --describe | grep -Ev '^T' | awk -F':' '{print $2}' | awk '{print $1}' > t1
		kafka-topics.sh --bootstrap-server $1 --describe | grep -Ev '^T' | awk -F':' '{print $3}' | awk '{print $1}' > t2
		replice=$(kafka-metadata-quorum.sh --bootstrap-server $1 describe --status | grep CurrentVoters | awk '{print $2}' | sed -e 's/\[//g' -e 's/\]//g')
		paste t1 t2  > kafka-topic.txt
		awk -v bash_var="$replice" '{print $0,"      ",bash_var}' kafka-topic.txt > temp_file && mv temp_file kafka-topic.txt
		rm -f t1 t2
	else
		echo "wrong args, you should input kafka_server_ip:port"
		exit 1
	fi
else
        echo "wrong args, you should input kafka_server_ip:port"
        exit 1
fi


str=''
cat  kafka-topic.txt |  while  read LINE
do
         l=($LINE)
         str+="{\"topic\": \"${l[0]}\",\"partition\": ${l[1]},\"replicas\": [${l[2]}]},"
         echo $str > tmp
done

sed  's/,$//g' tmp > tmp1
str1=$(cat tmp1)
cat <<EOF> reassignment.json
{
    "version": 1,
    "partitions": [
        $str1
    ]
}
EOF
rm -f tmp tmp1 kafka-topic.txt
