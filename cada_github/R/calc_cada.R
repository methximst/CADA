#' Compare two hypothesized mean patterns for independent groups
#'
#' `calc_cada()` compares two hypothesized mean patterns in independent groups
#' using the squared CADA criterion. It can compute a bootstrap null
#' distribution, a normal approximation, or both.
#'
#' @param dv Character scalar. Name of the dependent variable.
#' @param h1,h2 Numeric vectors with hypothesized means for hypothesis 1 and 2.
#' @param data A data frame.
#' @param design Currently only `"between"` is implemented.
#' @param method Either `"bootstrap"`, `"normal"`, or `"both"`.
#' @param between Character scalar. Grouping variable for between-subject data.
#' @param n_boot Number of bootstrap samples.
#' @param seed Optional random seed.
#' @param bootstrap_deviation Currently only `"squared"` is implemented. The
#'   argument is kept so older scripts with `bootstrap_deviation = "squared"`
#'   keep working.
#' @param deviation Currently only `"squared"` is implemented. Kept for
#'   compatibility with older scripts.
#' @param variance `"sample"` uses denominator `n - 1`; `"population"` uses
#'   denominator `n`.
#' @param alternative Direction of the hypothesis comparison. `"h1"` tests
#'   whether hypothesis 1 fits better than hypothesis 2 (`criterion < 0`).
#'   `"h2"` tests whether hypothesis 2 fits better than hypothesis 1
#'   (`criterion > 0`). `"two.sided"` tests whether either hypothesis fits
#'   better than the other, regardless of direction.
#' @param na.rm Logical. If `TRUE`, incomplete rows are removed.
#' @param reverse_bootstrap Optional logical. For between-subject bootstrap with
#'   squared deviations, `NULL` reproduces the earlier `cadaboot` convention and
#'   reverses the bootstrap hypotheses.
#'
#' @return An object of class `"cada"`.
#' @export
calc_cada <- function(dv,
                      h1,
                      h2,
                      data,
                      design = "between",
                      method = c("bootstrap", "normal", "both"),
                      between = NULL,
                      n_boot = 1000L,
                      seed = NULL,
                      bootstrap_deviation = "squared",
                      deviation = "squared",
                      variance = c("sample", "population"),
                      alternative = c("two.sided", "h1", "h2"),
                      na.rm = TRUE,
                      reverse_bootstrap = NULL) {
  design <- match.arg(design, choices = "between")
  method <- match.arg(method)
  deviation <- match.arg(deviation, choices = "squared")
  bootstrap_deviation <- match.arg(bootstrap_deviation, choices = "squared")
  variance <- match.arg(variance)
  alternative <- normalize_alternative(alternative)

  assert_data_frame(data)
  dv <- assert_string(dv, "dv")
  between <- assert_optional_string(between, "between")
  n_boot <- assert_count(n_boot, "n_boot")

  check_method_deviation(method, deviation, bootstrap_deviation)

  if (!is.null(reverse_bootstrap) &&
      (!is.logical(reverse_bootstrap) || length(reverse_bootstrap) != 1L || is.na(reverse_bootstrap))) {
    stop("`reverse_bootstrap` must be `TRUE`, `FALSE`, or `NULL`.", call. = FALSE)
  }

  deviation_for_analysis <- "squared"
  analysis <- calculate_between(
    dv = dv,
    between = between,
    h1 = h1,
    h2 = h2,
    data = data,
    method = method,
    n_boot = n_boot,
    seed = seed,
    deviation = deviation_for_analysis,
    variance = variance,
    alternative = alternative,
    na.rm = na.rm,
    reverse_bootstrap = reverse_bootstrap
  )

  out <- c(
    list(
      call = match.call(),
      method = method,
      deviation = deviation_for_analysis,
      bootstrap_deviation = if (method %in% c("bootstrap", "both")) bootstrap_deviation else NA_character_,
      variance = variance,
      alternative = alternative,
      n_boot = if (method %in% c("bootstrap", "both")) n_boot else NA_integer_,
      seed = seed,
      title = "CADA comparison of competing hypothesized mean patterns"
    ),
    analysis
  )

  class(out) <- "cada"
  out
}

#' Compare two hypotheses for several dependent variables
#'
#' `calc_cada_multi()` applies [calc_cada()] to several dependent variables.
#' `h1` and `h2` can be numeric vectors reused for all dependent variables,
#' named lists, or data frames/matrices whose columns are dependent-variable
#' names and whose row names are groups.
#'
#' @param dvs Character vector. Dependent variables to analyze.
#' @inheritParams calc_cada
#'
#' @return An object of class `"cada_multi"`.
#' @export
calc_cada_multi <- function(dvs,
                            h1,
                            h2,
                            data,
                            design = "between",
                            method = c("bootstrap", "normal", "both"),
                            between = NULL,
                            n_boot = 1000L,
                            seed = NULL,
                            bootstrap_deviation = "squared",
                            deviation = "squared",
                            variance = c("sample", "population"),
                            alternative = c("two.sided", "h1", "h2"),
                            na.rm = TRUE,
                            reverse_bootstrap = NULL) {
  design <- match.arg(design, choices = "between")
  method <- match.arg(method)
  deviation <- match.arg(deviation, choices = "squared")
  bootstrap_deviation <- match.arg(bootstrap_deviation, choices = "squared")
  variance <- match.arg(variance)
  alternative <- normalize_alternative(alternative)
  assert_data_frame(data)

  if (!is.character(dvs) || length(dvs) == 0L || anyNA(dvs)) {
    stop("`dvs` must be a non-empty character vector.", call. = FALSE)
  }

  missing_dvs <- setdiff(dvs, names(data))
  if (length(missing_dvs) > 0L) {
    stop(
      "The following dependent variable(s) were not found in `data`: ",
      paste(missing_dvs, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  seeds <- rep(list(NULL), length(dvs))
  if (!is.null(seed)) {
    set.seed(seed)
    seeds <- as.list(sample.int(.Machine$integer.max, length(dvs)))
  }

  analyses <- lapply(
    seq_along(dvs),
    function(i) {
      dv <- dvs[[i]]
      calc_cada(
        dv = dv,
        h1 = hypothesis_for_dv(h1, dv, "h1"),
        h2 = hypothesis_for_dv(h2, dv, "h2"),
        data = data,
        design = design,
        method = method,
        between = between,
        n_boot = n_boot,
        seed = seeds[[i]],
        bootstrap_deviation = bootstrap_deviation,
        deviation = deviation,
        variance = variance,
        alternative = alternative,
        na.rm = na.rm,
        reverse_bootstrap = reverse_bootstrap
      )
    }
  )
  names(analyses) <- dvs

  results <- do.call(
    rbind,
    lapply(analyses, summary_row)
  )
  row.names(results) <- NULL

  out <- list(
    call = match.call(),
    title = "CADA comparison for several dependent variables",
    design = design,
    method = method,
    deviation = "squared",
    bootstrap_deviation = if (method %in% c("bootstrap", "both")) bootstrap_deviation else NA_character_,
    variance = variance,
    alternative = alternative,
    between = between,
    dvs = dvs,
    n_boot = if (method %in% c("bootstrap", "both")) n_boot else NA_integer_,
    seed = seed,
    results = results,
    analyses = analyses
  )

  class(out) <- "cada_multi"
  out
}
