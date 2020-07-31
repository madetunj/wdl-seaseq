version 1.0
import "fastqc.wdl"
import "bedtools.wdl"
import "bowtie.wdl"
import "samtools.wdl"
import "macs.wdl" 
import "bamtogff.wdl"
import "sicer.wdl"
import "motifs.wdl"
import "rose.wdl"
import "util.wdl"
import "visualization.wdl" as viz
import "runspp.wdl"
import "sortbed.wdl"

workflow seaseq_dev_workflow {
    input {
        File fastqfile
        File reference
        File reference_index
        File blacklistfile
        File chromsizes
        File gtffile
        Array[File]+ index_files
        Array[File]+ motif_databases
    }

    call fastqc.fastqc {
        input :
            inputfile=fastqfile
    }
    call util.basicfastqstats as bfs {
        input :
            fastqfile=fastqfile
    }
    call bowtie.bowtie {
        input :
            fastqfile=fastqfile,
            index_files=index_files,
            metricsfile=bfs.metrics_out
    }
    call samtools.viewsort {
        input :
            samfile=bowtie.samfile
    }
    call fastqc.fastqc as bamfqc {
        input :
            inputfile=viewsort.sortedbam
    }
    call samtools.indexstats {
        input :
            bamfile=viewsort.sortedbam
    }
    call bedtools.intersect as blacklist {
        input :
            fileA=viewsort.sortedbam,
            fileB=blacklistfile,
            nooverlap=true
    }
    call samtools.markdup {
        input :
            bamfile=blacklist.intersect_out
    }
    call samtools.indexstats as bklist {
        input :
            bamfile=blacklist.intersect_out
    }
    call samtools.indexstats as mkdup {
        input :
            bamfile=markdup.mkdupbam
    }
    call macs.macs {
        input :
            bamfile=blacklist.intersect_out
    }
    call macs.macs as all {
        input :
            bamfile=blacklist.intersect_out,
            keep_dup="all"
    }
    call macs.macs as nomodel {
        input :
            bamfile=blacklist.intersect_out,
            nomodel=true
    }
    call bamtogff.bamtogff {
        input :
            gtffile=gtffile,
            chromsizes=chromsizes,
            bamfile=markdup.mkdupbam,
            bamindex=mkdup.indexbam
    }
    call bedtools.bamtobed {
        input :
            bamfile=markdup.mkdupbam
    }
    call sicer.sicer {
        input :
            bedfile=bamtobed.bedfile
    }
    call motifs.motifs {
        input:
            reference=reference,
            reference_index=reference_index,
            bedfile=macs.peakbedfile,
            motif_databases=motif_databases
    }

    call util.flankbed {
        input :
            bedfile=macs.summitsfile
    }
    
    call motifs.motifs as flank {
        input:
            reference=reference,
            reference_index=reference_index,
            bedfile=flankbed.flankbedfile,
            motif_databases=motif_databases
    }

    call rose.rose {
        input :
            gtffile=gtffile,
            bamfile=blacklist.intersect_out,
            bamindex=bklist.indexbam,
            bedfile_auto=macs.peakbedfile,
            bedfile_all=all.peakbedfile
    }

    call viz.visualization {
        input:
            wigfile=macs.wigfile,
            chromsizes=chromsizes,
            xlsfile=macs.peakxlsfile
    }
    
    call viz.visualization as vizall {
        input:
            wigfile=all.wigfile,
            chromsizes=chromsizes,
            xlsfile=all.peakxlsfile
    }
    
    call viz.visualization as viznomodel {
        input:
            wigfile=nomodel.wigfile,
            chromsizes=chromsizes,
            xlsfile=nomodel.peakxlsfile
    }

    call bedtools.bamtobed as tobed {
        input :
            bamfile=blacklist.intersect_out
    }
    call runspp.runspp {
        input:
            bamfile=blacklist.intersect_out
    }
    call sortbed.sortbed {
        input:
            bedfile=tobed.bedfile
    }
    call bedtools.intersect {
        input:
            fileA=macs.peakbedfile,
            fileB=sortbed.sortbed_out,
            countoverlap=true,
            sorted=true
    }

    call util.summarystats {
        input:
            bambed=tobed.bedfile,
            sppfile=runspp.spp_out,
            countsfile=intersect.intersect_out,
            peaksxls=macs.peakxlsfile,
            bamflag=indexstats.flagstats,
            rmdupflag=mkdup.flagstats,
            bkflag=bklist.flagstats,
            fastqczip=fastqc.zipfile,
            fastqmetrics=bfs.metrics_out,
            enhancers=rose.enhancers,
            superenhancers=rose.super_enhancers
    }

}
