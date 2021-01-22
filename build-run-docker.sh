#/bin/bash

docker build -t challenge .

# map ports [airflow/jupyter]
docker run -it --env-file dc_env --entrypoint /bin/bash -p 8080-8081:8080-8081 challenge:latest
