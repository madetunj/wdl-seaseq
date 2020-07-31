version 1.0

task macs {

    input {
        File bamfile

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1

        String pvalue = '1e-9'
        String keep_dup = 'auto'
        Int space = 50
        Int shiftsize = 200
        Boolean wiggle = true
        Boolean single_profile = true
        Boolean nomodel = false

        String prefix = basename(bamfile,'\.bam') 
        String name = if (nomodel) then '_nm' else '_p' + sub(pvalue,'^.*-','') + '_kd-' + keep_dup
        String folder = if (nomodel) then '-nm' else '-p' + sub(pvalue,'^.*-','') + '_kd-' + keep_dup
    }
    command <<<
        outputname="~{prefix}~{name}"
        outputfolder="~{prefix}~{folder}"

        mkdir ${outputfolder}

        if [ "~{nomodel}" == 'true' ]; then
            macs14 \
                -t ~{bamfile} \
                --space=~{space} \
                --shiftsize=~{shiftsize} \
                ~{true="-w" false="" wiggle} \
                ~{true="-S" false="" single_profile} \
                ~{true="--nomodel" false="" nomodel} \
                -n ${outputname} \
                && mv \
                ${outputname}* \
                ${outputfolder}
        else
            macs14 \
                -t ~{bamfile} \
                -p ~{pvalue} \
                --keep-dup=~{keep_dup} \
                --space=~{space} \
                ~{true="-w" false="" wiggle} \
                ~{true="-S" false="" single_profile} \
                -n ${outputname} \
                && mv \
                ${outputname}* \
                ${outputfolder}
        fi
    >>>
    runtime {
        memory: memory_gb + " GB"
        maxRetries: max_retries
        docker: 'madetunj/macs:v1.4.2'
        cpu: ncpu
    }
    output {
	File peakbedfile = "~{prefix}~{folder}\/~{prefix}~{name}_peaks.bed"
	File peakxlsfile = "~{prefix}~{folder}\/~{prefix}~{name}_peaks.xls"
	File summitsfile = "~{prefix}~{folder}\/~{prefix}~{name}_summits.bed"
	File wigfile = "~{prefix}~{folder}\/~{prefix}~{name}_MACS_wiggle\/treat\/~{prefix}~{name}_treat_afterfiting_all.wig.gz"
    }
}
