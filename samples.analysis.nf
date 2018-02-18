Channel.fromPath( "samples.analysis.csv" )
        .splitCsv(header: true)
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
        // .tap { all_samples; all_samples2 }
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

sample_pairs2.subscribe { println "sample_pairs2: ${it}" }

process analyze_pairs {
    tag { "${sampleComparison}" }
    executor "local"
    echo true

    input:
    set val(sampleComparison), val(sampleID), val(tumorID), val(normalID), val(sampleVal1), val(sampleVal2) from sample_pairs

    script:
    """
    echo "sampleComparison: ${sampleComparison}, sampleID: ${sampleID}, tumorID: ${tumorID}, normalID: ${normalID},  sampleVal1: ${sampleVal1}, sampleVal2: ${sampleVal2}"
    """
}
