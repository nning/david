#!/bin/bash
# (60+(28*3*(30+15)))/60=64

uri="coap://[::1]:5683/hello"

./coapbench.sh -c 1000 -t 60 $uri > /dev/null 2>&1

seq="$(seq 10 10 90) $(seq 100 100 900) $(seq 1000 1000 10000)"

for c in $seq; do
	for i in $(seq 1 3); do
		./coapbench.sh -c $c -t 30 $uri 2>&1 | grep throughput
		sleep 15
	done
done

rm -f coapbench\(*
