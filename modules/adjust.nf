process ADJUST {
    tag "${key}"

    label 'simple'
    label 'penncnv'

    publishDir("${params.output_dir}/adjusted", mode: 'copy')

    input:
    tuple val(key), path(file),
          val(dbsnp), file(gcm)

    output:
    tuple val(key), path("${key}.signal.txt.adjusted")
    
    script:
    """
    #!/bin/bash
    genomic_wave.pl \
        -adjust \
        -gcmodel ${gcm} \
        ${file}
    """
}