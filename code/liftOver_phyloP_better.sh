#!/bin/bash
#SBATCH --job-name=liftOver_phyloP
#SBATCH --output=outs/liftOver_phyloP.out
#SBATCH --error=errs/liftOver_phyloP.err
#SBATCH --account=project_2007567
#SBATCH --partition=small
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=350G
#SBATCH --cpus-per-task=1

#22713485 

export PATH="/projappl/project_2007567/softwares/ucsc-tools:$PATH" 

liftOver_chainfile_path=/projappl/project_2006203/liftOver/
cd /scratch/project_2007567/phyloP

#fetchChromSizes hg19 > hg19.chrom.sizes

module load biokit
module load bedops

BIGWIG=cactus241way.phyloP.bw
#BIGWIG=hg38.phyloP447way.bw
#BIGWIG=hg38.phyloP447wayLRT.bw

#Maybe first convert BigWig to chromosome-wide wig files, there is already the wig file
#grep -o "chrom=[^ ]*" "${BIGWIG%.*}".wig | cut -d '=' -f 2 | sort | uniq

#DONE! Took 8 hours
#for chr in {1..22} X Y; do
#    echo $chr
#    echo "bigWigToBedGraph"
#    bigWigToBedGraph -chrom="chr"$chr $BIGWIG ${BIGWIG%%.*}".chr"$chr.bedGraph
#    # -bedPlus=N - File is bed N+ format (i.e. first N fields conform to bed format)
#    echo "liftOver"
#    liftOver -bedPlus=4 ${BIGWIG%%.*}".chr"$chr.bedGraph $liftOver_chainfile_path"hg38ToHg19.over.chain" ${BIGWIG%%.*}".chr"$chr.hg19.bedGraph unMapped.chr$chr.${BIGWIG%%.*} 
#    echo "bedSort"
#    bedSort ${BIGWIG%%.*}".chr"$chr.hg19.bedGraph ${BIGWIG%%.*}".chr"$chr.hg19.sorted.bedGraph
#done

#The hg19.sorted.bedGraph may contain regions mapped to other chromosomes
#Extract chromosome-specific regions from each file

#Done
#mkdir separate_chroms/
#for chr in {1..22} X Y; do
#  awk -v chr="$chr" -v base="${BIGWIG%%.*}" '{print > "separate_chroms/"base".chr"chr"_"$1".bedgraph"}' "${BIGWIG%%.*}.chr${chr}.hg19.sorted.bedGraph"
#done

#Then we need to combine these
cd separate_chroms
#DONE!
# for chr in {1..22} X Y; do
#  echo $chr
#  cat *_chr$chr.bedgraph  > combined.chr$chr.bedgraph
#  bedSort combined.chr$chr.bedgraph combined_sorted.chr$chr.bedgraph
# done
#resolve overlap issues

# for chr in {1..22} X Y; do
#   echo $chr
#   awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }' combined_sorted.chr$chr.bedgraph | sort-bed - > chr$chr.bed
#   bedops --partition chr$chr.bed > chr$chr"_partitions.bed"
#   bedmap --echo --max --delim '\t' chr$chr"_partitions.bed" chr$chr.bed > chr$chr"_unique.bed"
#   sort-bed chr$chr"_unique.bed" > chr$chr"_unique_sorted.bed"
# done

#Merge beds

cat chr1_unique_sorted.bed chr2_unique_sorted.bed chr3_unique_sorted.bed chr4_unique_sorted.bed chr5_unique_sorted.bed \
    chr6_unique_sorted.bed chr7_unique_sorted.bed chr8_unique_sorted.bed chr9_unique_sorted.bed chr10_unique_sorted.bed \
    chr11_unique_sorted.bed chr12_unique_sorted.bed chr13_unique_sorted.bed chr14_unique_sorted.bed chr15_unique_sorted.bed \
    chr16_unique_sorted.bed chr17_unique_sorted.bed chr18_unique_sorted.bed chr19_unique_sorted.bed chr20_unique_sorted.bed \
    chr21_unique_sorted.bed chr22_unique_sorted.bed chrX_unique_sorted.bed chrY_unique_sorted.bed \
    > all_chromosomes_unique.bed

sort-bed all_chromosomes_unique.bed > all_chromosomes_unique_sorted.bed

#LINENUM=1490409334
#head -<$LINENUM + 10> all_chromosomes_sorted_unique.bed | tail -20 

bedGraphToBigWig all_chromosomes_unique_sorted.bed ../hg19.chrom.sizes ../cactus241way.phyloP.hg19.bw

#Oneliner
#bedops --partition <(sort-bed out.bdg.tmp | awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }') | bedmap --echo --mean --delim '\t' - <(sort-bed out.bdg.tmp | awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }') > answer.bedgraph

#LC_COLLATE=C sort -k1,1 -k2,2n -k3,3n -s out.bdg.tmp > out.bdg.sorted
#echo "bedGraphToBigWig"
#bedGraphToBigWig out.bdg.sorted hg19.chrom.sizes ${BIGWIG%%.*}".hg19.phyloP.bw"


#echo "bedGraphToBigWig"
#Error - overlapping regions in bedGraph line 199 of cactus241way.hg19.phyloP.sorted.bedGraph
#bedGraphToBigWig ${BIGWIG%%.*}".hg19.phyloP.sorted.bedGraph" hg19.chrom.sizes ${BIGWIG%%.*}".hg19.phyloP.bw"



#rm ${BIGWIG%%.*}.bedGraph
#rm ${BIGWIG%%.*}.hg19.bedGraph
#rm ${BIGWIG%%.*}.hg19.sorted.bedGraph



#For mouse 

#cd /scratch/project_2007567/phyloP_mm10

#fetchChromSizes mm39 > mm39.chrom.sizes

#BIGWIG=phylop.bw

#bigWigToBedGraph $BIGWIG ${BIGWIG%%.*}_mm10.bedGraph

# -bedPlus=N - File is bed N+ format (i.e. first N fields conform to bed format)
#liftOver -bedPlus=4 ${BIGWIG%%.*}_mm10.bedGraph $liftOver_chainfile_path"mm10ToMm39.over.chain" ${BIGWIG%%.*}_mm39.bedGraph unMapped.${BIGWIG%%.*}"_mm10" 

#or use bedSort
#sort -k1,1 -k2,2n ${BIGWIG%%.*}_mm39.bedGraph > ${BIGWIG%%.*}_mm39.sorted.bedGraph

#bedGraphToBigWig ${BIGWIG%%.*}_mm39.sorted.bedGraph mm39.chrom.sizes ${BIGWIG%%.*}_mm39.bw

#rm ${BIGWIG%%.*}_mm10.bedGraph
#rm ${BIGWIG%%.*}_mm39.bedGraph
#rm ${BIGWIG%%.*}_mm39.sorted.bedGraph
