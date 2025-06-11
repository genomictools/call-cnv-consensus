process PFB {
    tag "${dbsnp}"

    label 'simple'
    label 'bcftools'
    
    publishDir("${params.output_dir}/ref", mode: 'copy')

    input:
    tuple val(dbsnp), path(dbsnp_file), path(dbsnp_index),
          path(snplist)

    output:
    tuple val(dbsnp), path("${dbsnp}.txt"), path("${dbsnp}.pfb")

    script:
    """
    #!/bin/bash
    # Extract the snps from the dbsnp file
    bcftools view -i ID==@${snplist} ${dbsnp_file} | \
    bcftools query -f '%ID\t%CHROM\t%POS\t%REF\t%ALT\t%CAF\n' > ${dbsnp}.txt

    # Convert to pfb
    dbsnp.awk ${dbsnp}.txt > ${dbsnp}.pfb
    """
}
