task fastq_screen {
	File read1
	File read2
	File screen_ref_dir
	File fastq_screen_conf
	String read1name = basename(read1,".fastq.gz")
	String read2name = basename(read2,".fastq.gz")
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		nt=$(nproc)
		mkdir -p /cromwell_root/tmp
		cp -r ${screen_ref_dir} /cromwell_root/tmp/
		#sed -i "s#/cromwell_root/fastq_screen_reference#${screen_ref_dir}#g" ${fastq_screen_conf}
		fastq_screen --aligner bowtie2 --conf ${fastq_screen_conf} --top 100000 --threads $nt ${read1}
		fastq_screen --aligner bowtie2 --conf ${fastq_screen_conf} --top 100000 --threads $nt ${read2}
	>>>

	runtime {
		docker:docker
    	cluster: cluster_config
    	systemDisk: "cloud_ssd 40"
    	dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
	}
	output {
		File png1 = "${read1name}_screen.png"
		File txt1 = "${read1name}_screen.txt"
		File html1 = "${read1name}_screen.html"
		File png2 = "${read2name}_screen.png"
		File txt2 = "${read2name}_screen.txt"
		File html2 = "${read2name}_screen.html"
	}
}