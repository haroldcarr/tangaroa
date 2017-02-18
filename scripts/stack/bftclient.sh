#!/bin/bash

stack exec bftclient -- -d -p keys/public_keys.txt -k keys/private_keys/10008.txt -s 10008 10000 10001 10002 10003
