.mismatches_as_IntegerList <- function(mismatches)
{
    arr_ind <- which(mismatches != 0, arr.ind=TRUE)
    ind_row <- unname(arr_ind[ , "row"])
    ind_col <- unname(arr_ind[ , "col"])
    oo <- S4Vectors::orderIntegerPairs(ind_row, ind_col)
    ind_row <- ind_row[oo]
    ind_col <- ind_col[oo]
    partitioning <- PartitioningByEnd(ind_row, NG=nrow(mismatches))
    relist(ind_col, partitioning)
}

#' @importFrom Biostrings DNAStringSet isMatchingAt substring extractAt complement RNAStringSet DNAString replaceAt
#' @importFrom BiocGenerics grep sort relist rep.int cbind
#' @importFrom IRanges IRangesList PartitioningByEnd 
#' @importFrom S4Vectors unstrsplit orderIntegerPairs elementNROWS
#' @importFrom methods as
#' @importFrom DelayedArray mean


buildFeatureVectorForScoring2 <-
    function(hits, gRNA.size = 20, 
    canonical.PAM = "NGG",
     PAM.size = 3, PAM.location = "3prime")
{
    #hits = read.table(hitsFile, sep = "\t", header=TRUE,
    # stringsAsFactors = FALSE)
    if (dim(hits)[1] == 0)
    {
        stop("Empty hits!")
    }
    subject <- DNAStringSet(as.character(hits$OffTargetSequence))
    if (PAM.location == "3prime")
        isCanonical.PAM <- as.numeric(isMatchingAt(canonical.PAM, subject, 
            at = (gRNA.size + 1), fixed = FALSE))
    else
        isCanonical.PAM <- as.numeric(isMatchingAt(canonical.PAM, subject,
            at =  1, fixed = FALSE))
    PAM <- substring(subject, gRNA.size+2)
    mismatches = hits[, grep("IsMismatch.pos", colnames(hits))]
    mismatch_pos <- .mismatches_as_IntegerList(mismatches)
    #d.nucleotide is the nucleotide that will hybridize to the gRNA
    ### reverse complement of the offtarget sequence
    #r.nucleotide is the gRNA sequence,except T is converted to U)

    at <- IRangesList(start=mismatch_pos, end=mismatch_pos)

    d.nucleotide <- extractAt(complement(subject), at)
    r.nucleotide <- unlist(extractAt(DNAStringSet(hits$gRNAPlusPAM), at))
    r.nucleotide[r.nucleotide == "T"] <- "U"
    d.nu.r.nu <- paste("r", r.nucleotide, ":d", 
       unlist(d.nucleotide), sep="")
    #### need to assign d.nu.r.nu to the right hits
    arr_ind <- which(mismatches != 0, arr.ind=TRUE)
    ind_row <- sort(unname(arr_ind[ , "row"]))
    partitioning <- PartitioningByEnd(ind_row, NG=nrow(mismatches))
    d.nu.r.nu.2 <- relist(d.nu.r.nu, partitioning)
    d.nu.r.nu <- unstrsplit(as(d.nu.r.nu.2,
                   "CharacterList"), sep = ",")

    mismatch.distance2PAM <- gRNA.size + 1L - mismatch_pos
    mismatch.distance2PAM <- unstrsplit(as(mismatch.distance2PAM,
                               "CharacterList"), sep = ",")

    alignment <- rep.int(DNAString("."), gRNA.size)
    alignment <- rep.int(DNAStringSet(alignment), nrow(hits))
    alignment <- as.character(replaceAt(alignment, at, extractAt(subject, at)))

    mean.neighbor.distance.mismatch <- mean(diff(mismatch_pos))
    no_neighbor_idx <- elementNROWS(mismatch_pos) <= 1L
    mean.neighbor.distance.mismatch[no_neighbor_idx] <- gRNA.size

    features <- cbind(mismatch.distance2PAM, alignment, isCanonical.PAM,
        mean.neighbor.distance.mismatch, d.nu.r.nu, PAM)
    colnames(features) <- c("mismatch.distance2PAM", "alignment", "NGG", 
        "mean.neighbor.distance.mismatch", "mismatch.type", "subPAM")
    cbind(hits, features)
}
