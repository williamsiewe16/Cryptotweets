FROM ubuntu

# Install Python and Pip
RUN apt update -y \
&& apt install -y python3-pip \
&& apt install -y python3.10 

# Install Airflow

RUN pip install apache-airflow \
&& airflow db init \
&& airflow users create --username airflow --password airflow --firstname airflow --lastname airflow --role Admin --email admin@airflow.com

COPY data_ingestion.py requirements.txt .env /app/

WORKDIR /app/

RUN pip install -r requirements.txt

COPY dags /root/airflow/dags

CMD airflow standalone