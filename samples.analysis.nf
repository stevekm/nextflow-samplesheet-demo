Channel.fromPath( "samples.analysis.csv" )
        .splitCsv(header: true)
        .tap { all_samples; all_samples2; all_samples3 }
        .map { row -> // parse the samplesheet
            def sampleID = row['Sample']
            def tumorID = row['Tumor']
            def normalID = row['Normal']
            def sampleVal1 = row['Val1']
            def sampleVal2 = row['Val2']
            def sampleComparison = "${tumorID}_${normalID}" // unique key for the comparison

            // return [ 'Comparison': sampleComparison,
            //         'Sample': sampleID,
            //         'Tumor': tumorID,
            //         'Normal': normalID,
            //         'Val1': sampleVal1,
            //         'Val2': sampleVal2 ]
            return [ sampleComparison, sampleID, tumorID, normalID, sampleVal1, sampleVal2 ]
        }
        .filter { item -> // leave only samples with paired Normal
            item[3] != 'NA'
        }
        .groupTuple()
        .into { sample_pairs; sample_pairs2 }
        // .filter { item -> // leave only non-Normal samples
        //     item['Sample'] != item['Normal']
        // }
        // .filter { item -> // leave only samples with paired Normal
        //     item['Normal'] != 'NA'
        // }
        // .join(all_samples)
        // .println()

all_samples2.subscribe { println "all_samples2: ${it}" }
sample_pairs2.subscribe { println "sample_pairs2: ${it}" }

process analyze_pairs {
    tag { "${sampleComparison}" }
    executor "local"
    echo true

    input:
    set val(sampleComparison), val(sampleID), val(tumorID), val(normalID), val(sampleVal1), val(sampleVal2) from sample_pairs

    script:
    """
    echo "[analyze_pairs] sampleComparison: ${sampleComparison}, sampleID: ${sampleID}, tumorID: ${tumorID}, normalID: ${normalID},  sampleVal1: ${sampleVal1}, sampleVal2: ${sampleVal2}"

    normalVal1="\$(echo "${sampleVal1}" | tr -d '[' | tr -d ',' | tr -d ']' | cut -f1 -d' ')"
    tumorVal1="\$(echo "${sampleVal1}" | tr -d '[' | tr -d ',' | tr -d ']' | cut -f2 -d' ')"

    normalVal2="\$(echo "${sampleVal2}" | tr -d '[' | tr -d ',' | tr -d ']' | cut -f1 -d' ')"
    tumorVal2="\$(echo "${sampleVal2}" | tr -d '[' | tr -d ',' | tr -d ']' | cut -f2 -d' ')"

    echo "[analyze_pairs] normalVal1: \${normalVal1}, tumorVal1: \${tumorVal1}, normalVal2: \${normalVal2}, tumorVal2: \${tumorVal2} "

    """
}

process print_row {
    echo true
    input:
    val(row) from all_samples
    script:
    """
    echo "print_row: ${row}"
    """
}


// leave as array map dictonary instead
all_samples3.map{ row ->
    def sampleID = row['Sample']
    def tumorID = row['Tumor']
    def normalID = row['Normal']
    def sampleVal1 = row['Val1']
    def sampleVal2 = row['Val2']
    def sampleComparison = "${tumorID}_${normalID}" // unique key for the comparison
    return [ 'Comparison': sampleComparison,
            'Sample': sampleID,
            'Tumor': tumorID,
            'Normal': normalID,
            'Val1': sampleVal1,
            'Val2': sampleVal2 ]
            }
            .filter { item -> // leave only samples with paired Normal
                item['Normal'] != 'NA'
            }
            .tap { samples_array; samples_array2 }
            .groupBy()
            .into { samples_array_group; samples_array_group2 }


samples_array2.subscribe { println "samples_array2: ${it}" }

samples_array_group2.subscribe { println "samples_array_group2: ${it}" }
