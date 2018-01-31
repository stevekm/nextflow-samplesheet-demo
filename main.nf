params.input_dir = "input"
params.output_dir = "output"

params.sample_sheet = "samples.tsv"
params.sample_sheet_colheader = "SampleID"

params.pairs_sample_sheet = "samples.pairs.csv"
params.pairs_sample_sheet_tumor_header = "#SAMPLE-T"
params.pairs_sample_sheet_normal_header = "#SAMPLE-N"
params.pairs_sheet_nomatch_value = "NA"

// Each Sample
Channel.fromPath( file(params.sample_sheet) )
                    .splitCsv(header: true, sep: '\t')
                    .map{row ->
                        // get the sampleID from the row
                        // def sample_col_key = row.keySet()[0] // first column is sample_ID <- !! THIS WORKS !!
                        // sample_ID = row."$sample_col_key"
                        // def sample_ID = row[ sample_col_key ]
                        // def sample_ID = row[ params.sample_sheet_colheader ]
                        def sample_ID = row."${params.sample_sheet_colheader}"
                        def sample_bam = file("${params.input_dir}/${sample_ID}.bam")
                        def sample_bai = file("${params.input_dir}/${sample_ID}.bam.bai")
                        println "-------------"
                        println "--- start TSV row mapping ----"
                        println "-- full row: ${row}"
                        println "-- sample_ID: ${sample_ID}"
                        println "-- bam file: ${sample_bam}"
                        println "-- bai file: ${sample_bai}"
                        println "--- end csv row mapping ----"
                        println "-------------"

                        return [sample_ID, sample_bam, sample_bai]
                    }
                    .into{
                        samples_print;
                        samples_check;
                        samples_subscr;
                        samples_demo
                    }

Channel.fromPath( file(params.pairs_sample_sheet) )
                    .splitCsv(header: true, sep: ',')
                    .map{row ->
                        def sample_tumor_ID = row."${params.pairs_sample_sheet_tumor_header}"
                        def sample_normal_ID = row."${params.pairs_sample_sheet_normal_header}"
                        def sample_comparison_ID = "${sample_tumor_ID}_${sample_normal_ID}"
                        def sample_tumor_bam = file("${params.input_dir}/${sample_tumor_ID}.bam")
                        def sample_tumor_bai = file("${params.input_dir}/${sample_tumor_ID}.bam.bai")
                        def sample_normal_bam = file("${params.input_dir}/${sample_normal_ID}.bam")
                        def sample_normal_bai = file("${params.input_dir}/${sample_normal_ID}.bam.bai")
                        println "##########"
                        println "#### start CSV pairs row mapping ######"
                        println "## full row: ${row}"
                        println "## sample_tumor_ID: ${sample_tumor_ID}"
                        println "## sample_normal_ID: ${sample_normal_ID}"
                        println "## sample_comparison_ID: ${sample_comparison_ID}"
                        println "## sample_tumor_bam: ${sample_tumor_bam}"
                        println "## sample_tumor_bai: ${sample_tumor_bai}"
                        println "## sample_normal_bam: ${sample_normal_bam}"
                        println "## sample_normal_bam: ${sample_normal_bam}"
                        println "## sample_normal_bai: ${sample_normal_bai}"
                        println "#### end CSV pairs row mapping ######"
                        println "##########"

                        return [ sample_comparison_ID, sample_tumor_ID, sample_tumor_bam, sample_tumor_bai, sample_normal_ID, sample_normal_bam, sample_normal_bai ]
                    }
                    .filter{ sample_comparison_ID, sample_tumor_ID, sample_tumor_bam, sample_tumor_bai, sample_normal_ID, sample_normal_bam, sample_normal_bai ->
                        sample_tumor_ID != params.pairs_sheet_nomatch_value && sample_normal_ID != params.pairs_sheet_nomatch_value
                    }
                    .set{ samples_pairs }


process print_samples {
    tag { sample_ID }
    executor "local"
    echo true

    input:
    set val(sample_ID), file(sample_bam), file(sample_bai) from samples_print

    script:
    """
    echo "sample: ${sample_ID}, bam: ${sample_bam}, bai: ${sample_bai}"
    """

}

process make_samples_foo_txt {
    tag { sample_ID }
    executor "local"
    publishDir "${params.output_dir}/samples_foo_txt"

    input:
    set val(sample_ID), file(sample_bam), file(sample_bai) from samples_check

    output:
    file "${sample_ID}.foo.txt" into samples_files, samples_files2

    script:
    """
    if [ -e "${sample_ID}.bam" ]; then echo "sample_bam exists"; else echo "sample_bam does not exist" && exit 1 ; fi
    if [ -e "${sample_ID}.bam.bai" ]; then echo "sample_bai exists"; else echo "sample_bai does not exist" && exit 1 ; fi
    echo "${sample_ID}" > "${sample_ID}.foo.txt"
    """
}

samples_files2.toList().println()

process files_list_file {
    executor "local"
    publishDir "${params.output_dir}/files_list_file"

    input:
    file "*.foo.txt" from samples_files.toList()

    output:
    file "files.txt"

    script:
    """
    echo "*.foo.txt" > files.txt
    """


}

process print_samples_pairs {
    echo true
    publishDir "${params.output_dir}/samples_pairs_txt"

    input:
    set val(sample_comparison_ID), val(sample_tumor_ID), file(sample_tumor_bam), file(sample_tumor_bai), val(sample_normal_ID), file(sample_normal_bam), file(sample_normal_bai) from samples_pairs

    output:
    file "${sample_comparison_ID}.txt" into samples_pairs_txt

    script:
    """
    echo "sample_comparison_ID: ${sample_comparison_ID}, sample_tumor_ID: ${sample_tumor_ID}, sample_tumor_bam: ${sample_tumor_bam}, sample_tumor_bai: ${sample_tumor_bai}, sample_normal_ID: ${sample_normal_ID}, sample_normal_bam: ${sample_normal_bam}, sample_normal_bai: ${sample_normal_bai}"
    echo "${sample_comparison_ID}" > "${sample_comparison_ID}.txt"
    """
}

process gather_samples_pairs_txt {
    echo true
    publishDir "${params.output_dir}/gather_samples_pairs_txt"

    input:
    file "*" from samples_pairs_txt.toList()

    output:
    file "gather_samples_pairs.txt"

    script:
    """
    echo "*"
    echo "*" > gather_samples_pairs.txt
    """
}
