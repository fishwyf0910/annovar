##Annovar对Variants进行功能注释

step 1：
#用自己的参考基因组构建数据库
/data01/wangyf/software/gffread/gffread genome.gff -T -o genome.gtf
/data01/wangyf/software/gtfToGenePred -genePredExt genome.gtf genome_refGene.txt
/data01/wangyf/software/annovar/retrieve_seq_from_fasta.pl --format refGene --seqfile genome.fa genome_refGene.txt --out genome_refGeneMrna.fa

mkdir genome
cp genome* genome

#格式转换
/data01/wangyf/software/annovar/convert2annovar.pl -format vcf4 -allsample \
  -withfreq /data01/wangyf/project2/CyprinusCarpio/15.pop/0.vcfdata/final-raw.indel5.biSNP.QUAL30.QD3.FS20.MQ55.SOR3.MQRS-5.RPRS-5.PASS.GQ10.popmiss.maxmiss0.15.AF0.05.10-3ClusterFilter.vcf.gz > final.vcf.avinput

/data01/wangyf/software/annovar/annotate_variation.pl -geneanno -dbtype refGene -outfile anno -buildver genome final.vcf.avinput ./genome --aamatrix /data01/wangyf/software/annovar/example/grantham.matrix
#-geneanno 通过基于基因的注释注释变体(推断基因的功能后果)
#-dbtype 指定数据库类型
#-outfile 指定输出文件前缀
#-buildver 指定数据库
#--aamatrix 指定一个氨基酸替换矩阵文件。有害突变（deleterious）：错义突变且Grantham Score >= 150。

##结果解读，生成2个文件
在variant_function文件中，注释所有变异所在基因及位置。第1列为变异所在的类型，如外显子等，第2列是对应的基因名(若有多个基因名用“，”隔开)
在exonic_variant_function文件中，详细注释外显子区域的变异功能、类型、氨基酸改变等。第1列为.variant_function文件中该变异所在行号，第2列为变异功能性后果，如外显子改变导致的氨基酸变化，阅读框移码，无义突变，终止突变等，第3列包括基因名称、转录识别标志和相应的转录本的序列变化

