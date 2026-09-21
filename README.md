### Introduction

This workflow performs consensus CNV (copy number variation) calling from genotyping array signal intensity data. It uses multiple CNV calling algorithms to identify CNVs and produces a consensus call set. The output includes quality-controlled CNV calls, genotypes, and visualizations.

The workflow is designed to:
- Support multiple CNV calling tools (PennCNV, QuantiSNP, RGADA)
- Generate consensus calls from multiple tools
- Apply quality filtering and cleaning of CNV calls
- Perform statistical testing of CNV associations
- Generate visualizations of CNV regions
- Handle family and cohort relationships

### Usage

`--cohorts` is a required input CSV file with columns: `cohort,key,level,file,pedigree`

The typical command looks like the following:

```bash
nextflow run call-cnv-consensus/main.nf \
    --cohorts cohorts_input.csv \
    --output_dir results/ \
    --tools penncnv,quantisnp,rgada
```

### Inputs & Parameters

#### Input Files
- `cohorts`: CSV file with columns: cohort, key, level, file (signal data), pedigree
- `snplist`: SNP list file for PennCNV (required)
- `known_sites`: Known CNV sites/common regions
- `manifest`: Array manifest file
- `clusters`: Sample clustering information
- `probes`: Probe sequence information
- `refgene`: RefGene annotation file
- `refexon`: RefGene exon annotation file
- `anno`: General annotation file
- `intervals`: Genomic intervals
- `fasta`: Reference FASTA file
- `genelist`: List of genes for analysis
- `bandlist`: Cytogenetic band information
- `exclude_regions`: Regions to exclude from analysis
- `gc`: GC content file (optional)
- `dbsnp`: dbSNP database file (optional)

#### Signal Data Extraction
- `name_col`: Default "SNP Name" - Column name for SNP identifiers
- `baf_col`: Default "bAllele Freq" - Column name for B allele frequency
- `lrr_col`: Default "Log R Ratio Illumina" - Column name for Log R Ratio
- `a1_col`: Default "Allele1 - Top" - Column name for allele 1
- `a2_col`: Default "Allele2 - Top" - Column name for allele 2

#### CNV Calling Tools
- `tools`: Default "penncnv,quantisnp,rgada" - Comma-separated list of tools to use
  - `penncnv`: PennCNV algorithm
  - `quantisnp`: QuantiSNP algorithm
  - `rgada`: RGADA (Robust Gaussian Adriatic Absorption) algorithm

#### Tool-Specific Parameters

**PennCNV**
- `backgroundgc`: Default 0.42 - Background GC content for normalization

**QuantiSNP**
- `quant_ratios`: QuantiSNP transitions file
- `quant_params`: QuantiSNP parameter file
- `lsetting`: Default 2000000 - QuantiSNP l-setting parameter
- `emiters`: Default 10 - Number of EM iterations

**RGADA**
- `t_statistic`: Default 5 - T-statistic threshold
- `a_alpha`: Default 0.8 - Alpha parameter for RGADA

#### Filtering & Quality Control Parameters
- `numsnp`: Default 50 - Minimum number of SNPs in a CNV call
- `maxnumsnp`: Default 1000000 - Maximum number of SNPs in a CNV call
- `length`: Default 25000 - Minimum CNV length (bp)
- `maxlength`: Default 50000000 - Maximum CNV length (bp)
- `confidence`: Minimum confidence scores per tool:
  - `penncnv`: Default 50
  - `quantisnp`: Default 250
  - `rgada`: Default 0.25
- `maxconfidence`: Maximum confidence scores per tool:
  - `penncnv`: Default 10000
  - `quantisnp`: Default 10000
  - `rgada`: Default 1
- `fraction`: Default 0.5 - Fraction threshold for cleaning overlapping calls
- `distance`: Default 1000000 - Distance for genomic wave adjustment

#### Processing Steps (Boolean Flags)
- `adjust`: Default true - Perform genomic wave adjustment
- `filter`: Default true - Apply CNV filtering
- `clean`: Default true - Clean overlapping/redundant calls
- `report`: Default true - Generate report
- `consensus`: Default true - Generate consensus calls
- `test`: Default true - Perform statistical testing
- `roh`: Default true - Detect runs of homozygosity
- `relations`: Default true - Apply family relationship constraints
- `export`: Default true - Export results
- `heatmap`: Default true - Generate heatmap visualizations
- `scatter`: Default true - Generate scatter plot visualizations

#### General Parameters
- `chunk`: Default 10000 - SNP list chunk size for parallel processing
- `window`: Default 50 - Window size for Plink analysis (SNPs)
- `format`: Default 'bed,tab' - Output format(s)
- `n_samples`: Default 10 - Number of samples to visualize
- `n_genes`: Default 10 - Number of genes per visualization
- `onesided`: Default false - Use one-sided statistical tests

### Output

The pipeline consists of multiple subworkflows executed in order:

1. `prepare_references`: Prepares reference files and generates PFB (population frequency) and GC content files
2. `prepare_signal`: Extracts signal data from microarray files and normalizes
3. `call_alternates`: Runs CNV calling tools (PennCNV, QuantiSNP, RGADA)
4. `clean_calls`: Filters, cleans, and generates consensus CNV calls
5. `test_calls`: Performs statistical testing of CNV associations
6. `visualize_cnv`: Generates heatmaps and scatter plots of CNVs

Output files are organized by subworkflow and include:
- CNV call files (bed, vcf format)
- Genotype files
- Consensus calls
- Test statistics
- Visualization plots
