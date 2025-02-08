process DETECT {
    tag "${key}"

    label 'simple'

    container = params.penncnv

    publishDir("${params.output_dir}/${type}", mode: 'copy')

    input:
    tuple val(key), path(file), file(pfb), file(hmm), val(type)

    output:
    tuple val(key), 
          path("${key}.${type}"),
          path("${key}.log")
    
    script:
    if (type == 'cnv') {
        """
        #!/bin/bash
        detect_cnv.pl \
            -test \
            -hmm ${hmm} \
            -pfb ${pfb} \
            ${file} \
            -log ${key}.log \
            -out ${key}.${type}
        """
    } else if (type == 'loh') {
        """
        #!/bin/bash
        detect_cnv.pl \
            -test \
            -loh \
            -tabout \
            -hmm hhall_0.hmm \
            -pfb common_all.pfb \
            ${file} \
            -log ${key}.log \
            -out ${key}.${type}
        """
    } else {
        error "Unknown type: ${type}"
    }
}
