#/bin/bash

# NOTE: this file is used to decrypt the credentials (password should be set in the environment) & then put the files in the right place if necessary

echo "--> Initializing credentials..."

python3 /usr/src/challenge/helper/crypt_files.py --password $CHALLENGE_CRYPT_KEY --file /usr/src/challenge/cred/client-cert.pem --type decrypt
python3 /usr/src/challenge/helper/crypt_files.py --password $CHALLENGE_CRYPT_KEY --file /usr/src/challenge/cred/client-key.pem --type decrypt
python3 /usr/src/challenge/helper/crypt_files.py --password $CHALLENGE_CRYPT_KEY --file /usr/src/challenge/cred/dc-challenge-key.json --type decrypt
python3 /usr/src/challenge/helper/crypt_files.py --password $CHALLENGE_CRYPT_KEY --file /usr/src/challenge/cred/server-ca.pem --type decrypt

mv /usr/src/challenge/cred/*.pem /etc/ssl/certs

echo "--> Initializing credentials - done"