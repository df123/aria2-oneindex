#!/bin/bash
path=$3
downloading="/home/aria2/downloads/"
log_path="/home/aria2/.aria2/upload.log"
temp="/"

if [ $2 -eq 0 ]
then
	exit 0
fi

if [ $2 -eq 1 ]
then
	echo "file" >> $log_path
	echo "$path" >> $log_path
	echo "start time $(date)" >> $log_path

    php /var/www/oneindex/one.php upload:file "$path" >> $log_path

	echo "complete time $(date)" >> $log_path
	echo -e >> $log_path
	exit 0
else
	path_length=${#path}
	downloading_length=${#downloading}
	length=$((path_length-downloading_length))

	for i in `seq $downloading_length $((path_length-1))`
	        do
			temp_a=${path:$((i)):1}
			if [ $temp_a == $temp ] 
			then
				index=i
				break
			fi																  
			done
	docl_root_path=${path:$((0)):$index}
	docl_name_path=${path:$((downloading_length)):$((index-downloading_length))}

	echo "folder" >> $log_path
	echo "$path" >> $log_path
	echo "$docl_root_path" >> $log_path
	echo "start time $(date)" >> $log_path

    php /var/www/oneindex/one.php upload:folder "$docl_root_path" /"$docl_name_path"/ >> $log_path
	
	echo "complete time $(date)" >> $log_path
	echo -e >> $log_path
	exit 0
fi