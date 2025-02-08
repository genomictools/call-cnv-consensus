process GCM {
    tag "${dbsnp}"

    label 'simple'

    container = params.penncnv

    publishDir("${params.output_dir}/ref", mode: 'copy')

    input:
    tuple val(dbsnp), path(txt), path(pfb),
          path(gc)

    output:
    tuple val(dbsnp), path("${dbsnp}.gcmodel")

    script:
    """
    #!/bin/bash
    # Sort gc content file
	sort -k 2,2 -k 3,3n ${gc} > gc.txt
    
    # Modify pfb inpur
    tail -n +2 ${pfb} | \
        awk -v OFS='\t' 'BEGIN {print "Name", "Chr", "Pos"} {print \$1, \$2, \$3}' \
        > snp.txt
    
    # Generate GC model
    cal_gc_snp.pl \
        gc.txt \
        snp.txt \
        --output ${dbsnp}.gcmodel
    """
}