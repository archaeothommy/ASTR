
#' Managing standard bracketing
#'
#' @description
#' Working with standard bracketing during analysis laboratory
#'
#' @details
#' <Any text written here goes into the "Details" section>
#'details details  vvvvvvvvvvvvvvvvvvvv
#'
#' @param df < Dataframe with analysis results from the machine>
#' @param ID_std string, <ID of the standard for bracketing>. The default value is "".
#' @param pos integer <position of the first line for bracketing>.
#'
#' @references
#' <include here any relevant literature references>
#'
#' @returns
#' <Describe the output of the function. This part goes into the "Value" section>
#'
#' @export # remove if the function should not be visible to the user
#'
#' @examples
#' <write here any example code. These are small simple examples on how to use
#' the function or to highlight specific features>

Bracketing <- function(df, std = "", pos=0) { # update name and arguments. The ellipsis parameter is special in R, use with care!

  if std=="":
    print("You need to assign the ID of the standard.")
    return ()


}
