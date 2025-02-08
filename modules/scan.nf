process SCAN {
    tag "${key}"

    label 'simple'

    container = params.penncnv

    publishDir("${params.output_dir}/scanned", mode: 'copy')

    input:
    tuple val(key), path(cnv), path(ref_gene), path(ref_link)   

    output:
    tuple val(key),
          path("${key}.cnv"),
          path("${key}.gene.cnv")
        
    script:
    """
    #!/bin/bash

    cat ${cnv} > ${key}.cnv

    scan_region.pl \
        ${key}.cnv \
        ${ref_gene} \
        -refgene -reflink ${ref_link} \
        > ${key}.gene.cnv
    """
}