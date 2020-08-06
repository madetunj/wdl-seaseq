version 1.0

task bowtie {
    input {
        File fastqfile
        File? metricsfile
        File reference
        String outputfile = sub(basename(fastqfile),'\_.*\_.*\.f.*q\.gz','.sam')
        Int? read_length
        Int limit_alignments = 2
        Int good_alignments = 2
        Boolean best_alignments = true

        Int memory_gb = 10
        Int max_retries = 1
        Int ncpu = 20
    }
    command <<<
        if [ -f "~{metricsfile}" ]; then
            readlength=$(tail -n 1 ~{metricsfile} | awk '{print $4}');
        else
            readlength=~{read_length}
        fi

        bowtie-build ~{reference} ~{basename(reference)}

        bowtie \
            -l $readlength \
            -p ~{ncpu} \
            -k ~{good_alignments} \
            -m ~{limit_alignments} \
            $best \
            -S ~{basename(reference)} \
            ~{fastqfile} \
            > ~{outputfile}
    >>>
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        cpu: ncpu
    }
    output {
        File samfile = "~{outputfile}"
    }
}
