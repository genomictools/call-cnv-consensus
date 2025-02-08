#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { PFB } from './modules/pfb.nf'
include { GCM } from './modules/gcm.nf'

include { EXTRACT } from './modules/extract.nf'
include { ADJUST } from './modules/adjust.nf'
include { DETECT } from './modules/detect.nf'

include { FILTER } from './modules/filter.nf'
include { CLEAN } from './modules/clean.nf'
include { SCAN } from './modules/scan.nf'
include { VISUALIZE } from './modules/visualize.nf'

include { ASSESS } from './modules/assess.nf'

workflow REFERENCES {
    // Compile refernce files
    Channel.fromPath(params.hmm) | set { hmm }
    Channel.fromPath(params.refgene) | set { genes }
    Channel.fromPath(params.reflink) | set { links }

    Channel.fromFilePairs(params.dbsnp, flat: true) | set { dbsnp }
    Channel.fromPath(params.snplist) | set { snplist }
    Channel.fromPath(params.gc) | set { gcm }
    
    dbsnp 
        | combine(snplist) 
        | PFB 
        | combine(gcm) 
        | GCM
        | combine(PFB.out, by: 0)
        | combine(hmm)
        | combine(genes)
        | combine(links)
        | map { [dbsnp: it[0], gcm: it[1], txt: it[2], pfb: it[3], hmm: it[4], genes: it[5], links: it[6]] }
        | set {ref}
    // ref | view
    emit:
    ref
}

Channel.fromPath(params.gtc) 
    | map { [it.simpleName, it] }
    | set { gtc }

workflow CALLING {
    take: 
    gtc
    ref

    main:
    gtc
        | EXTRACT 
        // | combine(ref.map { it.gcm })
        // | ADJUST
        | combine(ref.map { it.pfb })
        | combine(ref.map { it.hmm })
        | combine(Channel.of( 'cnv' ))
        | DETECT
        | FILTER
        | combine(ref.map { it.pfb })
        | CLEAN
        | map { ['scanned', it.last()] }
        | groupTuple(by: 0)
        | combine(ref.map { it.genes })
        | combine(ref.map { it.links })
        | SCAN
        | combine(Channel.of( 'bed', 'tab'))
        | VISUALIZE
    
    EXTRACT.out
        | combine(DETECT.out, by: 0)
        | groupTuple(by: 0)
        | ASSESS

    emit:
    EXTRACT.out
}

workflow LOH {
    take: 
    signal
    ref

    main:
    signal
        | combine(ref.map { it.pfb })
        | combine(ref.map { it.hmm })
        | combine(Channel.of( 'loh' ))
        | DETECT
}

workflow {
    REFERENCES()
    CALLING(gtc, REFERENCES.out)
    LOH(CALLING.out, REFERENCES.out)
}