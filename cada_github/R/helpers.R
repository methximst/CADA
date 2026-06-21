assert_data_frame <- function(x) {
  if (!is.data.frame(x)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  invisible(TRUE)
}

assert_string <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop("`", arg, "` must be a single non-missing character string.", call. = FALSE)
  }
  x
}

assert_optional_string <- function(x, arg) {
  if (is.null(x)) {
    return(NULL)
  }
  assert_string(x, arg)
}

assert_count <- function(x, arg) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 1L || x != floor(x)) {
    stop("`", arg, "` must be a positive whole number.", call. = FALSE)
  }
  as.integer(x)
}

align_hypothesis <- function(x, levels, arg) {
  if (is.list(x) && !is.data.frame(x)) {
    x <- unlist(x, use.names = TRUE)
  }

  if (!is.numeric(x)) {
    stop("`", arg, "` must be numeric.", call. = FALSE)
  }

  x_names <- names(x)
  has_names <- !is.null(x_names) && all(nzchar(x_names))

  if (has_names) {
    missing_levels <- setdiff(levels, x_names)
    if (length(missing_levels) > 0L) {
      stop(
        "`", arg, "` is missing value(s) for level(s): ",
        paste(missing_levels, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
    out <- x[levels]
  } else {
    if (length(x) != length(levels)) {
      stop(
        "`", arg, "` must have length ", length(levels),
        " or names matching the observed levels.",
        call. = FALSE
      )
    }
    out <- x
    names(out) <- levels
  }

  out <- as.numeric(out)
  names(out) <- levels

  if (anyNA(out)) {
    stop("`", arg, "` contains missing hypothesis values.", call. = FALSE)
  }

  out
}

group_variance <- function(x, variance) {
  if (identical(variance, "sample")) {
    return(stats::var(x))
  }

  mean((x - mean(x))^2)
}

group_deviation <- function(h, means, n) {
  n * (h - means)^2
}

criterion_from_means <- function(means, h1, h2, n) {
  dev1_by_level <- group_deviation(h1, means, n)
  dev2_by_level <- group_deviation(h2, means, n)

  list(
    dev1_by_level = dev1_by_level,
    dev2_by_level = dev2_by_level,
    dev1 = sum(dev1_by_level),
    dev2 = sum(dev2_by_level),
    criterion = sum(dev1_by_level) - sum(dev2_by_level)
  )
}

normal_p_values <- function(criterion, sd_criterion) {
  if (is.na(sd_criterion) || sd_criterion < 0) {
    return(list(z = NA_real_, p_left = NA_real_, p_right = NA_real_, p_two_sided = NA_real_))
  }

  if (sd_criterion == 0) {
    z <- if (criterion == 0) 0 else sign(criterion) * Inf
  } else {
    z <- criterion / sd_criterion
  }

  list(
    z = z,
    p_left = stats::pnorm(z),
    p_right = 1 - stats::pnorm(z),
    p_two_sided = min(1, 2 * stats::pnorm(-abs(z)))
  )
}

normalize_alternative <- function(alternative) {
  if (length(alternative) > 1L) {
    alternative <- alternative[[1L]]
  }

  alternative <- match.arg(
    alternative,
    choices = c("two.sided", "h1", "h2", "two_sided", "two-sided", "h1_better", "h2_better")
  )

  switch(
    alternative,
    two_sided = "two.sided",
    "two-sided" = "two.sided",
    h1_better = "h1",
    h2_better = "h2",
    alternative
  )
}

p_value_for_alternative <- function(p_left, p_right, p_two_sided, alternative) {
  switch(
    alternative,
    h1 = p_left,
    h2 = p_right,
    two.sided = p_two_sided
  )
}

z_from_sd <- function(criterion, sd_criterion) {
  if (is.na(sd_criterion) || sd_criterion == 0) {
    if (criterion == 0) {
      return(0)
    }
    return(sign(criterion) * Inf)
  }

  criterion / sd_criterion
}

better_hypothesis <- function(criterion) {
  if (criterion < 0) {
    return("Hypothesis 1 fits better")
  }
  if (criterion > 0) {
    return("Hypothesis 2 fits better")
  }
  "Both hypotheses fit equally well"
}

hypothesis_for_dv <- function(x, dv, arg) {
  if (is.numeric(x) && !is.matrix(x) && !is.data.frame(x)) {
    return(x)
  }

  if (is.data.frame(x) || is.matrix(x)) {
    if (!dv %in% colnames(x)) {
      stop("Column `", dv, "` was not found in `", arg, "`.", call. = FALSE)
    }
    out <- x[, dv]
    if (!is.null(row.names(x))) {
      names(out) <- row.names(x)
    }
    return(out)
  }

  if (is.list(x) && !is.null(names(x))) {
    if (!dv %in% names(x)) {
      stop("Element `", dv, "` was not found in `", arg, "`.", call. = FALSE)
    }
    return(x[[dv]])
  }

  stop(
    "`", arg, "` must be a numeric vector, named list, data frame, or matrix.",
    call. = FALSE
  )
}

check_method_deviation <- function(method, deviation, bootstrap_deviation) {
  if (!identical(deviation, "squared")) {
    stop("Only `deviation = \"squared\"` is implemented.", call. = FALSE)
  }

  if (!identical(bootstrap_deviation, "squared")) {
    stop("Only `bootstrap_deviation = \"squared\"` is implemented.", call. = FALSE)
  }

  invisible(TRUE)
}
