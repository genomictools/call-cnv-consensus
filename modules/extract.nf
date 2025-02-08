process EXTRACT {
    tag "${key}"

    label 'simple'

    container = params.penncnv

    publishDir("${params.output_dir}/signal", mode: 'copy')

    input:
    tuple val(key), path(file)

    output:
    tuple val(key), path("${key}.signal.txt")
    
    script:
    """
    #!/bin/bash
    echo -e "Name\tB Allele Freq\tLog R Ratio" > ${key}.signal.txt
    cat ${file} | tail -n +13 | cut -f 1,15,16 >> ${key}.signal.txt
    """
}