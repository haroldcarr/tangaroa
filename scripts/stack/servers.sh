#!/bin/bash

stack exec simpleserver -- -d -s 10000 10001 10002 10003 10004 &
stack exec simpleserver -- -d -s 10001 10000 10002 10003 10004 &
stack exec simpleserver -- -d -s 10002 10001 10000 10003 10004 &
stack exec simpleserver -- -d -s 10003 10001 10002 10000 10004 &
stack exec simpleserver -- -d -s 10004 10001 10002 10003 10000
