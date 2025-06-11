// Quality control of CNV calls
process ASSESS {
    tag "${key}"

    label 'simple'
    label 'penncnv'

    publishDir("${params.output_dir}/qc", mode: 'copy')

    input:
    tuple val(key), path(signal), val(type), path(cnv), path(cnv_log)

    output:
    tuple val(key),
          path("${key}.qcpass"),
          path("${key}.qcsum"),
          path("${key}.goodcnv")

    script:
    """
    #!/bin/bash
    awk '(NR == 1) || (FNR > 1)' ${signal} > ${key}.signal.txt
    cat ${cnv} > ${key}.raw.cnv
    cat ${cnv_log} > ${key}.log.txt

    filter_cnv.pl \
        ${key}.raw.cnv \
        -qclogfile ${key}.log.txt \
        -qclrrsd 0.35 \
        -qcnumcnv 500 \
        -qcpassout ${key}.qcpass \
        -qcsumout ${key}.qcsum \
        -out ${key}.goodcnv
    """
}