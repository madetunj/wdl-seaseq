version 1.0

task bamtogff {

    input {
        File bamfile
        File bamindex

        File gtffile
        File chromsizes
        String feature = "gene"

        String samplename = basename(bamfile,'.bam')

        Int memory_gb = 5
        Int max_retries = 1
        Int ncpu = 1
    }
    command <<<
        mkdir bamdensity_out

        ln -s ~{bamfile} ~{basename(bamfile)}
        ln -s ~{bamindex} ~{basename(bamindex)}

        GTFFILE=~{gtffile}
        FEATURE=~{feature}
        BAMFILE=~{basename(bamfile)}
        CHROMSIZES=~{chromsizes}
        SAMPLENAME=~{samplename}

        echo "#############################################"
        echo "######            BAM2GFF v1           ######"
        echo "#############################################"

        echo "BAM file: $BAMFILE"
        echo "FEATURE type: $FEATURE"
        echo "Sample Name: $SAMPLENAME"

        mkdir -p annotation
        echo "Extracting GENE regions"
        BAM2GFF_gtftogenes.py -g $GTFFILE -f $FEATURE -c $CHROMSIZES

        mkdir -p matrix
        echo "Working on Promoter Region"
        BAM2GFF_main.py -b $BAMFILE -i annotation/promoters.gff -m 100 -o matrix/promoters.txt

        echo "Working on GeneBody Region"
        BAM2GFF_main.py -b $BAMFILE -i annotation/genes.gff -m 100 -o matrix/genebody.txt

        echo "Working on Upstream Region"
        BAM2GFF_main.py -b $BAMFILE -i annotation/upstream.gff -m 50 -o matrix/upstream.txt

        echo "Working on Downstream Region"
        BAM2GFF_main.py -b $BAMFILE -i annotation/downstream.gff -m 50 -o matrix/downstream.txt

        echo "BAM2GFF_plots.R $SAMPLENAME"
        BAM2GFF_plots.R $SAMPLENAME

        echo "Done!"

        mv matrix *png *pdf bamdensity_out/
    >>>
    runtime {
        memory: ceil(memory_gb * ncpu) + " GB"
        maxRetries: max_retries
        docker: 'madetunj/bam2gff:v1.1.0'
        cpu: ncpu
    }
    output {
        File m_downstream = "bamdensity_out/matrix/downstream.txt"
	File m_upstream = "bamdensity_out/matrix/upstream.txt"
	File m_genebody = "bamdensity_out/matrix/genebody.txt"
	File m_promoters = "bamdensity_out/matrix/promoters.txt"
        File? pdf_gene = "bamdensity_out/~{samplename}-entiregene.pdf"
        File? pdf_h_gene = "bamdensity_out/~{samplename}-heatmap.entiregene.pdf"
        File? png_h_gene = "bamdensity_out/~{samplename}-heatmap.entiregene.png"
        File? pdf_h_gene = "bamdensity_out/~{samplename}-heatmap.entiregene.pdf"
        File? pdf_promoters = "bamdensity_out/~{samplename}-promoters.pdf"
        File? pdf_h_promoters = "bamdensity_out/~{samplename}-heatmap.promoters.pdf"
        File? png_h_promoters = "bamdensity_out/~{samplename}-heatmap.promoters.png"
    }
}
