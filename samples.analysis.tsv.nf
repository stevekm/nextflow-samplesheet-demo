// read samples from analysis samplesheet

Channel.fromPath( file("samples.analysis.tsv") )
        .splitCsv(header: true, sep: '\t')
        .map{row ->
            def sample_ID = row['Sample']
            def reads1 = row['R1'].tokenize( ',' ).collect { file(it) } // comma-sep string into list of files
            def reads2 = row['R2'].tokenize( ',' ).collect { file(it) }
            return [ sample_ID, reads1, reads2 ]
        }
        .tap { samples_R1_R2; samples_R1_R2_2 }
        .map { sample_ID, reads1, reads2 ->
            return [ reads1, reads2 ]
        }
        .flatMap().flatMap()
        .into { samples_fastqs; samples_fastqs2 }


samples_R1_R2.subscribe { println "samples_R1_R2: ${it}" }


process get_samples_files {
    tag { "${sample_ID}" }
    executor "local"
    echo true
    input:
    set val(sample_ID), file(reads1: "*"), file(reads2: "*") from samples_R1_R2_2

    script:
    """
    echo "[get_samples_files] sample_ID: ${sample_ID}, reads1: ${reads1}, reads2: ${reads2}"
    """

}


process get_file {
    tag { "${fastq}" }
    executor "local"
    echo true
    input:
    val(fastq) from samples_fastqs

    script:
    def output_html = "${fastq}".replaceFirst(/.fastq.gz$/, "_fastqc.html")
    def output_zip = "${fastq}".replaceFirst(/.fastq.gz$/, "_fastqc.zip")
    """
    echo "[get_file] fastq: ${fastq}, output_html: ${output_html}, output_zip: ${output_zip}"
    """
}


process check_var {
    tag { "${fastq}" }
    executor "local"
    echo true
    input:
    val(fastq) from samples_fastqs2

    script:
    """
    # export SOMEVAR=fooooooo
    check_var.sh
    """
}
