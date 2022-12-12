import airflow
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import timedelta
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'ubuntu',    
    #'start_date': airflow.utils.dates.days_ago(2),
    # 'end_date': datetime(),
    # 'depends_on_past': False,
    #'email': ['airflow@example.com'],
    #'email_on_failure': False,
    #'email_on_retry': False,
    # If a task fails, retry it once after waiting
    # at least 5 minutes
    #'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag_python = DAG(
	dag_id = "twitter_to_s3",
	default_args=default_args,
	schedule_interval='*/30 * * * *',
	dagrun_timeout=timedelta(minutes=60),
	description='scrap tweets using twitter api an store into S3',
	start_date = airflow.utils.dates.days_ago(1),
    catchup=False
)


scrapping_task = BashOperator(
    task_id="scraping_task",
    bash_command="python /app/twitter_scraper/twitter_scraper.py",
    dag=dag_python
)

scrapping_task

if __name__ == "__main__":
    dag_python.cli()