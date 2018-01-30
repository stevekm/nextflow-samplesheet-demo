params.samples = ['Sample1', 'Sample2', 'Sample3', 'Sample4']

Channel.from( params.samples ).set{ samples }

process make_file {
    input:
    val(sampleID) from samples

    output:
    file "${sampleID}" into samples_files, samples_files2

    script:
    """
    echo "${sampleID}" > "${sampleID}"
    """
}

samples_files2.toList().println()

process gather_files {
    input:
    file "*" from samples_files.toList()

    exec:
    println "*"

}
