version 1.0

import "util.wdl"

workflow visualization {
    input {
        File xlsfile
        File wigfile
        File chromsizes
    }
    
    call util.normalize {
        input:
            wigfile=wigfile,
            xlsfile=xlsfile
    }
    call wigtobigwig {
        input:
            chromsizes=chromsizes,
            wigfile=normalize.norm_wig
    }
    call igvtdf {
        input:
            wigfile=normalize.norm_wig
    }
    
    output {
        File bigwig = wigtobigwig.bigwig
        File norm_wig = normalize.norm_wig
        File tdffile = igvtdf.tdffile
    }
    
}
task wigtobigwig {
    input {
        File wigfile
        File chromsizes
        String outputfile = sub(basename(wigfile),'\.wig\.gz', '.bw')

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command <<<
        wigToBigWig \
            -clip \
            ~{wigfile} \
            ~{chromsizes} \
            ~{outputfile}
    >>> 
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        cpu: ncpu
    }
    output {
        File bigwig = "~{outputfile}"
    }
}

task igvtdf {
    input {
        File wigfile
        String genome = "hg19"

        String outputfile = sub(basename(wigfile),'\.wig\.gz', '.tdf')

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command <<<
        igvtools \
            toTDF \
            ~{wigfile} \
            ~{outputfile} \
            ~{genome}
    >>> 
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        cpu: ncpu
    }
    output {
        File tdffile = "~{outputfile}"
    }
}
