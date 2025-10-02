#!/bin/bash
set -ueo pipefail

for i in {Rosie,Haley,Sarah}
do 
	./greet.sh ${i}
done
