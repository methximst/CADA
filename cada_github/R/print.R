summary_row <- function(x) {
  data.frame(
    dv = x$dv,
    design = x$design,
    method = x$method,
    deviation = x$deviation,
    bootstrap_deviation = x$bootstrap_deviation,
    alternative = x$alternative,
    criterion = x$criterion,
    dev1 = x$dev1,
    dev2 = x$dev2,
    var_criterion_boot = value_or_na(x$var_criterion_boot),
    sd_criterion_boot = value_or_na(x$sd_criterion_boot),
    z_boot = value_or_na(x$z_boot),
    p_boot = value_or_na(x$p_boot),
    var_criterion_formula = value_or_na(x$var_criterion_formula),
    sd_criterion_formula = value_or_na(x$sd_criterion_formula),
    z_formula = value_or_na(x$z_formula),
    p_normal = value_or_na(x$p_normal),
    effect_numerator_group = value_or_na(x$effect_numerator_group),
    effect_denominator_group = value_or_na(x$effect_denominator_group),
    cada_effect_group = value_or_na(x$cada_effect_group),
    better_hypothesis = x$better_hypothesis,
    stringsAsFactors = FALSE
  )
}

value_or_na <- function(x) {
  if (is.null(x)) {
    return(NA_real_)
  }
  x
}

print.cada <- function(x, digits = max(3L, getOption("digits") - 3L), ...) {
  cat(x$title, "\n")
  cat("Design:            ", x$design, "\n")
  cat("Method:            ", x$method, "\n")
  cat("Alternative:       ", x$alternative, "\n")
  cat("Dependent variable:", x$dv, "\n")
  cat("Between variable:  ", x$between, "\n")
  if (x$method %in% c("bootstrap", "both")) {
    cat("Bootstrap samples: ", x$n_boot, "\n")
  }
  cat("\n")

  out <- summary_row(x)
  numeric_cols <- vapply(out, is.numeric, logical(1))
  out[numeric_cols] <- lapply(out[numeric_cols], round, digits = digits)
  print(out, row.names = FALSE)

  invisible(x)
}

summary.cada <- function(object, ...) {
  out <- list(
    results = summary_row(object),
    level_results = object$results_by_level,
    dist = object$dist
  )
  class(out) <- "summary_cada"
  out
}

print.summary_cada <- function(x, digits = max(3L, getOption("digits") - 3L), ...) {
  cat("Result summary\n")
  results <- x$results
  numeric_cols <- vapply(results, is.numeric, logical(1))
  results[numeric_cols] <- lapply(results[numeric_cols], round, digits = digits)
  print(results, row.names = FALSE)

  cat("\nLevel-level components\n")
  level_results <- x$level_results
  numeric_cols <- vapply(level_results, is.numeric, logical(1))
  level_results[numeric_cols] <- lapply(level_results[numeric_cols], round, digits = digits)
  print(level_results, row.names = FALSE)

  invisible(x)
}

plot.cada <- function(x,
                      breaks = 40,
                      main = NULL,
                      xlab = "Bootstrap criterion",
                      ...) {
  if (is.null(x$dist)) {
    stop("No bootstrap distribution is available. Use `method = \"bootstrap\"` or `method = \"both\"`.", call. = FALSE)
  }

  if (is.null(main)) {
    main <- paste("CADA bootstrap distribution:", x$dv)
  }

  graphics::hist(
    x$dist,
    breaks = breaks,
    main = main,
    xlab = xlab,
    ...
  )
  graphics::abline(v = 0, lty = 2)
  graphics::abline(v = x$criterion, lwd = 2)
  graphics::abline(v = -abs(x$criterion), lty = 3)
  graphics::abline(v = abs(x$criterion), lty = 3)

  invisible(x)
}

print.cada_multi <- function(x, digits = max(3L, getOption("digits") - 3L), ...) {
  cat(x$title, "\n")
  cat("Design:            ", x$design, "\n")
  cat("Method:            ", x$method, "\n")
  cat("Alternative:       ", x$alternative, "\n")
  if (x$method %in% c("bootstrap", "both")) {
    cat("Bootstrap samples: ", x$n_boot, "\n")
  }
  cat("\n")

  results <- x$results
  numeric_cols <- vapply(results, is.numeric, logical(1))
  results[numeric_cols] <- lapply(results[numeric_cols], round, digits = digits)
  print(results, row.names = FALSE)

  invisible(x)
}

summary.cada_multi <- function(object, ...) {
  out <- list(
    results = object$results,
    analyses = object$analyses
  )
  class(out) <- "summary_cada_multi"
  out
}

print.summary_cada_multi <- function(x, digits = max(3L, getOption("digits") - 3L), ...) {
  cat("Multi-variable result summary\n")
  results <- x$results
  numeric_cols <- vapply(results, is.numeric, logical(1))
  results[numeric_cols] <- lapply(results[numeric_cols], round, digits = digits)
  print(results, row.names = FALSE)

  invisible(x)
}
