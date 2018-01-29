params.input_dir = "input"
params.sample_sheet = "samples.csv"
params.sample_sheet_colheader = "SampleID"
x = params.sample_sheet_colheader


Channel.fromPath( file(params.sample_sheet) )
                    .splitCsv(header: true)
                    .map{row ->
                        sample_col_key = row.keySet()[0] // first column is sample_ID
                        sample_ID = row."$sample_col_key"
                        sample_bam = file("${params.input_dir}/${sample_ID}.bam")
                        sample_bai = file("${params.input_dir}/${sample_ID}.bam.bai")
                        println "-------------"
                        println "--- start csv row mapping ----"
                        println "full row: ${row}"
                        println "sample_ID: ${sample_ID}"
                        println "bam file: ${sample_bam}"
                        println "bai file: ${sample_bai}"
                        println "--- end csv row mapping ----"
                        println "-------------"

                        return [
                        sample_ID,
                        sample_bam,
                        sample_bai
                                ]
                    }
                    .into{ samples_print;
                        samples_check;
                        samples_subscr }

samples_subscr.subscribe { item ->
                                    println "# # ------------- # #"
                                    println "# # --- start samples_subscr row print ---- # #"
                                    println item.join("\t")
                                    println "# #--- end samples_subscr row print ---- # #"
                                    println "# # ------------- # #"
                                }


process print_samples {
    tag { sample_ID }
    executor "local"

    input:
    set val(sample_ID), file(sample_bam), file(sample_bai) from samples_print

    exec:
    println "sample: ${sample_ID}, bam: ${sample_bam}, bai: ${sample_bai}"

}

process check_samples {
    tag { sample_ID }
    executor "local"

    input:
    set val(sample_ID), file(sample_bam), file(sample_bai) from samples_check

    script:
    """
    if [ -e "${sample_ID}.bam" ]; then echo "sample_bam exists"; else echo "sample_bam does not exist" && exit 1 ; fi
    if [ -e "${sample_ID}.bam.bai" ]; then echo "sample_bai exists"; else echo "sample_bai does not exist" && exit 1 ; fi
    """
}
