Channel.from('alpha', 'beta', 'gamma').set{ values }

process print_values {
    tag { value }
    echo true

    input:
    val(value) from values

    output:
    file "${value}.txt" into value_files

    script:
    """
    echo "value is ${value}"
    echo "heres your value: ${value}" > "${value}.txt"
    cat "${value}.txt"
    """
}
value_files.collectFile(name: 'all_values.txt', storeDir: ".").subscribe{ println it }
