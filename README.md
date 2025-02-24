---
editor_options: 
  markdown: 
    wrap: 72
---

# how-to-liftOver-bigwig

This repository contains scripts for liftOver conversion of genomic
track bigwig files

These steps perform bigwig conversions from hg38 to hg19. I used the
following tools and steps. Maybe the steps could be more elegant and
simplified, e.g. sorting not needed in every step.

We need the ucsc tools from <https://hgdownload.soe.ucsc.edu/admin/exe/>

```{bash}
export PATH="/projappl/project_2007567/softwares/ucsc-tools:\$PATH”
```

I performed the computations on CSC, load tools to the environment (see
list at the bottom). Bedops is most relevant.

```{bash}
module load biokit
module load bedops
```

Directory that contains hg38ToHg19.over.chain, download using
experiments/download.sh

```{bash}
liftOver_chainfile_path=/projappl/project_2006203/liftOver/
cd /scratch/project_2007567/phyloP
fetchChromSizes hg19 > hg19.chrom.sizes

```

We will liftOver Zoonomia PhyloP scores

```{bash}

BIGWIG=cactus241way.phyloP.bw
##Convert BigWig to chromosome-wise bedGraph files, liftOver and sort

for chr in {1..22} X Y; do

  bigWigToBedGraph -chrom="chr"$chr $BIGWIG ${BIGWIG%%.*}".chr"$chr.bedGraph 
  liftOver -bedPlus=4 ${BIGWIG%%.*}".chr"$chr.bedGraph $liftOver_chainfile_path"hg38ToHg19.over.chain" ${BIGWIG%%.*}".chr"$chr.hg19.bedGraph unMapped.chr$chr.${BIGWIG%%.*}
  bedSort ${BIGWIG%%.*}".chr"$chr.hg19.bedGraph ${BIGWIG%%.*}".chr"$chr.hg19.sorted.bedGraph

done
```

The hg19.sorted.bedGraph may contain regions mapped to other
chromosomes. Extract chromosome-specific regions from each file.

```{bash}
mkdir separate_chroms/ 
for chr in {1..22} X Y; do 
awk -v chr="$chr" -v base="${BIGWIG%%.*}" '{print > "separate_chroms/"base".chr"chr"_"$1".bedgraph"}' "${BIGWIG%%.*}.chr${chr}.hg19.sorted.bedGraph"
done
```

Then we need to combine these

```{bash}
cd separate_chroms

for chr in {1..22} X Y; do 
    echo $chr
    cat *_chr$chr.bedgraph > combined.chr$chr.bedgraph
    bedSort combined.chr$chr.bedgraph combined_sorted.chr$chr.bedgraph
done
```

We need to resolve overlap issues as bedGraphToBigWig does not allow
overlaps. Use the maximum score for the overlapping regions.

```{bash}
for chr in {1..22} X Y; do
   echo $chr
   awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }' combined_sorted.chr$chr.bedgraph | sort-bed - > chr$chr.bed
   bedops --partition chr$chr.bed > chr$chr"_partitions.bed"
   bedmap --echo --max --delim '\t' chr$chr"_partitions.bed" chr$chr.bed > chr$chr"_unique.bed"
   sort-bed chr$chr"_unique.bed" > chr$chr"_unique_sorted.bed"
done
```

Merge beds

```{bash}

cat chr1_unique_sorted.bed chr2_unique_sorted.bed chr3_unique_sorted.bed chr4_unique_sorted.bed chr5_unique_sorted.bed \
    chr6_unique_sorted.bed chr7_unique_sorted.bed chr8_unique_sorted.bed chr9_unique_sorted.bed chr10_unique_sorted.bed \
    chr11_unique_sorted.bed chr12_unique_sorted.bed chr13_unique_sorted.bed chr14_unique_sorted.bed chr15_unique_sorted.bed \
    chr16_unique_sorted.bed chr17_unique_sorted.bed chr18_unique_sorted.bed chr19_unique_sorted.bed chr20_unique_sorted.bed \
    chr21_unique_sorted.bed chr22_unique_sorted.bed chrX_unique_sorted.bed chrY_unique_sorted.bed \
    > all_chromosomes_unique.bed

```

Final sort

```{bash}

sort-bed all_chromosomes_unique.bed > all_chromosomes_unique_sorted.bed
```

Convert bedGraphToBigWig

```{bash}
bedGraphToBigWig all_chromosomes_unique_sorted.bed ../hg19.chrom.sizes ../cactus241way.phyloP.hg19.bw
```

Done!

## Tools in the environment (CSC biokit module)

```{bash}

bedops  2.4.41  environment loaded 
bamtools  2.5.2  environment loaded 
bedtools  2.30.0  environment loaded 
Bioperl  1.7.8  environment loaded 
java  1.8.0_302  environment loaded 
EMBOSS  6.5.7  environment loaded 
BLAST  2.15.0  environment loaded 
Bowtie  1.2.3  environment loaded 
Bowtie2  2.5.3  environment loaded 
BWA  0.7.17  environment loaded 
cd-hit  4.8.1  environment loaded 
clustalo  1.2.4  environment loaded 
clustalw  2.1  environment loaded 
cufflinks  2.2.1  environment loaded 
diamond  2.1.6  environment loaded 
EMBOSS  6.5.7  environment loaded 
Exonerate  2.4.0  environment loaded 
fastx-toolkit  0.0.14  environment loaded 
hisat2  2.2.1  environment loaded 
hmmer  3.4  environment loaded 
kraken  2.1.2  environment loaded 
krona  2.8.1  environment loaded 
mafft  7.505  environment loaded 
minimap2  2.24  environment loaded 
Mummer  4.0.0brc1  environment loaded 
muscle  5.1  environment loaded 
SANSPANZ  3  environment loaded 
Phylip  3.697  environment loaded 
picard  2.27.5  environment loaded 
prinseq  0.20.4  environment loaded 
samtools  1.18  environment loaded 
sratoolkit  3.0.0  environment loaded 
stacks  2.65  environment loaded 
star  2.7.11b  environment loaded 
trimmomatic  0.39  environment loaded 
samtools  1.16.1  environment loaded 
Trinity 2.8.5  environment loaded 
vcftools  0.1.17  environment loaded 
Velvet 1.2.10  environment loaded 
vsearch  2.22.1  environment loaded 
wtdbg2  2.5  environment loaded 
```
