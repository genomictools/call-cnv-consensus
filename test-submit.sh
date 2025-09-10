#!/bin/bash

#SBATCH -o test/test.out
#SBATCH -e test/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p tests/ tests/input

# # Download test data
# URL="https://figshare.com/ndownloader/files"

# wget -c $URL/50690370 -O input/pheno.variants.vcf.gz

cd tests/

# Run nextflow
module load Nextflow

# nextflow run houlstonlab/call-cnv-arrays -r main \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -params-file ../test-params.json \
    -profile cluster,test_family \
    -resume

# usage: nextflow run [ local_dir/main.nf | git_url ]  
# These are the required arguments:
#     -r            {main,dev} to run specific branch
#     -profile      {local,cluster} to run using differens resources
#     -params-file  params.json to pass parameters to the pipeline
#     -resume       To resume the pipeline from the last checkpoint

mv .nextflow.log nextflow.log