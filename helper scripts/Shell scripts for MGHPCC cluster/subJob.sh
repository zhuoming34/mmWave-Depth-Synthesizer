#!/bin/bash

read -p "Enter job name: " jobName
#read -p "Enter job queue: " jobQueue
read -p "Enter job time in hrs:mins: " jobTime # e.g. 30:00
read -p "Enter memory size in MB: " memSize
echo "Default: long queue will be used."
bsub -q long -W $jobTime -R "rusage[mem=$memSize]" -J $jobName ./matlab_cmd.sh
