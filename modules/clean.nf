process CLEAN {
    tag "${key}"

    label 'simple'
    label 'penncnv'

    publishDir("${params.output_dir}/clean", mode: 'copy')

    input:
    tuple val(key), path(cnv), 
          val(dbsnp), path(txt), path(pfb)

    output:
    tuple val(key), path("${key}.clean.cnv")

    script:
    """
    #!/bin/bash
    clean_cnv.pl \
        combineseg \
        --fraction 0.2 \
        --signalfile ${pfb} \
        ${cnv} \
        --output ${key}.clean.cnv
    """
}