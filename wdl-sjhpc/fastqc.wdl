version 1.0

task fastqc {
    input {
        File inputfile
        String suffix = ".fastq.gz"
        String prefix = basename(inputfile, suffix)

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command {
        ln -s ~{inputfile} ~{sub(basename(inputfile),'\.bam$','.bam.bam')}
        fastqc \
            -o ./ \
            ~{sub(basename(inputfile),'\.bam$','.bam.bam')}
    }
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        cpu: ncpu
    }
    output {
        File htmlfile = "~{prefix}_fastqc.html"
        File zipfile = "~{prefix}_fastqc.zip"
    }
}
