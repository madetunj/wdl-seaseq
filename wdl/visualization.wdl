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
        memory: memory_gb + " GB"
        maxRetries: max_retries
        docker: 'madetunj/wigtobigwig:v4'
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
        memory: memory_gb + " GB"
        maxRetries: max_retries
        docker: 'madetunj/igvtools:v2.8.2'
        cpu: ncpu
    }
    output {
        File tdffile = "~{outputfile}"
    }
}

task normalize {
    input {
        File wigfile
        File xlsfile

        String outputfile = sub(basename(wigfile),'\.wig\.gz', '.RPM.wig')

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command <<<

        gunzip -c ~{wigfile} > ~{basename(wigfile,'.gz')}
        ln -s ~{basename(wigfile,'.gz')} thewig.wig
        ln -s ~{xlsfile} xlsfile.xls
        
        python <<CODE
        import subprocess
        
        command = "grep 'tags after filtering in treatment' xlsfile.xls"
        try:
            mappedreads = int(str(subprocess.check_output(command,shell=True).strip()).split(': ')[1].split("'")[0].strip())
        except:
            mappedreads = 0
        if mappedreads <= 0:
            command = "grep 'total tags in treatment' xlsfile.xls"
            mappedreads = int(str(subprocess.check_output(command,shell=True).strip()).split(': ')[1].split("'")[0].strip())  

        mappedreads = mappedreads/1000000
        
        inputwig = open("thewig.wig", 'r')
        Lines = inputwig.readlines()
        file1 = open("output.out", 'w') 
        
        for line in Lines :
            if line.startswith('track') or line.startswith('variable'):
                file1.write("%s" %(line))
            else:
                lines = line.split("\t")
                height = int(lines[1])/float(mappedreads)
                file1.write("%s\t%s\n" %(lines[0],height))
                
        CODE
        mv output.out ~{outputfile}
        gzip ~{outputfile}

    >>> 
    runtime {
        memory: memory_gb + " GB"
        maxRetries: max_retries
        docker: 'madetunj/seaseq:v0.0.1'
        cpu: ncpu
    }
    output {
        File norm_wig = "~{outputfile}.gz"
    }
}
