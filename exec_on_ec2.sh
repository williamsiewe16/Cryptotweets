#!/bin/bash

until [ -f /var/lib/cloud/instances/*/boot-finished ]
do
       sleep 2
done

airflow
sudo pip install -r /app/twitter_scraper/requirements.txt
sudo airflow users create --username airflow --password airflow --firstname airflow --lastname airflow --role Admin --email admin@airflow.com
sudo mv /app/dags/ ~/airflow/
sudo airflow standalone
#sudo airflow db init
#sudo airflow db init
#sudo airflow dags unpause s3_to_redshift
#sudo airflow dags unpause twitter_to_s3
#sudo airflow webserver
#sudo airflow scheduler&