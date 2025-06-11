process VISUALIZE {
    tag "${key}"

    label 'simple'
    label 'penncnv'

    publishDir("${params.output_dir}/tables", mode: 'copy')

    input:
    tuple val(key), path(cnv), path(annotated), val(format)

    output:
    tuple val(key), path("${key}.${format}")
        
    script:
    """
    #!/bin/bash
    visualize_cnv.pl \
        ${cnv} \
        -format ${format} \
        -track "${key}" \
        > ${key}.${format}
    """
}