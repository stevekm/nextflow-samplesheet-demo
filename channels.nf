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
    set val("${sampleID}"), file("${sampleID}.txt"), file("${sampleID}2.txt") into samples_file3
    set val("${sampleID}"), file("${sampleID}.txt"), file("${sampleID}3.txt") into samples_file4

    script:
    """
    echo "make_file: ${sampleID}"
    echo "make_file: ${sampleID}" > "${sampleID}.txt"
    echo "make_file: ${sampleID}" > "${sampleID}2.txt"
    echo "make_file: ${sampleID}" > "${sampleID}3.txt"
    echo "make_file: ${sampleID}" > "${sampleID}4.txt"
    """
}

samples_files2.subscribe { println "samples_files2: ${it}" }

// doesnt work
// samples_files.empty()
//             .from( ['foo', 'bar', 'baz'] )
//             .subscribe { println "samples_files: ${it}" }

process get_files {
    echo true
    executor "local"

    input:
    set val(sampleID), file(sampleTXT), file(sampleTXT2) from samples_file3

    script:
    """
    echo "[get_files] sampleID: ${sampleID}, sampleTXT: ${sampleTXT}, sampleTXT2: ${sampleTXT2}"
    """

}

process get_files2 {
    echo true
    executor "local"

    input:
    set val(sampleID), file(sampleTXT), file(sampleTXT2) from samples_file4

    script:
    """
    echo "[get_files2] sampleID: ${sampleID}, sampleTXT: ${sampleTXT}, sampleTXT2: ${sampleTXT2}"
    """

}
