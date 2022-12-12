import airflow
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python_operator import PythonOperator
from datetime import timedelta
from airflow.utils.dates import days_ago
import boto3

def my_func():
    client = boto3.client('glue')
    # Variables for the job: 
    glueJobName = "s3_to_redshift"
    response = client.start_job_run(JobName = glueJobName)
    print(response)


default_args = {
    'owner': 'ubuntu',    
    #'start_date': airflow.utils.dates.days_ago(2),
    # 'end_date': datetime(),
    # 'depends_on_past': False,
    #'email': ['airflow@example.com'],
    #'email_on_failure': False,
    #'email_on_retry': False,
    # If a task fails, retry it once after waitingac
    # at least 5 minutes
    #'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag_python = DAG(
	dag_id = "s3_to_redshift",
	default_args=default_args,
	schedule_interval='* */12 * * *',
	dagrun_timeout=timedelta(minutes=60),
	description='send data from S3 to redshift after an AWS Glue processing',
	start_date = airflow.utils.dates.days_ago(1),
    catchup=False
)


python_task = PythonOperator(task_id='python_task',python_callable=my_func, dag=dag_python)

python_task

if __name__ == "__main__":
    dag_python.cli()