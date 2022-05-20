#!/bin/bash
myBASENAME=`basename $(pwd)`

docker kill $myBASENAME-pg_green-1 \
            $myBASENAME-pg_blue-1  \
	    $myBASENAME-pg_red-1   

docker-compose down -v
docker image rm $myBASENAME\_pg_blue  \
                $myBASENAME\_pg_green \
		$myBASENAME\_pg_red   
docker volume rm $myBASENAME\_pg_blue_data $myBASENAME\_pg_green_data $myBASENAME\_pg_red_data $myBASENAME\_shared_tmp 2>/dev/null
