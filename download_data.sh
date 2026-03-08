#!/bin/bash
# Download script for SRA sequencing data via NCBI/ENA
# Uses wget to download FASTQ files from ENA FTP
# Each SRR accession includes paired-end reads (_1 and _2)
# If a sample is single-end, only the _1 file will exist

set -e

SRR_IDS=(
    SRR37244854
    SRR37244852
    SRR37244853
    SRR37244849
    SRR37244541
    SRR35789858
    SRR35789755
    SRR37244543
    SRR37244542
    SRR35613409
    SRR35613410
    SRR35760468
    SRR35760470
    SRR35760472
    SRR35760475
    SRR37421678
    SRR37421679
    SRR37421680
    SRR37421684
    SRR37421727
    SRR37353380
    SRR37353400
    SRR37353401
    SRR37207862
    SRR37207863
    SRR37298483
    SRR37298484
    SRR37298485
    SRR37298486
    SRR37298487
)

mkdir -p data

for SRR in "${SRR_IDS[@]}"; do
    PREFIX="${SRR:0:6}"
    SUBDIR="0${SRR: -2}"
    BASE="https://ftp.sra.ebi.ac.uk/vol1/fastq/${PREFIX}/${SUBDIR}/${SRR}"
    wget -c -P data "${BASE}/${SRR}_1.fastq.gz"
    wget -c -P data "${BASE}/${SRR}_2.fastq.gz" || true
done

