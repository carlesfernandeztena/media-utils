#!/bin/bash
if [ $# -lt 1 ]
then
	echo
	echo "Usage: $0 <query> <target_dir>"
	echo
else
	query=$1
	query="${query//" "/"+"}"
	if [ $# == 2 ]	
	then
		targetdir=$2
	else
		targetdir=$query
	fi

	if [ -d $query ]
	then
		echo "Directory already exists!"
	else

		# send query. To have only faces, we added "&tbs=itp:face"
		searchpagefile=$targetdir/searchpage.html
		imglistfile=$targetdir/imagelist.txt
		echo "QUERY = $query"
		mkdir -p $targetdir
		curl "https://www.google.es/search?q=${query}&sa=X&biw=394&bih=723&tbm=isch&tbs=itp:face&ei=58KCVqC0OIL9UqXuhNgH&ved=0ahUKEwjgw52UzIHKAhWCvhQKHSU3AXsQuT0IMCgB&vet=10ahUKEwjgw52UzIHKAhWCvhQKHSU3AXsQuT0IMCgB.58KCVqC0OIL9UqXuhNgH.i" -H 'Referer: https://www.google.es/' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2599.0 Safari/537.36' --compressed -s > $searchpagefile	

		# extract urls
		rm -rf $imglistfile
		grep -o 'http[^"]*jpg' $searchpagefile >> $imglistfile

		# Remove duplicate images
		cat $imglistfile | sort | uniq > temp
		mv temp $imglistfile
		rm -rf temp

		# download images
		cat $imglistfile | while read url
		do
			file=$targetdir/${url##*/}
			if [ ! -s $file ] # if file is empty or does not exist
			then
				echo -n .
				wget -O $file --tries=3 --retry-connrefused --waitretry=1 --timeout=3 $url -q
				# delete if zero bytes
				if [ ! -s $file ]; then rm -rf $file; fi 
			fi
		done
		echo
		rm $imglistfile
		rm $searchpagefile
	fi
fi

