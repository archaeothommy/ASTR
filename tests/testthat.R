# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)
# suppressMessages: the `units` dependency prints a startup message
# ("udunits database from ...") on first load, which would otherwise
# clutter the test report.
suppressMessages(library(ASTR))

test_check("ASTR")
