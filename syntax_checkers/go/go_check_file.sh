#!/bin/sh
# This is necessary
cd "`dirname $1`"
go build -o /dev/null ./ 2>&1 | fgrep "`basename $1`:"
