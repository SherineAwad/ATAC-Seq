configfile: "config.yaml"

with open(config['REPLICATE1']) as fp:
    REPLICATE1= fp.read().splitlines()
with open(config['REPLICATE2']) as fp:
    REPLICATE2 = fp.read().splitlines()

print(REPLICATE1)
print(REPLICATE2)

rule all: 
    input:
        expand("{sample}.sam", sample = REPLICATE1), 
        expand("{sample}.bam", sample = REPLICATE1), 
        expand("{sample}.sorted.bam", sample = REPLICATE1),    
        expand("{sample}.sam", sample = REPLICATE2),
        expand("{sample}.bam", sample = REPLICATE2),
        expand("{sample}.sorted.bam", sample = REPLICATE2), 
        expand("{replicate}.narrowPeak", replicate = config['REPLICATE1_NAME']), 
        expand("{replicate}.narrowPeak", replicate = config['REPLICATE2_NAME'])

if config['PAIRED']:
    rule trim: 
       input: 
          r1 = "{sample}.r_1.fq.gz",
          r2 = "{sample}.r_2.fq.gz"
       output: 
          val1 = "galore/{sample}.r_1_val_1.fq.gz",
          val2 = "galore/{sample}.r_2_val_2.fq.gz"
       conda: 'env/env-trim.yaml'
       log: 
           "{sample}.trim.log"
       shell: 
         """
         trim_galore --gzip --retain_unpaired --trim1 --fastqc --fastqc_args "--outdir fastqc" -o galore --paired {input.r1} {input.r2}
         """

    rule tosam:
       input:
          r1 = "galore/{sample}.r_1_val_1.fq.gz",
          r2 = "galore/{sample}.r_2_val_2.fq.gz"
       params:
          genome = config['GENOME']
       output:
          "{sample}.sam"
       conda: 'env/env-align.yaml'
       log: 
           "{sample}.sam.log"
       shell:
           "bowtie2 -x {params} -1 {input.r1} -2 {input.r2} -S {output}"
else: 
     rule trim:
       input:
           "{sample}.fq.gz",
       output:
           "galore/{sample}_trimmed.fq.gz",
       conda: 'env/env-trim.yaml'
       log:
           "{sample}.trim.log"
       shell:
           """
           mkdir -p galore
           mkdir -p fastqc
           trim_galore --gzip --retain_unpaired --trim1 --fastqc --fastqc_args "--outdir fastqc" -o galore {input}
           """
     rule tosam: 
        input:
           "galore/{sample}_trimmed.fq.gz"
        params:
           genome = config['GENOME']
        conda: 'env/env-align.yaml'
        log:
           "{sample}.sam.log" 
        output:
           "{sample}.sam"
        shell:
           "bowtie2 -x {params.genome} -U {input} -S {output}"

rule tobam:
      input:
          "{sample}.sam"
      output:
          "{sample}.bam"
      conda: 'env/env-align.yaml'
      log: 
          "{sample}.bam.log"
      shell:
          "samtools view {input[0]} -S -b > {output[0]}"

rule sort:
    input: 
       "{sample}.bam"
    output:
       "{sample}.sorted.bam" 
    params: 
        "{sample}.tmp.sorted"
    conda: 'env/env-align.yaml'
    log: 
        "{sample}.sorted.log" 
    shell: 
       "samtools sort -T {params} -n -o {output} {input}"

rule peak_call:
    input: 
        expand("{sample}.sorted.bam", sample = REPLICATE1), 
        expand("{sample}.sorted.bam", sample = REPLICATE2)
    params:
       lambda w: ",".join(expand("{sample}.sorted.bam", sample = REPLICATE1)), 
       lambda w: ",".join(expand("{sample}.sorted.bam", sample = REPLICATE2)),
       expand("{chr}", chr=config['CHR']),
       expand("{file}.bed", file = config['REPLICATE1_NAME']),
       expand("{file}.bed", file = config['REPLICATE2_NAME']),
       expand("{qv}", qv = config['QV']),
       expand("{auc}", auc = config['AUC']),
       expand("{length}", length = config['LEN'])
    output: 
       expand("{replicate}.narrowPeak", replicate = config['REPLICATE1_NAME']), 
       expand("{replicate}.narrowPeak", replicate = config['REPLICATE2_NAME'])
    conda: 'env/env-peakcall.yaml'
    shell:
       """
       Genrich -t {params[0]} -o {output[0]} -b {params[3]} -r -j -v -e {params[2]}  -q {params[5]} -a {params[6]} -l {params[7]}
       Genrich -t {params[1]} -o {output[1]} -b {params[4]} -r -j -v -e {params[2]}  -q {params[5]} -a {params[6]} -l {params[7]}
       bedtools intersect -a {params[3]} -b {params[4]} > intersect.out 
       bedtools subtract -a  {params[3]} -b {params[4]} > subtract.out 
       """  
