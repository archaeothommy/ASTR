# Workflow

Please find below the suggested flow of actions to write a function for the ASTR package. 

## Preparation 

You can do all these steps within R Studio in the "Git" and "Files" panes. 

One team member: 

1. Pull the latest version of ASTR from GitHub.
2. Create a new branch by running `usethis::pr_init(branch = "<NAME>")` in the console after replacing `<Name>` with the name of the new branch. The branch name should be the name of the function or something similarly telling. 
3. Create copies of the relevant documents in the folder `dev_guide` in the proper directories and rename them to the function name while leaving "ASTR_" intact. Usually, these are at least: 
  * Folder `R`: ASTR_function.R
  * Folder `tests/testthat`: ASTR_test.R
4. Push the changes to GitHub. 

Everyone: 

* Pull the latest version from GitHub and switch to the new branch. 

## Coding

### 1. Populate the files according to the instructions in them 
  * Function
  * Documentation
  * Examples (part of the documentation block)
  * Tests (in the test file)
  * (Vignette)
 
### 2. Check the formatting of the function(s)
  * Remove all comments unrelated to the function. 
  * Style the function by using the Styler addin ("Style active file").
  * Lint the function by using the Lintr addin ("Lint current file") and fix all listed issues. 
  * Proof-read the documentation. You can create its formatted version by running in the R console: `devtools::document()` 

When working with multiple people on the same function, this is the time to push everything to GitHub and pull the most recent version of the branch you are working on. The following steps require that all parts (code, documentation, tests, ...) are available. 

### 3. Make sure everything is working correctly 
  * Load the newest version of your function by running in the R console: `devtools::load_all()`
  * Test the function by running `devtools::test()` and make sure that all tests succeed.  
  * Check that your tests cover all relevant parts of the function by using the devtools addin ("Report test coverage for a file") or running in the R console: `devtools::test_coverage_active_file()`
  * If needed, add tests and repeat the previous steps until all (relevant) parts of the code are covered by tests and all tests succeed.
  * Build and test the package by running in the R console: `devtools::check()` and fix any reported errors, warnings and ideally also notes. 
  * If you made any changes, repeat steps 2 and 3 and run `devtools::check()` one last time to exclude errors introduced by typos. 

### 4. Integrating the function into the package

These steps are done only by the person that serves as point of contact for any questions about the function. 

  * Run in the R console: `usethis::pr_push()`
  * In the browser, click "Create pull request".
  * Provide a telling title and a short summary. In the summary, include any relevant further information. This especially includes information related to the results of `devtools::check()` and if there is anything that should be checked more thoroughly or needs to be addressed. 
  * Create a draft pull request if you are unsure that the function is ready for the package as is. Create a pull request if you think it is. You can choose between both with the small downward-facing triangle on the green button. 
  * The maintainer of the package will be automatically notified and check your changes. This might take a bit. 
  * If the maintainer points out anything that needs to be changed: 
    * Make sure that you are on the branch of the function you are working on.
    * Get the latest state by running in the R console: `usethis::pr_pull()` 
    * Update the code accordingly and repeat steps 2 to 4.

To switch more easily between main branch and branches of functions, you could use `usethis::pr_pause()` and `usethis::pr_resume()`. For further details, see the [usethis vignette](https://usethis.r-lib.org/articles/pr-functions.html#other-helpful-functions) this workflow is based upon. 
    
### 5. Start working on a new function
  * Switch back to the main branch. 
  * Only when you got the mail that your pull request was merged into the main branch: 
    * Make sure that you are on the branch of the function you are working on.
    * Run in the R console: `usethis::pr_finish()`

## Additional notes

### Major changes on the main brach
Changes on the main branch likely affecting ongoing work on functions are announced in the plenary sessions. If they occur: 

* Make sure that you are on the branch of the function you are working on. 
* Run in the R console: `usethis::pr_merge_main()` 
* If a pull request was already created for the function, repeat step 3 and, if this resulted in changes, step 4. 

### Coding
Please use comments in the function code to add context, to explain reasoning behind choices not readily graspable from the code itself, and to inform developers about e.g. to dos for a specific part of the function. Write such comments as complete sentences and be as informative as possible.

Consider using comments to structure the code into subsections to improve navigation in it. You can create such sections in RStudio with `CTRL+SHIFT+R`. 

### Documentation

Use [markdown tags](https://roxygen2.r-lib.org/articles/markdown.html#syntax) to insert links, lists and other formatted text in the documentation. They are more easily readable than the [native Roxygen tags](https://roxygen2.r-lib.org/articles/formatting.html). 

### Testing plots
There are two approaches to automatically test plotting functions: Testing the objects storing the information for the plot and testing the plot itself. It can be difficult to test the objects directly because they are often complex lists (e.g. in ggplot2), making it difficult to find which information is stored where and what to use as comparison to test for. Nevertheless, this is the most reliable approach especially if data are transformed in the plotting function. You can easily browse through such lists in RStudio and a button allows you to get the full path to the respective element in the object. The ggplot2 tutorial will include an overview on the structure of these objects. 

Testing the plot itself requires [vdiffr](https://vdiffr.r-lib.org/), an extension for testthat, the test suite for R packages. This package allows comparison of a plot created during testing against an existing snapshot of the plot. It fails if the two versions differ. Therefore, these tests are best suited if it was visually confirmed before that the initial plot looks as desired or to capture unwanted changes resulting from revisions. The ggplot2 tutorial will include an example for how tests with vdiffr look like. 
