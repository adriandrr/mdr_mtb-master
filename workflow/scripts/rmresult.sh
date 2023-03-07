#! /bin/bash

# the script is meant to remove everything produced by the snakemake workflow
# it comes in handy when you need to re-create several times

echo "removing results and logs"
rm -r /homes/adrian/mdr_mtb-master/results/*
rm -r /homes/adrian/mdr_mtb-master/logs/*
echo "results and logs removed"