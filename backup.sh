backup_log_file_date=$(date +'%F_%R')
backup_log_file="/home/projetco2-2024/co2/docker/volumes/postgre_bkp/logs/${backup_log_file_date}.log"

touch ${backup_log_file}
echo "Starting backup at ${backup_log_file_date}" >> ${backup_log_file}

backup_temp_file="/home/projetco2-2024/co2/docker/volumes/postgre_bkp/temp"
mkdir ${backup_temp_file}

cd /home/projetco2-2024/co2/docker/volumes/postgre_bkp/temp

echo "Check if Chirpstack DB exist" >> ${backup_log_file}
DB_Chirpstack=$(docker exec -i -e PGPASSWORD=root docker_postgres_1 psql -U postgres -lqt | cut -d \| -f 1 | grep -w chirpstack)

if [ ${DB_Chirpstack} = "chirpstack" ] 
then

	echo "\tBackuping Chirpstack" >> ${backup_log_file}
	docker exec -i -e PGPASSWORD=root docker_postgres_1 pg_dump -U postgres chirpstack >> ${backup_temp_file}/chirpstack.sql
else
	echo "\tChirpstack DB does not exist" >> ${backup_log_file}
fi

echo "Check if co2dev DB exist" >> ${backup_log_file}
DB_Chirpstack=$(docker exec -i -e PGPASSWORD=root docker_postgres_1 psql -U postgres -lqt | cut -d \| -f 1 | grep -w co2dev)

if [ ${DB_Chirpstack} = "co2dev" ]
then

        echo "\tBackuping co2dev" >> ${backup_log_file}
        docker exec -i -e PGPASSWORD=root docker_postgres_1 pg_dump -U postgres co2dev >> ${backup_temp_file}/co2dev.sql
else
        echo "\tco2dev does not exist" >> ${backup_log_file}
fi


echo "Check if co2prod DB exist" >> ${backup_log_file}
DB_Chirpstack=$(docker exec -i -e PGPASSWORD=root docker_postgres_1 psql -U postgres -lqt | cut -d \| -f 1 | grep -w co2prod)

if [ ${DB_Chirpstack} = "co2prod" ]
then

        echo "\tBackuping co2prod" >> ${backup_log_file}
        docker exec -i -e PGPASSWORD=root docker_postgres_1 pg_dump -U postgres co2prod >> ${backup_temp_file}/co2prod.sql
else
        echo "\tco2prod does not exist" >> ${backup_log_file}
fi

backup_file_name=$(date +'%F-%H')
echo "\n Compressing files" >> ${backup_log_file}

tar czf /home/projetco2-2024/co2/docker/volumes/postgre_bkp/${backup_file_name}.tar.gz ./


echo "\n Deleting temp files" >> ${backup_log_file}
rm *.sql

echo "Ending backup at ${backup_log_file_date}" >> ${backup_log_file}

