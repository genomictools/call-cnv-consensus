process FILTER {
    tag "${key}"

    label 'simple'

    container = params.penncnv

    publishDir("${params.output_dir}/filtered", mode: 'copy')

    input:
    tuple val(key), path(cnv), path(cnv_log)

    output:
    tuple val(key), path("${key}.filtered.cnv")
          
    script:
    """
    #!/bin/bash
    filter_cnv.pl \
        -numsnp 10 \
        -length 50k \
        ${cnv} \
        --output ${key}.filtered.cnv
    """
}
