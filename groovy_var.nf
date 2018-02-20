Channel.from(["Sample1.fastq.gz", "Sample2.fastq.gz"]).set { samples_fastqs }

process make_files {
    executor "local"
    echo true

    input:
    val(fastq) from samples_fastqs

    output:
    file(output_html)
    file(output_zip)

    script:
    output_html = "${fastq}".replaceFirst(/.fastq.gz$/, "_fastqc.html")
    output_zip = "${fastq}".replaceFirst(/.fastq.gz$/, "_fastqc.zip")
    """
    touch "${output_html}"
    touch "${output_zip}"
    """
}
