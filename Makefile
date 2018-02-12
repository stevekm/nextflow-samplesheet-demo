none:

install:
	curl -fsSL get.nextflow.io | bash

run:
	./nextflow run main.nf

example:
	./nextflow run examples/example.nf

clean-logs:
	rm -f .nextflow.log.*

clean-output:
	[ -d output ] && mv output oldoutput && rm -rf oldoutput &

clean-work:
	[ -d work ] && mv work oldwork && rm -rf oldwork &

clean: clean-logs clean-work

clean-all: clean clean-output

copy: output results_dir
	rsync -vrthP output/ results_dir/
