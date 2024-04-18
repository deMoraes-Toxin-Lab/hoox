CONFIG=tests/config.yaml
GENOMES=tests/genomes.txt
GENOMES_MESSY=tests/genomes_messy.txt
SNAKEMAKE=snakemake --cores all --configfile $(CONFIG)


.PHONY test-dry:
test-dry: $(GENOMES)
	$(SNAKEMAKE) -np


.PHONY test:
test: $(GENOMES)
	$(SNAKEMAKE)


.PHONY test-mtime:
test-mtime: $(GENOMES)
	$(SNAKEMAKE) --rerun-triggers mtime


$(GENOMES): $(GENOMES_MESSY)
	utils/deduplicate_accessions.R $< 2> /dev/null > $@


.PHONY style:
style:
	snakefmt .
	black .
	/usr/bin/Rscript -e 'styler::style_dir(".")'
	isort .
	isort workflow/Snakefile


.PHONY dag:
dag: $(GENOMES)
	$(SNAKEMAKE) --forceall --dag | dot -Tsvg > dag.svg
	$(SNAKEMAKE) --rulegraph      | dot -Tsvg > rulegraph.svg
	$(SNAKEMAKE) --filegraph      | dot -Tsvg > filegraph.svg


.PHONY clean:
clean:
	rm -rf tests/results/
	rm -rf .snakemake/
	rm -rf dag.svg rulegraph.svg filegraph.svg
	rm -rf tests/genomes.txt
	git clean -d -n
	printf "\n\nTo remove untracked files run:\ngit clean -d -f\n"
