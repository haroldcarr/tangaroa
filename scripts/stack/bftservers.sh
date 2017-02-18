#!/bin/bash

stack exec bftserver -- -d -p keys/public_keys.txt -c keys/client_public_keys.txt -k keys/private_keys/10000.txt -s 10000 10001 10002 10003 &
stack exec bftserver -- -d -p keys/public_keys.txt -c keys/client_public_keys.txt -k keys/private_keys/10001.txt -s 10001 10000 10002 10003 &
stack exec bftserver -- -d -p keys/public_keys.txt -c keys/client_public_keys.txt -k keys/private_keys/10002.txt -s 10002 10001 10000 10003 &
stack exec bftserver -- -d -p keys/public_keys.txt -c keys/client_public_keys.txt -k keys/private_keys/10003.txt -s 10003 10001 10002 10000
