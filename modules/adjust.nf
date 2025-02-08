process ADJUST {
    tag "${key}"

    label 'simple'

    container = params.penncnv

    publishDir("${params.output_dir}/adjusted", mode: 'copy')

    input:
    tuple val(key), path(file), file(gcm)

    output:
    tuple val(key), path("${key}.adjusted.txt")
    
    script:
    """
    #!/bin/bash
    genomic_wave.pl \
        -adjust \
        -gcmodel ${gcm} \
        ${file}
    
    cp ${key}.adjusted ${key}.adjusted.txt
    """
}