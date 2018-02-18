Channel.from( ['Sample1','Sample2','Sample3','Sample4'] ).into { samples; samples2 }

samples2.subscribe { println "samples2: ${it}" }

process make_file {
    tag { "${sampleID}" }
    echo true
    executor "local"

    input:
    val(sampleID) from samples

    output:
    file "${sampleID}.txt" into samples_files, samples_files2

    script:
    """
    echo "make_file: "${sampleID}"
    echo "make_file: "${sampleID}" > "${sampleID}.txt"
    """
}

samples_files2.subscribe { println "samples_files2: ${it}" }

// doesnt work
// samples_files.empty()
//             .from( ['foo', 'bar', 'baz'] )
//             .subscribe { println "samples_files: ${it}" }
