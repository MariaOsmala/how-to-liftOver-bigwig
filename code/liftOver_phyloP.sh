#!/bin/bash
#SBATCH --job-name=liftOver_phyloP
#SBATCH --output=outs/liftOver_phyloP.out
#SBATCH --error=errs/liftOver_phyloP.err
#SBATCH --account=project_2007567
#SBATCH --partition=small
#SBATCH --ntasks=1
#SBATCH --time=2-00:00:00
#SBATCH --mem-per-cpu=350G
#SBATCH --cpus-per-task=1

#22713485 

export PATH="/projappl/project_2007567/softwares/ucsc-tools:$PATH" 

liftOver_chainfile_path=/projappl/project_2006203/liftOver/
cd /scratch/project_2007567/phyloP

#fetchChromSizes hg19 > hg19.chrom.sizes

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

#Then we need to combine these, THE SORTING ABOVE DOES NOT REALLY HELP AS LIFTOVER MAPS THE REGIONS ALSO TO OTHER CHROMOSOMES
#echo "${BIGWIG%%.*}"

#echo "concatenate bedGraphs"
#cat ${BIGWIG%%.*}".chr1".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr2".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr3".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr4".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr5".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr6".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr7".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr8".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr9".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr10".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr11".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr12".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr13".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr14".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr15".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr16".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr17".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr18".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr19".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr20".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr21".hg19.sorted.bedGraph ${BIGWIG%%.*}".chr22".hg19.sorted.bedGraph ${BIGWIG%%.*}".chrX".hg19.sorted.bedGraph ${BIGWIG%%.*}".chrY.hg19.sorted.bedGraph" > ${BIGWIG%%.*}".hg19.phyloP.bedGraph"


#echo "sort the final bedGraph"
#Error - overlapping regions in bedGraph line 60 of cactus241way.hg19.phyloP.sorted.bedGraph
#sort -k1,1 -k2,2n ${BIGWIG%%.*}".hg19.phyloP.bedGraph" | uniq > ${BIGWIG%%.*}".hg19.phyloP.sorted.bedGraph" #This worked

#echo "${BIGWIG%%.*}"

#echo "bigWigToBedGraph"
#bigWigToBedGraph $BIGWIG ${BIGWIG%%.*}.bedGraph #DONE

# -bedPlus=N - File is bed N+ format (i.e. first N fields conform to bed format)
#echo "liftOver"
#liftOver -bedPlus=4 ${BIGWIG%%.*}.bedGraph $liftOver_chainfile_path"hg38ToHg19.over.chain" ${BIGWIG%%.*}.hg19.bedGraph unMapped.${BIGWIG%%.*} #DONE

#for which chromosomes there is data

#grep -o "chr[^ ]*" ${BIGWIG%%.*}.hg19.bedGraph | cut -d '=' -f 2 | sort | uniq

#cut -d $'\t' -f 1 ${BIGWIG%%.*}.hg19.bedGraph | sort | uniq

#awk '{print $1}' ${BIGWIG%%.*}.hg19.bedGraph | sort | uniq


#Separate the data into different files by chromosome
#awk '{print > $1""${BIGWIG%%.*}.hg19.bedGraph}' ${BIGWIG%%.*}.hg19.bedGraph


#bedSort
#echo "sort"
#sort -k1,1 -k2,2n ${BIGWIG%%.*}.hg19.bedGraph > ${BIGWIG%%.*}.hg19.sorted.bedGraph
#bedSort ${BIGWIG%%.*}.hg19.bedGraph ${BIGWIG%%.*}.hg19.sorted.bedGraph

echo "resolve overlapping entries"
module load biokit
#echo "sort"
#LC_COLLATE=C sort -k1,1 -k2,2n -k3,3n -s ${BIGWIG%%.*}".hg19.phyloP.sorted.bedGraph" > out.bdg.tmp
echo "bedtools"

#echo "Find the overlapping intervals"
#bedtools intersect -a out.bdg.tmp -b out.bdg.tmp -wa -wb > overlaps.bedGraph

#bedtools merge -i out.bdg.tmp -c 4 -o absmin > out.bdg #-c 4 -d 0
#echo "sort again"

#Convert to bed
#awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }' out.bdg.tmp | sort-bed - > out.bed
#cat out.bed

#The disjoint set from these intervals would look like this:

#bedops --partition out.bed

#We can pipe these intervals to bedmap --mean with the original five-column BED file as a "map" file, calculating the mean signal over the disjoint intervals:

#bedops --partition out.bed | bedmap --echo --mean --delim '\t' - out.bed > /tmp/answer.bedgraph
#cat answer.bedgraph

#Oneliner
#bedops --partition <(sort-bed out.bdg.tmp | awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }') | bedmap --echo --mean --delim '\t' - <(sort-bed out.bdg.tmp | awk -vOFS="\t" '{ print $1, $2, $3, ".", $4 }') > answer.bedgraph

LC_COLLATE=C sort -k1,1 -k2,2n -k3,3n -s out.bdg.tmp > out.bdg.sorted
echo "bedGraphToBigWig"
bedGraphToBigWig out.bdg.sorted hg19.chrom.sizes ${BIGWIG%%.*}".hg19.phyloP.bw"


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
