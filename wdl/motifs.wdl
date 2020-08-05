version 1.0

import "https://raw.githubusercontent.com/madetunj/wdl-seaseq/master/wdl/bedtools.wdl"

workflow motifs {
    input {
        File bedfile
        File reference 
        File reference_index
        Array[File]+ motif_databases
    }

    call bedtools.bedfasta {
        input :
            reference=reference,
            reference_index=reference_index,
            bedfile=bedfile
    }

    call ame {
        input :
            motif_databases=motif_databases,
            fastafile=bedfasta.fastafile
    }

    call meme {
        input :
            fastafile=bedfasta.fastafile
    }

    output {
	File ame_out = ame.outputdir
        File meme_out = meme.outputdir 
    }
}

task meme {

    input {
        File fastafile
        Boolean spamo_skip = false
        Boolean fimo_skip = false

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1

        String outputfolder = "bklist" + sub(basename(fastafile,'.fa'),'^.*bklist','') + '-meme_out'
    }
    command <<<
        meme-chip \
            ~{true="-spamo-skip" false="" spamo_skip} \
            ~{true="-fimo-skip" false="" fimo_skip} \
            -oc ~{outputfolder} \
            ~{fastafile}

       tar -czvf ~{outputfolder}.tgz ~{outputfolder}
    >>>
    runtime {
        memory: memory_gb + " GB"
        maxRetries: max_retries
        docker: 'madetunj/memesuite:v5.1.1'
        cpu: ncpu
    }
    output {
        File outputdir = "~{outputfolder}.tgz"
    }
}

task ame {

    input {
        File fastafile
        Array[File]+ motif_databases

        Int memory_gb = 10
        Int max_retries = 1
        Int ncpu = 1

        String outputfolder = "bklist" + sub(basename(fastafile,'.fa'),'^.*bklist','') + '-ame_out'
    }
    command <<<
        ame \
            -oc ~{outputfolder} \
            ~{fastafile} \
            ~{sep=' ' motif_databases}

       tar -czvf ~{outputfolder}.tgz ~{outputfolder}
    >>>
    runtime {
        memory: memory_gb + " GB"
        maxRetries: max_retries
        docker: 'madetunj/memesuite:v5.1.1'
        cpu: ncpu
    }
    output {
        File outputdir = "~{outputfolder}.tgz"
    }
}
