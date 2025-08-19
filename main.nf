#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { prepare_references }  from './subworkflows/prepare_references.nf'
include { call_alternates }     from './subworkflows/call_alternates.nf'
include { visualize_cnv }       from './subworkflows/visualize_cnv.nf'

gtc_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, row.key, file(row.file) ] }

dbsnp   = Channel.fromFilePairs(params.dbsnp, flat: true)
snplist = Channel.fromPath(params.snplist)
gc      = Channel.fromPath(params.gc)
hmm     = Channel.fromPath(params.hmm)
hmm0    = Channel.fromPath(params.hmm0)
genes   = Channel.fromPath(params.refgene)
links   = Channel.fromPath(params.reflink)
exclude = Channel.fromPath(params.exclude_regions)

type_ch     = Channel.of(params.type.split(','))
format_ch   = Channel.of(params.format.split(','))
features_ch = Channel.of(params.features.split(','))
plot_type_ch= Channel.of(params.plot_type.split(','))

workflow {
    ref = prepare_references(dbsnp, snplist, gc)
    alt = call_alternates(gtc_ch, ref.pfb, ref.gcm, hmm, hmm0, exclude)
    visualize_cnv(alt.cnv, genes, links, alt.signal, ref.pfb)
}