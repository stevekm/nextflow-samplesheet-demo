params.regions_file = "regions.bed"
params.samples = ['Sample1', 'Sample2', 'Sample3', 'Sample4']
params.subset_bed_script = "subset_bed.py"

Channel.from( params.samples ).set{ samples }

Channel.fromPath( params.regions_file )
            .splitCsv(sep: '\t')
            .map{row ->
                row[0]
            }
            .unique()
            .set{ chroms }

Channel.fromPath( params.regions_file ).set{ regions_file_ch }


process combine_chrom_samples {
    tag { "${sampleID}.${chrom}.${regions_file}" }
    publishDir "output/chroms"

    input:
    set val(chrom), val(sampleID), file(regions_file) from chroms.combine(samples).combine(regions_file_ch)

    output:
    file "${sampleID}.${chrom}.bed"

    script:
    """
    $params.subset_bed_script "${chrom}" "${regions_file}" > "${sampleID}.${chrom}.bed"
    """
}
