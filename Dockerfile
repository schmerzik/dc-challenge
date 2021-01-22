FROM debian:stable
# ARG ISLOCAL=0

WORKDIR /usr/src

# RUN echo $ISLOCAL
# RUN if [ "${ISLOCAL}" = "1" ]; then echo "Building..."; fi

# RUN if [ "${ISLOCAL}" = "1" ]; \
# 	then echo "Building local"; \
# 	else echo "Building cloud"; \
# 	fi

# copy repo files
COPY ./main/ ./challenge/


# Update packages
RUN apt-get update && apt-get -y upgrade \
	&& apt-get -y --no-install-recommends install \
		# Add tool needed to install extra packages
		apt-utils software-properties-common \
		# other necessities
		curl wget ca-certificates gnupg git \
		# troubleshoot convenience
		nano vim

# python repo
# RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

# python & pip
RUN apt-get update \
	&& apt-get install --no-install-recommends -y -q \
		python3.7 \
		python3-setuptools \
		gcc python3-dev \
		python3-pip \
	# Clean apt cache for smaller docker
	&& apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install python libraries
RUN python3 -m pip install --no-cache-dir -r ./challenge/requirements.txt

# non-sensitive environment variables
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/src/challenge/cred/dc-challenge-key.json
ENV AIRFLOW_HOME=/usr/src/challenge/airflow
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV DBT_PROFILES_DIR=/usr/src/challenge/helper/dbt

EXPOSE 80 8080 8081

ENTRYPOINT ["/bin/bash","./challenge/scripts/init-all.sh"]