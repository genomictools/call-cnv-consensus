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

// snplist = Channel.fromPath(params.snplist)
// dbsnp   = Channel.fromFilePairs(params.dbsnp, flat: true)
// gc      = Channel.fromPath(params.gc)
exclude = Channel.fromPath(params.exclude_regions)

hmm     = Channel.empty()
    | ( params.hmm  != null ? concat(Channel.of([file(params.hmm), 'cnv']))  : Channel.empty() )
    | ( params.hmm0 != null ? concat(Channel.of([file(params.hmm0), 'loh'])) : Channel.empty() )
    // | combine(type_ch, by: 0)

genelist_ch = Channel.empty()
    | ( params.genelist != null ? concat(Channel.of(file(params.genelist))) : Channel.empty() )
    | splitCsv(header: true)
    | map { row -> [ row.cohort, row.gene ] }

format_ch   = Channel.of(params.format.split(','))
features_ch = Channel.from([
        ['refgene', params.refgene],
        ['refexon', params.refexon],
        ['anno', params.anno]
    ])
    | filter { it[1] != null }
    | map { [it[0], file(it[1])] }

type_ch = Channel.of(params.type.split(','))
// tools_ch = Channel.of(params.tools.split(','))

workflow {
    if ( params.tools.contains('penncnv') ) {
        ref = prepare_references(params.snplist, params.dbsnp, params.gc)
    }
    input = prepare_signal(signal_ch, ref.pfb, ref.gcm)
    // alt = call_alternates(input.signal, input.genotypes, ref.pfb, hmm, ref.levels, type_ch, tools_ch)
    // cleaned = clean_calls(alt, ref.pfb, exclude, cohort_size)
    // tested = test_calls(input.signal, alt, cleaned.consensus, pedigree_ch, ref.pfb, hmm)
    // visualize_cnv(cleaned.calls, ref.pfb, input.signal, features_ch, genelist_ch)
}
