##Annovar对Variants进行功能注释

#PBS -N snp_annovar
#PBS -l nodes=1:ppn=4
#PBS -l walltime=480:00:00
#PBS -q batch
#PBS -V
#PBS -S /bin/bash


cd /data01/wangyf/project2/CyprinusCarpio/15.pop/7.annovar/

step 1：
#用自己的参考基因组构建数据库
#mv GWHAATB00000000.genome.fasta genome.fa
#mv GWHAATB00000000.gff genome.gff
#/data01/wangyf/software/gffread/gffread genome.gff -T -o genome.gtf
#/data01/wangyf/software/gtfToGenePred -genePredExt genome.gtf genome_refGene.txt

#retrieve_seq_from_fasta.pl --format refGene --seqfile genome.fa genome_refGene.txt --out genome_refGeneMrna.fa
#NOTICE: Reading region file genome_refGene.txt ... Done with 99698 regions from 758 chromosomes
#WARNING: 1595 gene regions do not have complete ORF (for example, rna-XM_019077247.2NC_056616.1:23660168, rna-XM_019104580.2NC_056601.1:20854380, rna-XM_042745688.1NC_056615.1:1299586, rna-XM_042734886.1NC_056608.1:636308, rna-XM_042715474.1NC_056596.1:11008385)

#mkdir genome
#cp genome* genome

#格式转换
convert2annovar.pl -format vcf4 -allsample -withfreq /data01/wangyf/project2/CyprinusCarpio/15.pop/0.vcfdata/final-raw.indel5.biSNP.QUAL30.QD3.FS20.MQ55.SOR3.MQRS-5.RPRS-5.PASS.GQ10.popmiss.maxmiss0.15.AF0.05.10-3ClusterFilter.vcf.gz > final.vcf.avinput
#NOTICE: Finished reading 2144591 lines from VCF file
#NOTICE: A total of 2137842 locus in VCF file passed QC threshold, representing 2137842 SNPs (1191766 transitions and 946076 transversions) and 0 indels/substitutions
#NOTICE: Finished writing allele frequencies based on 320676300 SNP genotypes (178764900 transitions and 141911400 transversions) and 0 indels/substitutions for 150 samples

#注释
annotate_variation.pl -geneanno -dbtype refGene -outfile anno -buildver genome final.vcf.avinput ./genome
#-geneanno 通过基于基因的注释注释变体(推断基因的功能后果)
#-dbtype 指定数据库类型
#-outfile 指定输出文件前缀
#-buildver 指定数据库
#NOTICE: Output files are written to anno.variant_function, anno.exonic_variant_function
#NOTICE: Reading gene annotation from genome/genome_refGene.txt ... Done with 99698 transcripts (including 18711 without coding sequence annotation) for 53440 unique genes
#NOTICE: Processing next batch with 2137842 unique variants in 2137842 input lines
#NOTICE: Finished analyzing 1000000 query variants
#NOTICE: Finished analyzing 2000000 query variants
#NOTICE: Reading FASTA sequences from genome/genome_refGeneMrna.fa ... Done with 46670 sequences
#WARNING: A total of 1595 sequences will be ignored due to lack of correct ORF annotation

##结果解读，生成2个文件
在variant_function文件中，注释所有变异所在基因及位置。第1列为变异所在的类型，如外显子等，第2列是对应的基因名(若有多个基因名用“，”隔开)
在exonic_variant_function文件中，详细注释外显子区域的变异功能、类型、氨基酸改变等。第1列为.variant_function文件中该变异所在行号，第2列为变异功能性后果，如外显子改变导致的氨基酸变化，阅读框移码，无义突变，终止突变等，第3列包括基因名称、转录识别标志和相应的转录本的序列变化
## 为方便了解每一列的含义，只输出第一行，然后把制表符改成换行符
cat anno.exonic_variant_function | head -n 1 | tr '\t' '\n'
##查看有多少种gene variant
cat anno.exonic_variant_function |cut -f2|cut -d" " -f1|sort |uniq -c |sort -nr

  63220 synonymous
  36036 nonsynonymous
  15476 unknown
    268 stopgain
     40 stoploss
	 
step 2：
#对sliding window的范围进行提取，从annovar的结果文件匹配出在该范围内的基因

#读取判断单系后输出的*.info.range文件，将染色体、起始位点、终止位点保存到变量chr、start、end中
#$i为/data01/wangyf/project2/CyprinusCarpio/15.pop/4.slide-window/6.newick/dir1-100/output.txt中的组成一个单>系的样本数，按照实际情况自己设置
#在该目录下运行
cd /data01/wangyf/project2/CyprinusCarpio/15.pop/7.annovar
i=6; while read -r line; do
    chr=$(echo $line | cut -d':' -f1)
    start=$(echo $line | cut -d':' -f2 | cut -d'-' -f1)
    end=$(echo $line | cut -d':' -f2 | cut -d'-' -f2)
        #用3个变量去anno.variant_function文件中进行匹配，保存到文件中
        awk -v chr="$chr" -v start="$start" -v end="$end" '$3 == chr && $4 >= start && $4 <= end' anno.variant_function >> 1.window-gene/$i.gene
done < /data01/wangyf/project2/CyprinusCarpio/15.pop/4.slide-window/6.newick/window500-dir1-3/mergerange/$i.info.range

