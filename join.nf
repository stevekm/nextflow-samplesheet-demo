params.sheet = "samples.tumor.normal.csv2"
Channel.fromPath( file(params.sheet) )
        .splitCsv()
        .map { row ->
            def sample_ID_tumor = row[0]
            def sample_ID_normal = row[1]

            return [ sample_ID_tumor, sample_ID_normal ]
        }
        .filter{ sample_ID_tumor, sample_ID_normal ->
                        sample_ID_tumor != "NA" && sample_ID_normal != "NA"
        }
        .set { samples_pairs }


params.fastq_raw_sheet = "samples.fastq-raw.csv"
Channel.fromPath( file(params.fastq_raw_sheet) )
        .splitCsv()
        .map { row ->
            def sample_ID = row[0]
            return sample_ID
        }
        .set { sample_IDs }

samples_pairs.join(sample_IDs).println()

