task fastqc {
	File read1
	File read2
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		nt=$(nproc)
		fastqc -t $nt -o ./ ${read1}
		fastqc -t $nt -o ./ ${read2}
	>>>

	runtime {
		docker:docker
    	cluster: cluster_config
    	systemDisk: "cloud_ssd 40"
    	dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
	}
	output {
		File read1_html = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read1_zip = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
		File read2_html = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read2_zip = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
	}
}