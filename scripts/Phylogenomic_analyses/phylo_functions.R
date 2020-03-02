
#################################################
## Functions
#################################################

#' Get the taxonomic levels of each node in the tree
#'
#' @param tree     Object of type 'phylo'
#' @param taxonomy Two-column data.frame. First column is the genome name, which
#'                 must match the corresponding leaf in tree$tip.label. Second
#'                 column is the Greengenes-like lineage string with form:
#'                 'd__domain;p__phylum;c__class;o__order;f__family;g__genus;s__species'
#'
#' @import phangorn tibble
#' @return
tax_levels.tree <- function(tree, taxonomy) {
  taxonomy.filt <- taxonomy[match(tree$tip.label, taxonomy$genome), ]
  parsed_ranks <-
    data.frame(t(sapply(taxonomy.filt[ ,2],
                        function(s){
                          ranks <- strsplit(as.character(s), split = ";")[[1]]
                          return(sapply(ranks, function(rank) {
                            strsplit(rank, split = "__")[[1]][2]}))
                        })))
  colnames(parsed_ranks) <- c("domain", "phylum", "class", "order", "family",
                              "genus", "species")
  taxonomy.parsed <- cbind(taxonomy.filt, parsed_ranks)

  mrca_lineages <- as.data.frame(t(
    sapply(1:tree$Nnode, function(internal_node_idx) {
      overall_node_idx <- length(tree$tip.label) + internal_node_idx
      node_tips.idx <- unlist(phangorn::Descendants(tree, overall_node_idx, type = "tips"))
      node_tips.labels <- tree$tip.label[node_tips.idx]
      tip_lineages <- taxonomy.parsed[match(node_tips.labels, taxonomy.parsed$genome),
                                      3:ncol(taxonomy.parsed)]
      mrca_lineage <- apply(tip_lineages, 2, function(ranks) {
        if(all(ranks[1] == ranks, na.rm = TRUE)) {
          return(ranks[1])
        } else {
          return(NA)
        }
      })
      return(mrca_lineage)
    })
  ))
  mrca_lineages <- tibble::rownames_to_column(mrca_lineages, var = "node_index")

  return(mrca_lineages)
}

# Converts a ordered, named vector of taxonomic ranks to a Greengene-like
# lineage string. The names are the taxonomic level
vector2lineage_string <- function(ranks) {
  ranks.noNA <- ranks[!is.na(ranks)]
  prefixes <- sapply(names(ranks.noNA), function(tax_level) {
    return(substr(tax_level, 1, 1))
  })
  lineage_string <- paste(prefixes, ranks.noNA, sep = "__", collapse = ";")
  return(lineage_string)
}

# Calculate the F1 score
F1 <- function(precision, sensitivity) {
  return(2 * (precision * sensitivity) / (precision + sensitivity))
}

# Calculate the F1 score for a particular phylogenetic node. This function is
# split from F1 to clearly demonstrate how binary classification in a
# phylogenetic context relates to statistical binary classification
f1score.node <- function(n_present_tips.node, n_present_tips.phylo, ntips.node, reduced = TRUE) {
  precision <- n_present_tips.node / ntips.node
  sensitivity <- n_present_tips.node / n_present_tips.phylo

  if(reduced) {
    return(F1(precision, sensitivity))
  } else {
    return(c("n_present_tips.node" = n_present_tips.node,
             "n_present_tips.phylo" = n_present_tips.phylo,
             "precision"= precision, "sensitivity" = sensitivity,
             "f1_score" = F1(precision, sensitivity)))
  }
}

#' Calculate the F1 scores for all nodes on the tree using the given trait
#' distribution
#'
#' @param trait_profile Vector with '1' to indicate presence and '0' to indicate
#'                      absence of a trait for tips in the same order as
#'                      tree$tip.labels
#' @param tree          Object of type 'phylo'
#' @param reduced       TRUE or FALSE, indicating whether scores for all nodes
#'                      or just the maximum one will be returned (default = TRUE)
#' @param tip_ancestors List of vectors indicating the node IDs of all ancestors
#'                      of the tip within tree$tip.label at the same list index.
#'                      This argument is optional
#'
#' @import ape phangorn tibble
#' @return              Either a list with node_index, precision, sensitivity,
#'                      and f1_score for the node with the greatest F1 score or
#'                      a data.frame with those values for all nodes
f1score.trait <- function(trait_profile, tree, reduced = TRUE, tip_ancestors, states) {
  ntips.phylo <- ape::Ntip(tree)
  trait_profile <- states[,trait_profile]
  names(trait_profile) <- rownames(states)
  n_present_tips.nodes <- rep(0, tree$Nnode)
  present_state_indices <- which(trait_profile == 1)
  # present_state_indices refer to the index of the tip in tree$tip.label
  # Note that tips are labelled from 1 to ntips.phylo

  # For each tip with a present state, increase the present counter of all its
  # ancestral nodes by 1
  if(missing(tip_ancestors)) {
    ancestors <- sapply(present_state_indices,
                        function(tip_index) {
                          return(phangorn::Ancestors(tree, tip_index, type = "all"))
                        })
  } else {
    ancestors <- lapply(present_state_indices,
                        function(tip_index) {
                          return(tip_ancestors[[tip_index]])
                        })
  }

  sapply(ancestors, function(present_node_index){
    n_present_tips.nodes[present_node_index - ntips.phylo] <<-
      n_present_tips.nodes[present_node_index - ntips.phylo] + 1
  })

  ntips.nodes <- sapply(prop.part(tree), length)

  f1score.nodes <-
    lapply(1:tree$Nnode, function(i) {
      return(f1score.node(n_present_tips.node = n_present_tips.nodes[i],
                          n_present_tips.phylo = length(present_state_indices),
                          ntips.node = ntips.nodes[i],
                          reduced = FALSE))
    })
  f1score.nodes <- do.call(rbind, f1score.nodes)
  rownames(f1score.nodes) <- 1:tree$Nnode

  if(reduced) {
    max_f1score_row_idx <- as.integer(which.max(f1score.nodes[ ,"f1_score"]))
    max_f1_row <- f1score.nodes[max_f1score_row_idx, ]
    return(
      c(list("node_index" = max_f1score_row_idx), max_f1_row)
    )
  } else {
    f1score.nodes.df <- as.data.frame(f1score.nodes)
    f1score.nodes.df <- tibble::rownames_to_column(f1score.nodes.df,
                                                   var = "node_index")
    return(f1score.nodes.df)
  }
}
