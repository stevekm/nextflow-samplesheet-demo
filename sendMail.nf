username = System.getProperty("user.name")
params.email_host = "nyumc.org"
params.email_from = "${username}@${params.email_host}"
params.email_to = "${username}@${params.email_host}"


params.samples_list = ['Sample1', 'Sample2', 'Sample3', 'Sample4']
Channel.from( params.samples_list ).into { samples_list; samples_list2 }

samples_list2.subscribe {
    println "[samples_list2] ${it}"
}
process make_txt {
    tag { "${sample_ID}" }
    executor "local"
    echo true

    input:
    val(sample_ID) from samples_list

    output:
    file "${sample_ID}.txt" into samples_files, samples_files2

    script:

    """
    echo "[make_txt] ${sample_ID}"
    echo "[make_txt] ${sample_ID}" > "${sample_ID}.txt"
    """
}

sendMail {
    to "${params.email_to}"
    from "${params.email_from}"
    attach samples_files.toList().getVal()
    subject 'Nextflow test'

    body
    '''
    Hi there,
    Here are files from Nextflow
    '''
}
