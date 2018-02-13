params.samples_list = ['Sample1', 'Sample2', 'Sample3', 'Sample4']
Channel.from( params.samples_list ).into{ samples_list; samples_list2 }

samples_list2.println()

process make_file {
    echo true
    executor "local"
    input:
    val(sample_ID) from samples_list

    output:
    file  "${sample_ID}.txt" into samples_files

    script:
    """
    touch "${sample_ID}.txt"
    """
}

process python_test {
    echo true
    executor "local"

    input:
    file 'file*' from samples_files.collect()

    script:
    """
    python - file* <<E0F
import sys
print(sys.argv)
E0F
    """

}
