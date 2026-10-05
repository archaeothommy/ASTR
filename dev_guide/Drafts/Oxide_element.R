
# Goals of the oxide_conversion function: 

# convert element compositions to oxides and vice versa
# be able to select which oxide to convert to depending on material (optional, set a default list)
# be able to normalize the data after conversion, for elements to oxides and oxide to elements (optional)
# be able to select what elements get converted to oxides: 
#         ("major" = (wt%>1), "minor" = (wt% > 0.1), "all")


#requirements:
#select only compositional data
#if normalised, need to convert all units to % or wt% prior to normalisation
##normalisation equation: 
##normalised_oxide_or_element = ([oxide_or_element_composition]*100)/(sum of (all_element_or_oxides_to_be_normalised)
#if only converting oxides at the major or minor threshold, will need special handling of the normalisation 


conversion_table <- read.csv("oxide_conversion.csv", stringsAsFactors = FALSE)

default_oxides <- c(
  "H2O","LiO2","BeO","B2O3","CO2","N2O5","Na2O","MgO","Al2O3","SiO2","P2O5","SO3",
  "K2O","CaO","Sc2O3","TiO2","V2O5","Cr2O3","MnO","FeO","CoO","NiO","CuO","ZnO","Ga2O3",
  "GeO2","As2O3","SeO2","Rb2O","SrO","Y2O3","ZrO2","MoO3","Ru2O3","Rh2O3",
  "PdO","Ag2O","CdO","SnO2","Sb2O3","TeO2","BaO","La2O3","CeO2",
  "Pm2O3","Sm2O3","Gd2O3","Tb2O3","Ho2O3","Er2O3","Tm2O3","Yb2O3","Lu2O3",
  "HfO2","Ta2O5","WO3","Re2O7","OsO4","HgO","Tl2O3","PbO","Bi2O3","UO3"
)

df <- read.csv("test.csv", stringsAsFactors = FALSE)

clean_df <- df
cols <- grep("_(wt%|%|ppm|ppb)$", names(clean_df), value = TRUE)


for (nm in cols) {
  x <- as.character(clean_df[[nm]])
  x[grepl("lod", x, ignore.case = TRUE)] <- NA  # turn "<LOD" (any case) into NA
  clean_df[[nm]] <- suppressWarnings(as.numeric(x))
  clean_df[[nm]] <- clean_df[[nm]] / 10000 
}

names(clean_df) <- sub("_(wt%|%|ppm|ppb)$", "", names(clean_df))



pick_elements_to_convert <- function(x, mode = c("all","major","minor")) {
  mode <- match.arg(mode)
  keep <- rep(TRUE, length(x))
  if (mode == "major") keep <- x > 1
  if (mode == "minor") keep <- x > 0.1
  keep
}

make_element_to_oxide_map <- function(conversion_table, preferred_oxides = default_oxides) {
  ct <- conversion_table[conversion_table$Oxide %in% preferred_oxides, ]
  ct$rank <- match(ct$Oxide, preferred_oxides)
  ct <- ct[order(ct$rank), ]
  ct <- ct[!duplicated(ct$Element), ]     
  rownames(ct) <- ct$Element
  ct
}

elements_to_oxides <- function(df,
                               conversion_table,
                               preferred_oxides = default_oxides,
                               which_elements = c("all","major","minor"),
                               normalize = FALSE) {
  
  which_elements <- match.arg(which_elements)
  
  ## (a) keep only element columns that exist in df
  elem_cols <- intersect(names(df), elements)
  if (!length(elem_cols)) stop("No element columns found in df.")
  
  ## (b) build mapping + keep only elements we can map
  map <- make_element_to_oxide_map(conversion_table, preferred_oxides)
  have_map <- elem_cols %in% rownames(map)
  if (!all(have_map)) {
    warning("No oxide mapping for: ", paste(elem_cols[!have_map], collapse = ", "))
  }
  elem_cols <- elem_cols[have_map]
  if (!length(elem_cols)) stop("No mappable element columns found.")
  
  ## (c) numeric matrix of selected elements
  X <- as.matrix(df[elem_cols])
  storage.mode(X) <- "double"
  
  ## (d) multiply by element->oxide factors
  factors <- as.numeric(map[elem_cols, "element_to_oxide"])
  XO <- sweep(X, 2, factors, "*")
  colnames(XO) <- map[elem_cols, "Oxide"]
  
  ## (e) thresholds (per row) if "major" (>1) or "minor" (>0.1)
  if (which_elements != "all") {
    thr <- if (which_elements == "major") 1 else 0.1
    XO[X <= thr] <- NA_real_          # only convert values above the threshold
  }
  
  ## (f) collapse duplicate oxide names (e.g., if multiple elements mapped to same oxide choice)
  ox_names <- colnames(XO)
  if (any(duplicated(ox_names))) {
    unq <- unique(ox_names)
    agg <- matrix(0, nrow = nrow(XO), ncol = length(unq))
    for (i in seq_along(unq)) {
      j <- which(ox_names == unq[i])
      agg[, i] <- rowSums(XO[, j, drop = FALSE], na.rm = TRUE)
    }
    XO <- agg
    colnames(XO) <- unq
  }
  
  ## (g) build output: drop converted element cols, add oxide cols
  out <- df
  out[elem_cols] <- NULL
  for (j in seq_len(ncol(XO))) out[[colnames(XO)[j]]] <- XO[, j]
  
  ## (h) optional normalization over the converted oxide set
  if (normalize) {
    sel <- colnames(XO)
    s <- rowSums(out[sel], na.rm = TRUE)
    for (nm in sel) out[[nm]] <- (out[[nm]] * 100) / s
  }
  
  out
}

ox_df <- elements_to_oxides(clean_df, conversion_table,
                                 preferred_oxides = default_oxides,
                                 which_elements = "all",
                                 normalize = FALSE)

ox_df_norm <- elements_to_oxides(clean_df, conversion_table,
                            preferred_oxides = default_oxides,
                            which_elements = "major",
                            normalize = TRUE)

## this works, but it is not optimised in any sense, and not set to work directly
## with the data yet -- all tbd
