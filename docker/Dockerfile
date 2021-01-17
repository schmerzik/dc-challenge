FROM debian:stable

WORKDIR /usr/src

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
COPY ./requirements.txt ./requirements.txt
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# copy credentials & certificates
COPY ["uncommitted/cred/client-cert.pem","uncommitted/cred/client-key.pem","uncommitted/cred/server-ca.pem","/etc/ssl/certs/"]
COPY uncommitted/cred/dc-challenge-key.json /usr/src/

CMD ["/bin/bash"]
