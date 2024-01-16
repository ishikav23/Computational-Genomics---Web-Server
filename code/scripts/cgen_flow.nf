nextflow.enable.dsl=2

if (!params.job) {
    exit 1, "Error: missing required parameter '--job'"
}

if (!params.loc) {
    params.loc = '/home/projects/team2/app'
}

process assembly {
    input:
        val job
        val loc
    publishDir "$loc/jobs/$job", mode: 'copy', overwrite: true
    output:
        path assembly_out
    script:
        """
        echo $job
        $loc/scripts/assembly.sh -e cgen -l "${loc}/jobs/${job}/input" -o asm_contigs -s assembly_out -q $loc
        """
      
}

process prediction_and_phylogeny {
    input:
        val job
        val loc
        path assembly_out
    publishDir "$loc/jobs/$job", mode: 'copy', overwrite: true
    output:
        path prediction_out
        path phylogeny_out
    script:
        """
        bash -i $loc/scripts/prediction.sh -e cgen -l "${loc}/jobs/${job}/assembly_out" -o prediction_out  
        bash -i $loc/scripts/phylogeny.sh -e cgen -l "${loc}/jobs/${job}/assembly_out" -o phylogeny_out -q $loc
        """
      
}

process annotation {
    input:
        val job
        val loc
        path prediction_out
        path assembly_out
    publishDir "$loc/jobs/$job", mode: 'copy', overwrite: true
    output:
        path annotation_out
    script:
        """
        bash -i $loc/scripts/annotation.sh -e cgen -g igv -a "${loc}/jobs/${job}/assembly_out" -l "${loc}/jobs/${job}/prediction_out" -o annotation_out -q $loc
        
        """
      
}

process sort_outputs {
    input:
        val job
        val loc
        path prediction_out
        path assembly_out
        path annotation_out
        path phylogeny_out
    publishDir "$loc/jobs/$job", mode: 'copy', overwrite: true
    output:
        path output
    script:
        """
        $loc/scripts/sort_output.sh -a "${loc}/jobs/${job}/assembly_out" -b "${loc}/jobs/${job}/prediction_out" -c "${loc}/jobs/${job}/annotation_out" -d "${loc}/jobs/${job}/phylogeny_out" -o output
        """
      
}

workflow {
    def job="${params.job}"
    def loc="${params.loc}"
    assembly_out=assembly(job, loc)
    prediction_phylogeny_out=prediction_and_phylogeny(job, loc, assembly_out)
    annotation_out=annotation(job, loc, prediction_phylogeny_out[0], assembly_out)
    sort_outputs(job, loc, prediction_phylogeny_out[0], assembly_out, annotation_out, prediction_phylogeny_out[1])
}