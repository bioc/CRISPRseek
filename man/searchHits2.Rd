% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/searchHits2.R
\name{searchHits2}
\alias{searchHits2}
\title{Search for off targets}
\usage{
searchHits2(
  gRNAs,
  BSgenomeName,
  chromToSearch = "all",
  chromToExclude = "",
  max.mismatch = 3,
  PAM.size = 3,
  gRNA.size = 20,
  PAM = "NGG",
  PAM.pattern = "N[A|G]G$",
  allowed.mismatch.PAM = 1,
  PAM.location = "3prime",
  baseEditing = FALSE,
  targetBase = "C",
  editingWindow = 4:8
)
}
\arguments{
\item{gRNAs}{DNAStringSet object containing a set of gRNAs. Please note the
sequences must contain PAM appended after gRNAs, e.g.,
ATCGAAATTCGAGCCAATCCCGG where ATCGAAATTCGAGCCAATCC is the gRNA and CGG is
the PAM}

\item{BSgenomeName}{BSgenome object. Please refer to available.genomes in
BSgenome package. For example,
\itemize{
\item{BSgenome.Hsapiens.UCSC.hg19} - for hg19,
\item{BSgenome.Mmusculus.UCSC.mm10} - for mm10
\item{BSgenome.Celegans.UCSC.ce6} - for ce6
\item{BSgenome.Rnorvegicus.UCSC.rn5} - for rn5
\item{BSgenome.Drerio.UCSC.danRer7} - for Zv9
\item{BSgenome.Dmelanogaster.UCSC.dm3} - for dm3
}}

\item{chromToSearch}{Specify the chromosome to search, default to all,
meaning search all chromosomes. For example, chrX indicates searching for
matching in chromosome X only}

\item{chromToExclude}{Specify the chromosome not to search, default to none,
meaning to search chromosomes specified by chromToSearch. For example, to
exclude haplotype blocks from offtarget search in hg19, set chromToExclude
to c(""chr17_ctg5_hap1","chr4_ctg9_hap1", "chr6_apd_hap1", "chr6_cox_hap2",
"chr6_dbb_hap3", "chr6_mann_hap4", "chr6_mcf_hap5","chr6_qbl_hap6",
"chr6_ssto_hap7")}

\item{max.mismatch}{Maximum mismatch allowed in off target search, default
3. Warning: will be considerably slower if it is set to greater than 3}

\item{PAM.size}{Size of PAM, default 3}

\item{gRNA.size}{Size of gRNA, default 20}

\item{PAM}{Regular expression of protospacer-adjacent motif (PAM), default
NGG for spCas9. For cpf1, ^TTTN}

\item{PAM.pattern}{Regular expression of PAM, default N[A|G]G$ for spCas9.
For cpf1, ^TTTN since it is a 5 prime PAM sequence}

\item{allowed.mismatch.PAM}{Number of degenerative bases in the PAM
sequence, default to 1 for N[A|G]G PAM}

\item{PAM.location}{PAM location relative to gRNA. For example, spCas9 PAM
is located on the 3 prime while cpf1 PAM is located on the 5 prime}

\item{baseEditing}{Indicate whether to design gRNAs for base editing.
Default to FALSE If TRUE, please set baseEditing = TRUE, targetBase and
editingWidow accordingly.}

\item{targetBase}{Applicable only when baseEditing is set to TRUE. It is
used to indicate the target base for base editing systems, default to C for
converting C to T in the CBE system. Please change it to A if you intend to
use the ABE system.}

\item{editingWindow}{Applicable only when baseEditing is set to TRUE. It is
used to indicate the effective editing window to consider for the offtargets
search only, default to 4 to 8 which is for the original CBE system. Please
change it accordingly if the system you use have a different editing window,
or you would like to include offtargets with the target base in a larger
editing window.}
}
\value{
a data frame contains 
\itemize{
\item{IsMismatch.posX} - {indicator variable indicating
whether this position X is mismatch or not, (1 means yes and 0 means not). X takes on values from 1 to gRNA.size, 
representing all positions in the guide RNA (gRNA). }
\item{strand} - {strand of
the match, + for plus and - for minus strand}
\item{chrom} - {chromosome of the off
target}
\item{chromStart} - {start position of the off target}
\item{chromEnd} - {end
position of the off target}
\item{name} - {gRNA name}
\item{gRNAPlusPAM} - {gRNA sequence
with PAM sequence concatenated}
\item{OffTargetSequence} - {the genomic sequence of
the off target}
\item{n.mismatch} - {number of mismatches between the off target and
the gRNA}
\item{forViewInUCSC} - {string for viewing in UCSC genome browser, e.g.,
chr14:31665685-31665707}
\item{score} - {set to 100, and will be updated in
getOfftargetScore}
}
}
\description{
Search for off targets for given gRNAs, BSgenome and maximum mismatches
}
\details{
%% ~~ If necessary, more details than the description above ~~
}
\note{
%% ~~further notes~~
}
\examples{

    all.gRNAs <- findgRNAs(inputFilePath = 
        system.file("extdata", "inputseq.fa", package = "CRISPRseek"),
        pairOutputFile = "pairedgRNAs.xls",
	findPairedgRNAOnly = TRUE)

    library("BSgenome.Hsapiens.UCSC.hg19")
    ### for speed reason, use max.mismatch = 0 for finding all targets with 
    ### all variants of PAM
    hits <- searchHits2(all.gRNAs[1], BSgenomeName = Hsapiens,
        max.mismatch = 0, chromToSearch = "chrX")
    colnames(hits)

    ### test PAM located at 5 prime
    all.gRNAs <- findgRNAs(inputFilePath = 
             system.file("extdata", "inputseq.fa", package = "CRISPRseek"),
             pairOutputFile = "pairedgRNAs.xls",
             findPairedgRNAOnly = FALSE,
             PAM = "TGT", PAM.location = "5prime")
     
    library("BSgenome.Hsapiens.UCSC.hg19")
         ### for speed reason, use max.mismatch = 0 for finding all targets with 
         ### all variants of PAM
    hits <- searchHits2(all.gRNAs[1], BSgenomeName = Hsapiens, PAM.size = 3,
        max.mismatch = 0, chromToSearch = "chrX", PAM.location = "5prime",
        PAM = "NGG", 
        PAM.pattern = "^T[A|G]N", allowed.mismatch.PAM = 2)
    colnames(hits)
}
\references{
%% ~put references to the literature/web site here ~
}
\seealso{
offTargetAnalysis
}
\author{
Lihua Julie Zhu
}
\keyword{misc}
