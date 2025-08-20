#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { prepare_references }  from './subworkflows/prepare_references.nf'
include { call_alternates }     from './subworkflows/call_alternates.nf'
include { clean_calls }         from './subworkflows/clean_calls.nf'
include { visualize_cnv }       from './subworkflows/visualize_cnv.nf'

gtc_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, row.key, file(row.file) ] }

dbsnp   = Channel.fromFilePairs(params.dbsnp, flat: true)
snplist = Channel.fromPath(params.snplist)
gc      = Channel.fromPath(params.gc)
genes   = Channel.fromPath(params.refgene)
links   = Channel.fromPath(params.reflink)
exclude = Channel.fromPath(params.exclude_regions)

type_ch = Channel.of(params.type.split(','))
hmm     = Channel.empty()
    | ( params.hmm  != null ? concat(Channel.of(['cnv', file(params.hmm)]))  : Channel.empty() )
    | ( params.hmm0 != null ? concat(Channel.of(['loh', file(params.hmm0)])) : Channel.empty() )
    | combine(type_ch, by: 0)


format_ch   = Channel.of(params.format.split(','))
features_ch = Channel.of(params.features.split(','))

workflow {
    ref = prepare_references(dbsnp, snplist, gc)
    alt = call_alternates(gtc_ch, ref.pfb, ref.gcm, hmm)
    cleaned = clean_calls(alt.calls, ref.pfb, exclude)
    visualize_cnv(cleaned.calls, ref.pfb, alt.signal, genes, links)
}