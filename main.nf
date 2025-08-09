#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { prepare_references }  from './subworkflows/prepare_references.nf'
include { call_alternates }     from './subworkflows/call_alternates.nf'
include { clean_cnv }           from './subworkflows/clean_cnv.nf'
include { assess_quality }      from './subworkflows/assess_quality.nf'

dbsnp   = Channel.fromFilePairs(params.dbsnp, flat: true)
snplist = Channel.fromPath(params.snplist)
gc      = Channel.fromPath(params.gc)
gtc     = Channel.fromPath(params.gtc) | map { [ it.simpleName, it ] }
hmm     = Channel.fromPath(params.hmm)
hmm0    = Channel.fromPath(params.hmm0)
genes   = Channel.fromPath(params.refgene)
links   = Channel.fromPath(params.reflink)

type_ch   = Channel.of(params.type.split(','))
format_ch = Channel.of( 'bed', 'tab' )

workflow {
    ref = prepare_references(dbsnp, snplist, gc)
    alt = call_alternates(gtc, ref.pfb, ref.gcm, hmm, hmm0, genes, links)
    clean_cnv(alt.cnv, ref.pfb, genes, links)
    assess_quality(alt.cnv, alt.signal)
}