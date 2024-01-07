#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: ./start.sh <ntdsfile> <days to run bruteforce>
    exit 1
fi
sudo time --format="Elapsed time: \t%E" /home/steve/crackjob/crack-lm-ntlm.sh $1 $2
