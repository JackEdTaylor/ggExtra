runggplot2InternalsTests <- function(ggplot2Version) {

  context <- paste("ggplot2 internals under ggplot2 version", ggplot2Version)

  context(context)

  test_that("ggExtra's accession of ggplot2 title grobs works" , {

    titleP <- function(title) {
      basicScatP() + title
    }
    titleList <- list(
      noSub = ggplot2::ggtitle("hi"),
      sub = ggplot2::ggtitle("there", subtitle = "friend")
    )

    expect_true({
      gTest <- vapply(
        titleList, 
        function(x) length(ggExtra:::getTitleGrobs(titleP(x))) == 2,
        logical(1)
      )
      all(gTest)
    })
    expect_true({
      gTest <- vapply(
        titleList, 
        function(x) !is.null(ggplot2::ggplot_build(titleP(x))$plot$labels$title),
        logical(1)
      )
      all(gTest)
    })

    expect_true({
      is.null(ggplot2::ggplot_build(titleP(ggplot2::theme()))$plot$labels$title)
    })

  })
  
  test_that("ggplot2 models scatter plot data as expected" , {
    
    scatPbuilt <- ggplot2::ggplot_build(basicScatP())
    scatDF <- scatPbuilt[["data"]][[1]]
    expect_true({
      "x" %in% colnames(scatDF) && "y" %in% colnames(scatDF)
    })
    
  })
  
  test_that("ggplot2 uses positive integers for groups and -1 for no groups" , {
    
    p1 <- ggplot2::ggplot(
      mtcars, ggplot2::aes(x = wt, y = mpg, colour = factor(gear))
    ) + ggplot2::geom_point()
    bp <- ggplot2::ggplot_build(p1)
    grp_vals <- unique(bp$data[[1]]$group)
    expect_true(all(grp_vals[order(grp_vals)] == c(1, 2, 3)))
    
    bp2 <- ggplot2::ggplot_build(basicScatP())
    grp_vals2 <- unique(bp2$data[[1]]$group)
    expect_true(grp_vals2 == -1L)
    
  })
  
}

# Function to run all tests against ggplot2 internals under all ggplot2 versions
runInternalTestsApply <- function(ggplot2Versions) {
  sapply(ggplot2Versions, function(ggplot2Version) {
    withVersions(ggplot2 = ggplot2Version, code = {
      runggplot2InternalsTests(ggplot2Version)
    })
  })
}

if (shouldTest()) {
  runInternalTestsApply(ggplot2Versions)
}
