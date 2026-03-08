# Capstone

## Data Download

The `download_data.sh` script downloads FASTQ files for all 30 SRA accessions via **ENA FTP** (`https://ftp.sra.ebi.ac.uk`).

### Usage

```bash
bash download_data.sh
```

Files are saved to a `data/` directory. Each accession downloads paired-end reads (`_1.fastq.gz` and `_2.fastq.gz`). For single-end samples, only the `_1` file will exist.

---

## SRR Accessions and wget Links

| SRR Accession | Read 1 | Read 2 |
|---------------|--------|--------|
| SRR37244854 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/054/SRR37244854/SRR37244854_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/054/SRR37244854/SRR37244854_2.fastq.gz) |
| SRR37244852 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/052/SRR37244852/SRR37244852_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/052/SRR37244852/SRR37244852_2.fastq.gz) |
| SRR37244853 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/053/SRR37244853/SRR37244853_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/053/SRR37244853/SRR37244853_2.fastq.gz) |
| SRR37244849 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/049/SRR37244849/SRR37244849_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/049/SRR37244849/SRR37244849_2.fastq.gz) |
| SRR37244541 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/041/SRR37244541/SRR37244541_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/041/SRR37244541/SRR37244541_2.fastq.gz) |
| SRR35789858 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/058/SRR35789858/SRR35789858_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/058/SRR35789858/SRR35789858_2.fastq.gz) |
| SRR35789755 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/055/SRR35789755/SRR35789755_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/055/SRR35789755/SRR35789755_2.fastq.gz) |
| SRR37244543 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/043/SRR37244543/SRR37244543_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/043/SRR37244543/SRR37244543_2.fastq.gz) |
| SRR37244542 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/042/SRR37244542/SRR37244542_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/042/SRR37244542/SRR37244542_2.fastq.gz) |
| SRR35613409 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR356/009/SRR35613409/SRR35613409_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR356/009/SRR35613409/SRR35613409_2.fastq.gz) |
| SRR35613410 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR356/010/SRR35613410/SRR35613410_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR356/010/SRR35613410/SRR35613410_2.fastq.gz) |
| SRR35760468 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/068/SRR35760468/SRR35760468_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/068/SRR35760468/SRR35760468_2.fastq.gz) |
| SRR35760470 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/070/SRR35760470/SRR35760470_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/070/SRR35760470/SRR35760470_2.fastq.gz) |
| SRR35760472 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/072/SRR35760472/SRR35760472_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/072/SRR35760472/SRR35760472_2.fastq.gz) |
| SRR35760475 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/075/SRR35760475/SRR35760475_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/075/SRR35760475/SRR35760475_2.fastq.gz) |
| SRR37421678 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/078/SRR37421678/SRR37421678_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/078/SRR37421678/SRR37421678_2.fastq.gz) |
| SRR37421679 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/079/SRR37421679/SRR37421679_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/079/SRR37421679/SRR37421679_2.fastq.gz) |
| SRR37421680 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/080/SRR37421680/SRR37421680_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/080/SRR37421680/SRR37421680_2.fastq.gz) |
| SRR37421684 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/084/SRR37421684/SRR37421684_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/084/SRR37421684/SRR37421684_2.fastq.gz) |
| SRR37421727 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/027/SRR37421727/SRR37421727_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/027/SRR37421727/SRR37421727_2.fastq.gz) |
| SRR37353380 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR373/080/SRR37353380/SRR37353380_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR373/080/SRR37353380/SRR37353380_2.fastq.gz) |
| SRR37353400 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR373/000/SRR37353400/SRR37353400_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR373/000/SRR37353400/SRR37353400_2.fastq.gz) |
| SRR37353401 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR373/001/SRR37353401/SRR37353401_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR373/001/SRR37353401/SRR37353401_2.fastq.gz) |
| SRR37207862 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/062/SRR37207862/SRR37207862_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/062/SRR37207862/SRR37207862_2.fastq.gz) |
| SRR37207863 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/063/SRR37207863/SRR37207863_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/063/SRR37207863/SRR37207863_2.fastq.gz) |
| SRR37298483 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/083/SRR37298483/SRR37298483_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/083/SRR37298483/SRR37298483_2.fastq.gz) |
| SRR37298484 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/084/SRR37298484/SRR37298484_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/084/SRR37298484/SRR37298484_2.fastq.gz) |
| SRR37298485 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/085/SRR37298485/SRR37298485_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/085/SRR37298485/SRR37298485_2.fastq.gz) |
| SRR37298486 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/086/SRR37298486/SRR37298486_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/086/SRR37298486/SRR37298486_2.fastq.gz) |
| SRR37298487 | [_1](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/087/SRR37298487/SRR37298487_1.fastq.gz) | [_2](https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/087/SRR37298487/SRR37298487_2.fastq.gz) |