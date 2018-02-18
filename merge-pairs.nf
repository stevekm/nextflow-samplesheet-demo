// Joining sample-pairs across Channels
//
// $ cat samples.analysis.csv
// Sample,Tumor,Normal,Val1,Val2
// HapMap,SeraCare,HapMap,foo1,foo2
// SeraCare,SeraCare,HapMap,bar1,bar2
// NTC-H2O,NTC-H2O,NA,baz1,baz2
// HapMap2,SeraCare2,HapMap2,foo1,foo2
// SeraCare2,SeraCare2,HapMap2,bar1,bar2
// SeraCare3,SeraCare3,HapMap,ee1,ee2
// SeraCare4,SeraCare4,HapMap2,ff1,ff2
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

sample_files.combine(samples_pairs) // get all the combinations of samples & pairs
            .filter { item -> // only keep combinations where sample is same as tumor pair sample
                def sampleID = item[0]
                def tumorID = item[2]
                sampleID == tumorID
            }
            .map { item -> // re-order the elements for joining
                def sampleID = item[0]
                def sampleFile = item[1]
                def tumorFile = sampleFile
                def tumorID = item[2]
                def normalID = item[3]
                return [ tumorID, tumorFile, normalID ]
            }
            .combine(sample_files2) // combine again to get the samples & files again
            .filter { item -> // keep only combinations where the normal ID matches the new sample ID
                def tumorID = item[0]
                def tumorFile = item[1]
                def normalID = item[2]
                def sampleID = item[3]
                def sampleFile = item[4]
                normalID == sampleID
            }
            .map {item -> // re arrange the elements
                def tumorID = item[0]
                def tumorFile = item[1]
                def normalID = item[2]
                def sampleID = item[3]
                def sampleFile = item[4]
                def normalFile = sampleFile
                return [ tumorID, tumorFile, normalID, normalFile ]
            }
            .set { sample_file_pairs }
            // .subscribe { println "sample_files: ${it}" }


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
