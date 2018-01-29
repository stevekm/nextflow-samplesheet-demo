params.input_dir = "input"
params.sample_sheet = "samples.csv"
params.sample_sheet_colheader = "SampleID"



Channel.fromPath( file(params.sample_sheet) )
                    .splitCsv(header: true)
                    .map{row ->
                        // sample_ID = row."${params.sample_sheet_colheader}"
                        // sample_ID = row["SampleID"]
                        println "-------------"
                        println "--- start csv row mapping ----"
                        // println "${params.sample_sheet_colheader}"
                        println "full row: " + row
                        println 'sample_ID: ' + row."${params.sample_sheet_colheader}"
                        println "bam file: ${params.input_dir}/${sample_ID}.bam"
                        println file("${params.input_dir}/${sample_ID}.bam")
                        println "bai file: ${params.input_dir}/${sample_ID}.bam.bai"
                        println file("${params.input_dir}/${sample_ID}.bam.bai")
                        println "--- end csv row mapping ----"
                        println "-------------"

                        return [
                        sample_ID,
                        file("${params.input_dir}/${sample_ID}.dd.ra.rc.bam"),
                        file("${params.input_dir}/${sample_ID}.bam.bai")
                                ]
                    }
                    .into{ samples_demo1; samples_demo2 }

// samples_demo2.sub
