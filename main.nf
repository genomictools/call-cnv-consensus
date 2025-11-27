#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { prepare_references }  from './subworkflows/prepare_references.nf'
include { prepare_signal }      from './subworkflows/prepare_signal.nf'
include { call_alternates }     from './subworkflows/call_alternates.nf'
include { clean_calls }         from './subworkflows/clean_calls.nf'
include { test_calls }          from './subworkflows/test_calls.nf'
include { visualize_cnv }       from './subworkflows/visualize_cnv.nf'

signal_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, row.key, row.level, file(row.file) ] }

signal_ch
    | groupTuple(by: 0)
    | map { it -> [ it[0], it[1].size() + 1 ] }
    | set { cohort_size }

pedigree_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, file(row.pedigree) ] }
    | unique

workflow {
    ref   = prepare_references(params.snplist, params.dbsnp, params.gc)
    input = prepare_signal(signal_ch, ref.pfb, ref.gcm, pedigree_ch)
    alt = call_alternates(input.signal, ref.pfb)
    cleaned = clean_calls(alt.calls, ref.pfb, cohort_size)
    tested = test_calls(input.signal, input.genotypes, alt.calls, cleaned.consensus, pedigree_ch, ref.pfb)
    visualize_cnv(cleaned.calls, ref.pfb, input.signal)
}
