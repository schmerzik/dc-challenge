from airflow import DAG

from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow_dbt.operators.dbt_operator import DbtRunOperator
from airflow.utils.dates import days_ago

from great_expectations_provider.operators.great_expectations import GreatExpectationsOperator

from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': days_ago(0),
    'email': ['erik.vanhauwaert@gmail.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'dir': '/usr/src/challenge/dbt_prep',
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2021, 1, 14),
}

dag = DAG('prep-analysis', default_args=default_args, schedule_interval=timedelta(days=1))

templated_command = """
    echo "{{ params.task_name }} : {{ ts }} [initiated at {{ params.start_date }}]"
"""

start_task = BashOperator(
    task_id='start',
    depends_on_past=False,
    bash_command=templated_command,
    params={'task_name': 'Start', 'start_date': default_args['start_date']},
    dag=dag,
)

valid_prod_task = GreatExpectationsOperator(
    task_id='valid_products',
    expectation_suite_name='products',
    data_context_root_dir='/usr/src/challenge/great_expectations',
    batch_kwargs={
        'table': 'products',
        'datasource': 'challenge_src'
    },
    dag=dag
)

valid_cust_task = GreatExpectationsOperator(
    task_id='valid_customers',
    expectation_suite_name='customers',
    data_context_root_dir='/usr/src/challenge/great_expectations',
    batch_kwargs={
        'table': 'test_customers',
        'datasource': 'challenge_src'
    },
    dag=dag
)

valid_ordr_task = GreatExpectationsOperator(
    task_id='valid_orders',
    expectation_suite_name='orders',
    data_context_root_dir='/usr/src/challenge/great_expectations',
    batch_kwargs={
        'table': 'test_orders',
        'datasource': 'challenge_src'
    },
    dag=dag
)

sync_task = BashOperator(
    task_id='sync_validations',
    depends_on_past=False,
    bash_command=templated_command,
    params={'task_name': 'Done with validations', 'start_date': default_args['start_date']},
    dag=dag,
)

dbt_task = DbtRunOperator(task_id='dbt', dag=dag)
# dbt_task = DummyOperator(task_id='dbt', dag=dag)

done_task = BashOperator(
    task_id='done',
    depends_on_past=False,
    bash_command=templated_command,
    params={'task_name': 'All done', 'start_date': default_args['start_date']},
    dag=dag,
)

start_task >> [valid_prod_task,valid_cust_task,valid_ordr_task] >> sync_task >> dbt_task >> done_task
