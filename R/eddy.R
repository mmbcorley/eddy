# function to do some sanity checks, update swirls, etc.

#' @export
eddy <- function () {
  ## first, check whether we have an internet connection

  ## see http://stackoverflow.com/questions/5076593/how-to-determine-if-you-have-an-internet-connection-in-r
  ## note function is locally defined to avoid namespace pollution
  can_internet <- function(url = "http://www.google.com") {

    # test the http capabilities of the current R build
    if (!capabilities(what = "http/ftp")) return(FALSE)

    # test connection by trying to read first line of url
    test <- try(suppressWarnings(readLines(url, n = 1)), silent = TRUE)

    # return FALSE if test inherits 'try-error' class
    !inherits(test, "try-error")
  }

  if (!can_internet()) stop("Please ensure your computer is connected to the internet and try eddy() again")

  ## second - check if swirl is installed, install if not.
  pkg_install <- function(pkg) {
    #check availabilty to load
    if (!require(pkg,character.only=TRUE)){
      install.packages(pkg,dep=TRUE)
      #recheck if can load.
      if(!require(pkg,character.only = TRUE)) stop("Can't install package - seek help")
    }
  }
  #pkg_install loads package too, so am suppressing the swirl output.
  suppressMessages(pkg_install("swirl"))

  ## third, check whether there is a UoEPsych installation and, if so, remove the progress
  ## and also remove course.

  #note - for this year's lot, we want to also remove the old courses named "Y2_Psychology_RMS1",
  # so this function has to be a bit more cumbersome than I'd like (extra if-loop for old course).

  check_courses<-function() {
    #find courses directory and user directory for swirl
    course_dir<-system.file("Courses", package="swirl")
    user_dir<-system.file("user_data", package ="swirl")
    # delete any old version of UoEPsych, and delete user progress
    if ("UoE-Psych" %in% list.files(course_dir)==TRUE){
      course_path <- system.file("Courses/UoE-Psych",package="swirl")
      invisible(unlink(course_path, recursive = TRUE, force = TRUE))
      if (file.exists(user_dir)) {
        invisible(unlink(list.files(user_dir, full.names = TRUE), recursive = TRUE))
      }
    }
    if ("Y2_Psychology_RMS1" %in% list.files(course_dir)==TRUE){
      course_path <- system.file("Courses/Y2_Psychology_RMS1",package="swirl")
      invisible(unlink(course_path, recursive = TRUE, force = TRUE))
      if (file.exists(user_dir)) {
        invisible(unlink(list.files(user_dir, full.names = TRUE), recursive = TRUE))
      }
    }
  }
  check_courses()
  # one problem with the above function is that every time a student runs eddy(), they are
  # essentially starting swirl with a completely new user. which means swirl shows them
  # the basic swirl instructions (can skip through in matter of seconds though).
  # see check_courses2 function for alternative - a bit more cumbersome.

  #possibly clear globalEnv? - is this because it might leave them with the above functions?
  rm(list=ls())

  ## fourth, start swirl and update the UoEPsych repository
  swirl_loaded <- "package:swirl" %in% search()
  require(swirl)

  #install_course_github("UoE-Psychology","UoE-Psych")
  #gives a message "perl is deprecated. Please use regexp instead"
  #It feels a bit wrong to suppress warnings, but given that the whole point to eddy() is to
  #hide all of this from the students, maybe use the following instead:
  suppressMessages(suppressWarnings(install_course_github("UoE-Psychology","UoE-Psych")))

  # if swirl was previously loaded there'll be no reminder to type "swirl()", so we'll write one
  if (swirl_loaded)
    packageStartupMessage(
      # three colons to access a functions which is not exported
      swirl:::make_pretty("Hi! Type swirl() when you are ready to begin.",skip_after=TRUE)
    )
}