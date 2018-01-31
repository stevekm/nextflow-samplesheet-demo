params.regions_file = "regions.bed"
params.samples = ['Sample1', 'Sample2', 'Sample3', 'Sample4']

Channel.from( params.samples ).set{ samples }
Channel.fromPath( params.regions_file )
            .splitCsv(sep: '\t')
            .map{row ->
                row[0]
            }
            .unique()
            .set{ chroms }

process combine_chrom_samples {
    tag { "${sampleID}.${chrom}" }
    publishDir "output/chroms"

    input:
    set val(chrom), val(sampleID) from chroms.combine(samples)

    output:
    file "${sampleID}.${chrom}.txt"

    script:
    """
    touch "${sampleID}.${chrom}.txt"
    """
}
