#!/bin/bash
path=$3
downloadpath='/root/Download'

if [ $2 -eq 0 ]
	then
		exit 0
fi

filepath=$path
path=${path%/*}
of=${path##*/}

if [ $2 -eq 1 ]
    then
		echo "$filepath" >> /root/.aria2/oneIndexUpload.log
		echo "start file upload $(date)" >> /root/.aria2/oneIndexUpload.log
        	php /var/www/html/one.php upload:file "$filepath" >> /root/.aria2/oneIndexUpload.log
		echo "ok file upload $(date)" >> /root/.aria2/oneIndexUpload.log
		echo "del file $(date)" >> /root/.aria2/oneIndexUpload.log
		rm -rf "$filepath"
		echo "del ok file $(date)" >> /root/.aria2/oneIndexUpload.log
		echo -e >> /root/.aria2/oneIndexUpload.log
		exit 0
else
		echo "$path" >> /root/.aria2/oneIndexUpload.log
		echo "start folder upload $(date)" >> /root/.aria2/oneIndexUpload.log
		php /var/www/html/one.php upload:folder "$path" /"$of"/ >> /root/.aria2/oneIndexUpload.log
		echo "ok folder upload $(date)" >> /root/.aria2/oneIndexUpload.log
		echo "del folder $(date)" >> /root/.aria2/oneIndexUpload.log
		rm -rf "$path"
		echo "del ok folder $(date)" >> /root/.aria2/oneIndexUpload.log
		echo -e >> /root/.aria2/oneIndexUpload.log
		exit 0
fi
