------
MYCRes
------

**Antibiotica resistance prediction for Mycobacteria tuberculosis WGS/AmpliSeq data**

Resistance summarizing plot: summed_resistances.html_

------------
Description
------------
This snakemake workflow links several bioinformatic tools to generate an antibiotic resistance prediction for sequenced Mycobacteria tuberculosis samples.
The `fastp <https://github.com/OpenGene/fastp>`__ preprocessing tool is used to trim the sequencing adapters off the reads. 
Here also a filtering for PHRED quality and minimum length is applied (default: 15 and 1). The Quality control tools `FastQC <https://github.com/s-andrews/FastQC>`__ 
and `MultiQC <https://github.com/ewels/MultiQC>`__ are used to perform a Quality control before and after trimming respectively. 
QC results can be found in `multiqc.html`_.
The reads are then mapped with `bwa <https://bio-bwa.sourceforge.net/bwa.shtml>`__ (bwa-mem) mapped against a preprocessed reference genome (bwa-index). 
The resulting bam files are sorted with `samtools sort <http://www.htslib.org/doc/samtools-sort.html>`__ 
and subsequently used to call mutations with `freebayes <https://github.com/freebayes/freebayes>`__. The found mutations are compared against 
the `pointfinder database <https://bitbucket.org/genomicepidemiology/pointfinder__db/src/master/>`__ to find antibiotic resistance causing mutations.
These information are enriched with sequencing coverage for the specific position and locus determined with `samtools_coverage <http://www.htslib.org/doc/samtools-coverage.html>`__ and `samtools_depth <http://www.htslib.org/doc/samtools-depth.html>`__ 
and visualized with `vega-altair <https://altair-viz.github.io/>`__. 
This resistance plot can be found for every sample in the folder `Resistance plot`_.
Additional coverage details gathered within the process can be found in a table format in `Loci coverage details`_.

**Author:**
    - `Adrian Doerr <Adrian.Doerr@uk-essen.de>`__, Institute for Artificial Intelligence in Medicine