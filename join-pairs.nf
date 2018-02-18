// Joining sample-pairs across Channels
//
// $ cat samples.analysis.csv
// Sample,Tumor,Normal,Val1,Val2
// HapMap,SeraCare,HapMap,foo1,foo2
// SeraCare,SeraCare,HapMap,bar1,bar2
// NTC-H2O,NTC-H2O,NA,baz1,baz2
// HapMap2,SeraCare2,HapMap2,foo1,foo2
// SeraCare2,SeraCare2,HapMap2,bar1,bar2
// Sample3,NA,NA,aa1,aa2
// Sample4,Sample4,NA,bb1,bb2
// Sample5,Sample6,Sample5,cc1,cc2
// Sample6,Sample6,Sample5,dd1,dd2

params.samples_file = "samples.analysis.csv"

// read in sample IDs and values from sheet
Channel.fromPath( file(params.samples_file) )
        .splitCsv(header: true)
        .tap { samples; samples2 }
        .map { row ->
            def sampleID = row['Sample']
            def val1 = row['Val1']
            def val2 = row['Val2']
            return [ sampleID, val1, val2 ]
        }
        .set { sample_vals }

// view entries as read from sheet
samples.subscribe { println "samples: ${it}" }

// setup sample pair mapping
samples2.map { row ->
    def sampleID = row['Sample']
    def normalID = row['Normal']
    return [ sampleID, normalID ]
    }
    .filter { item ->
        item[0] != item[1] // remove Normal samples
    }
    .filter { item ->
        item[1] != 'NA' // unpaired samples
    }
    .into { samples_pairs; samples_pairs2 }

// view paired entries
samples_pairs2.subscribe { println "samples_pairs2: ${it}" }

// make files for every sample
process make_file {
    tag { "${sampleID}" }
    echo true
    executor "local"

    input:
    set val(sampleID), val(val1), val(val2) from sample_vals

    output:
    set val(sampleID), file("${sampleID}.txt") into sample_files, sample_files2

    script:
    """
    echo "[make_file] sampleID: ${sampleID}, val1: ${val1}, val2" ${val2}"
    echo "[make_file] sampleID: ${sampleID}, val1: ${val1}, val2" ${val2}" > "${sampleID}.txt"
    """
}

// merge the files per-sample with the sample pairs
sample_files.join(samples_pairs) // gets the Normal ID for every sample; only samples that passed Normal ID filtering
            .map { item ->
                def tumorID = item[0]
                def tumorFile = item[1]
                def normalID = item[2]
                return [ normalID, tumorID, tumorFile ] // need to put the Normal ID as first array entry for next join operation
            }
            .join(sample_files2) // gets the normalFile for every normalID in the first position of the array; appends the filepath to the end of the array
            .map { item ->
                def normalID = item[0]
                def tumorID = item[1]
                def tumorFile = item[2]
                def normalFile = item[3]
                return [ tumorID, tumorFile, normalID, normalFile ] // put the array items back in the correct order again
            }
            .into { sample_file_pairs; sample_file_pairs2 }

sample_file_pairs2.subscribe { println "sample_file_pairs2: ${it}" }

process tumor_normal_compare {
    echo true
    executor "local"

    input:
    set val(tumorID), file(tumorFile), val(normalID), file(normalFile) from sample_file_pairs

    script:
    """
    echo "[tumor_normal_compare] tumorID: ${tumorID}, tumorFile: ${tumorFile}, normalID: ${normalID}, normalFile: ${normalFile}"
    """
}
