#!/bin/bash
#SBATCH --job-name=liftOver_phyloP
#SBATCH --output=outs/liftOver_phyloP.out
#SBATCH --error=errs/liftOver_phyloP.err
#SBATCH --account=project_2007567
#SBATCH --partition=small
#SBATCH --ntasks=1
#SBATCH --time=3-00:00:00
#SBATCH --mem-per-cpu=200G #350G
#SBATCH --cpus-per-task=1

# 30218411 hg38.phyloP470way.bw took 1-10:09:33 and 143GB of memory
# 30283406 hg38.phyloP447wayLRT.bw took 1-06:01:34 134.28 GB
# 30331942 hg38.phyloP447way.bw took 1-08:54:16 138.47 GB
export PATH="/projappl/project_2007567/softwares/ucsc-tools:$PATH" 

# grep -h '^chain' hg38-chm13v2.over.chain  | awk '{print $8}' | sort -u
# grep -h '^chain' hg38-chm13v2.over.chain | awk '{print $3}' | sort -u


liftOver_chainfile_path=/projappl/project_2006203/liftOver/
# cd /scratch/project_2007567/comparative-genomics/Data/Zoonomia-241-mammalian-2020v2b/ #DONE
# cd /scratch/project_2007567/comparative-genomics/Data/UCSC_multiz470way/phyloP470way/ #DONE? Check chromosomes
cd /scratch/project_2007567/comparative-genomics/Data/UCSC-447-mammalian/phyloP/

fetchChromSizes hs1 > hs1.chrom.sizes

module load biokit
module load bedops

#BIGWIG=241-mammalian-2020v2.bigWig #DONE
#BIGWIG=hg38.phyloP470way.bw #This has mode chromosomes than chr1-chr22, chrX and chrY
BIGWIG=hg38.phyloP447way.bw # is this REV model? Same I have visualised before?
#BIGWIG=hg38.phyloP447wayLRT.bw #DONE, low signal?

bigWigInfo -chroms $BIGWIG


#DONE! Took 1 day
for chr in {1..22} X Y; do
   echo $chr
   echo "bigWigToBedGraph"
   bigWigToBedGraph -chrom="chr"$chr $BIGWIG ${BIGWIG%%.*}".chr"$chr.bedGraph
   # -bedPlus=N - File is bed N+ format (i.e. first N fields conform to bed format)
   echo "liftOver"
   liftOver -bedPlus=4 ${BIGWIG%%.*}".chr"$chr.bedGraph $liftOver_chainfile_path"hg38-chm13v2.over.chain" ${BIGWIG%%.*}".chr"$chr.chm13v2.bedGraph unMapped.chr$chr.${BIGWIG%%.*}
   echo "bedSort"
   bedSort ${BIGWIG%%.*}".chr"$chr.chm13v2.bedGraph ${BIGWIG%%.*}".chr"$chr.chm13v2.sorted.bedGraph
done

#The chm13v2.sorted.bedGraph may contain regions mapped to other chromosomes
#Extract chromosome-specific regions from each file

# 30095889 DONE, maybe this is not an issue in hg38--> chm13vs2 conversion
mkdir separate_chroms/
for chr in {1..22} X Y; do
  awk -v chr="$chr" -v base="${BIGWIG%%.*}" '{print > "separate_chroms/"base".chr"chr"_"$1".bedgraph"}' "${BIGWIG%%.*}.chr${chr}.chm13v2.sorted.bedGraph"
done

#DONE Then we need to combine these 30096988, took 04:34:34 time and 21.96 GB memory 
cd separate_chroms
#
for chr in {1..22} X Y; do
 echo $chr
 cat *_chr$chr.bedgraph  > combined.chr$chr.bedgraph
 bedSort combined.chr$chr.bedgraph combined_sorted.chr$chr.bedgraph
done
#resolve overlap issues

for chr in {1..22} X Y; do
  echo $chr
  awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }' combined_sorted.chr$chr.bedgraph | sort-bed - > chr$chr.bed
  bedops --partition chr$chr.bed > chr$chr"_partitions.bed"
  bedmap --echo --max --delim '\t' chr$chr"_partitions.bed" chr$chr.bed > chr$chr"_unique.bed"
  sort-bed chr$chr"_unique.bed" > chr$chr"_unique_sorted.bed"
done

#Merge beds
#30139791 50G not enough --> 137.40 G was enough
 cat chr1_unique_sorted.bed chr2_unique_sorted.bed chr3_unique_sorted.bed chr4_unique_sorted.bed chr5_unique_sorted.bed \
     chr6_unique_sorted.bed chr7_unique_sorted.bed chr8_unique_sorted.bed chr9_unique_sorted.bed chr10_unique_sorted.bed \
     chr11_unique_sorted.bed chr12_unique_sorted.bed chr13_unique_sorted.bed chr14_unique_sorted.bed chr15_unique_sorted.bed \
     chr16_unique_sorted.bed chr17_unique_sorted.bed chr18_unique_sorted.bed chr19_unique_sorted.bed chr20_unique_sorted.bed \
     chr21_unique_sorted.bed chr22_unique_sorted.bed chrX_unique_sorted.bed chrY_unique_sorted.bed \
     > all_chromosomes_unique.bed
# 
sort-bed all_chromosomes_unique.bed > all_chromosomes_unique_sorted.bed

#LINENUM=1490409334
#head -<$LINENUM + 10> all_chromosomes_sorted_unique.bed | tail -20 

bedGraphToBigWig all_chromosomes_unique_sorted.bed ../hs1.chrom.sizes "../"${BIGWIG%.*}"_hs1.bw"

# all_chromosomes_unique_sorted.bed is 82G
#The result is 20G


# rm *
# cd ..
# rm *.bedGraph
# rm unMapped*


