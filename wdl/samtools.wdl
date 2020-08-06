version 1.0
# SAMtools

task indexstats {
    input {
        File bamfile
        String outputfile = basename(bamfile) + ".bai"
        String flagstat = sub(basename(bamfile),"\.bam$", "-flagstat.txt")

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command {
        ln -s ~{bamfile} ~{basename(bamfile)}

        samtools flagstat ~{bamfile} > ~{flagstat}

        samtools index ~{basename(bamfile)}
    }
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        docker: 'madetunj/samtools:v1.9'
        cpu: ncpu
    }
    output {
        File indexbam = "~{outputfile}"
        File flagstats = "~{flagstat}"
    }
}

task markdup {
    input {
        File bamfile
        String outputfile = sub(basename(bamfile),"\.bam$", ".rmdup.bam")

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command {
        samtools markdup \
            -r -s \
            ~{bamfile} \
            ~{outputfile}
    }
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        docker: 'madetunj/samtools:v1.9'
        cpu: ncpu
    }
    output {
        File mkdupbam = "~{outputfile}"
    }
}

task viewsort {
    input {
        File samfile
        String outputfile = basename(sub(samfile,'\.sam$','\.sorted.bam'))

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command {
        samtools view -b \
            ~{samfile} \
            > ~{sub(samfile,'\.sam$','\.bam')}

        samtools sort \
           ~{sub(samfile,'\.sam$','\.bam')} \
           -o ~{outputfile}
    }
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        docker: 'madetunj/samtools:v1.9'
        cpu: ncpu
    }
    output {
        File sortedbam = "~{outputfile}"
    }
}
