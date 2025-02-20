#' Download sPlotOpen data and load into R
#'
#' `get_sPlot()` downloads sPlotOpen data from the iDiv Data Repository and
#' saves the downloaded tables to a local directory and/or loads them into R.
#'
#' @param dir Directory where sPlotOpen data will be saved after download. If
#'   `NULL`, data will not be saved on disk and only loaded into the R
#'   environment.
#' @param load If `TRUE` (the default), data will be loaded immediately into R.
#' @param tables A character vector. Names of tables to be downloaded. Options
#'   are (default is to download all):
#'  * `"header"`: plot-level information.
#'  * `"DT"`: a list of species and relative cover in each vegetation plot.
#'  * `"CWM_CWV"`: community-weighted means and variances for 18 traits.
#' @param metadata If `TRUE` (the default), metadata will be downloaded.
#'
#' @return If `load = TRUE`, returns a named list containing the downloaded
#'   tables as tibbles.
#' @export
#'
#' @examples
#' \dontrun{
#' # Download all sPlot tables, load into R, and save to local directory
#' db <- get_sPlot(dir = tempdir())
#' }
get_sPlot <- function(dir = "~/sPlotOpen/data",
                      tables = c("header", "DT", "CWM_CWV"),
                      metadata = TRUE,
                      load = TRUE) {

  op <- options()
  options(timeout = 3600)

  if(any(c("DT", "header", "CWM_CWV") %in% tables) == F) stop("tables must include at least one of 'DT', 'header', 'CWM_CWV'")

  # create directory
  if (!is.null(dir)) {
    if (stringr::str_sub(dir, -1) != "/") {
      dir <- paste(dir, "/", sep = "")
    }
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = T)
      message(paste("Creating directory:", dir))
    }
    message(paste0("Saving to ", dir))
  }

  # give error message if no directory is specified and load = FALSE
  if (is.null(dir) & load == FALSE) {
    stop("Must specify a directory (\"dir\") to save data when \"load = FALSE\".")
  }

  # check if tables exist
  if(!is.null(dir)) {
    existing <- sapply(tables, function(i) any(stringr::str_detect(list.files(dir), i)))
    if(any(existing)) {
      download <- readline(paste(paste(tables[existing], collapse = ", "),
                                 "already exist in", dir, "\nDownload anyway? (y/n)"))
      if(download == "y") {
        print("Downloading data")
      } else {
        stop("Not downloading data. Use read_sPlot() to load existing tables")
      }
    }
  }

  # download zipped sPlotOpen data to temporary file
  temp <- tempfile()
  url <- "https://idata.idiv.de/ddm/Data/DownloadZip/3474?version=5047"
  utils::download.file(url, temp, mode = "wb")

  if (!is.null(dir)) {

    # extract to directory
    utils::unzip(temp, exdir = stringr::str_sub(dir, 1, -2))
    unlink(temp)

    # load data
    if(load) {
      data <- list()
      if("DT" %in% tables) data$DT <- readr::read_tsv(file.path(dir, stringr::str_subset(list.files(dir), "DT")))
      if("header" %in% tables) data$header <- readr::read_tsv(file.path(dir, stringr::str_subset(list.files(dir), "header")), guess_max = 9999)
      if("CWM_CWV" %in% tables) data$CWM_CVM <- readr::read_tsv(file.path(dir, stringr::str_subset(list.files(dir), "CWM_CWV")))

      return(data)
    }

  } else {

    # unzip to temporary directory
    tempDir <- tempdir()
    utils::unzip(temp, exdir = tempDir)
    unlink(temp)

    # load data
    data <- list()
    if("DT" %in% tables) data$DT <- readr::read_tsv(file.path(tempDir, stringr::str_subset(list.files(tempDir), "DT")))
    if("header" %in% tables) data$header <- readr::read_tsv(file.path(tempDir, stringr::str_subset(list.files(tempDir), "header")), guess_max = 9999)
    if("CWM_CWV" %in% tables) data$CWM_CVM <- readr::read_tsv(file.path(tempDir, stringr::str_subset(list.files(tempDir), "CWM_CWV")))
    return(data)

    # delete temporary directory
    unlink(tempDir, recursive = T)
  }

  # reset initial options
  options(op)
}


#' Load sPlotOpen data into R
#'
#' `read_sPlot()` searches for sPlotOpen data tables in the directory you
#' specify and, if present, loads them into R.
#'
#' @param dir Directory where sPlotOpen tables are stored.
#' @param tables A character vector. Names of tables to load. Options are
#'   (default is to load all):
#'  * `"header"`: plot-level information.
#'  * `"DT"`: data on species composition of each plot in long format.
#'  * `"CWM_CWV"`: community-weighted means and variances for 18 traits.
#'
#' @return A named list containing sPlotOpen data tables as tibbles.
#' @export
#'
#' @examples
#' \dontrun{
#' # Load all sPlotOpen tables
#' db <- read_sPlot(dir = "~/sPlotOpen/data", tables = c("DT", "header", "CWM_CWV"))
#' }
read_sPlot <- function(dir = "~/sPlotOpen/data",
                       tables = c("header", "DT", "CWM_CWV")) {

  if(any(c("DT", "header", "CWM_CWV") %in% tables) == F) stop("tables must include at least one of 'DT', 'header', 'CWM_CWV'")

  data <- list()
  if("DT" %in% tables) data$DT <- readr::read_tsv(file.path(dir, stringr::str_subset(list.files(dir), "DT")))
  if("header" %in% tables) data$header <- readr::read_tsv(file.path(dir, stringr::str_subset(list.files(dir), "header")), guess_max = 9999)
  if("CWM_CWV" %in% tables) data$CWM_CVM <- readr::read_tsv(file.path(dir, stringr::str_subset(list.files(dir), "CWM_CWV")))

  return(data)
}

