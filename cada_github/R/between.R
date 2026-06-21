calculate_between <- function(dv,
                              between,
                              h1,
                              h2,
                              data,
                              method,
                              n_boot,
                              seed,
                              deviation,
                              variance,
                              alternative,
                              na.rm,
                              reverse_bootstrap) {
  if (is.null(between)) {
    stop("`between` must be supplied when `design = \"between\"`.", call. = FALSE)
  }

  if (!dv %in% names(data)) {
    stop("Column `dv = \"", dv, "\"` was not found in `data`.", call. = FALSE)
  }
  if (!between %in% names(data)) {
    stop("Column `between = \"", between, "\"` was not found in `data`.", call. = FALSE)
  }
  if (!is.numeric(data[[dv]])) {
    stop("The dependent variable `", dv, "` must be numeric.", call. = FALSE)
  }

  dat <- data[c(between, dv)]
  names(dat) <- c("group", "value")

  if (na.rm) {
    dat <- dat[stats::complete.cases(dat), , drop = FALSE]
  } else if (anyNA(dat)) {
    stop("Missing values found. Use `na.rm = TRUE` or remove them first.", call. = FALSE)
  }

  if (nrow(dat) == 0L) {
    stop("No complete observations are available for this analysis.", call. = FALSE)
  }

  dat$group <- as.character(dat$group)
  groups <- unique(dat$group)

  if (length(groups) < 2L) {
    stop("At least two observed groups are needed.", call. = FALSE)
  }

  h1 <- align_hypothesis(h1, groups, "h1")
  h2 <- align_hypothesis(h2, groups, "h2")

  values_by_group <- split(dat$value, factor(dat$group, levels = groups), drop = TRUE)
  n_by_group <- vapply(values_by_group, length, integer(1))
  means_empirical <- vapply(values_by_group, mean, numeric(1))

  if (variance == "sample" && any(n_by_group < 2L)) {
    small_groups <- names(n_by_group)[n_by_group < 2L]
    stop(
      "Sample variances require at least two observations per group. Problem group(s): ",
      paste(small_groups, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  variance_empirical <- vapply(
    values_by_group,
    group_variance,
    numeric(1),
    variance = variance
  )

  observed <- criterion_from_means(
    means = means_empirical,
    h1 = h1,
    h2 = h2,
    n = n_by_group
  )

  midpoint <- (h1 + h2) / 2
  shift_to_midpoint <- midpoint - means_empirical

  bootstrap <- list()
  if (method %in% c("bootstrap", "both")) {
    if (is.null(reverse_bootstrap)) {
      reverse_bootstrap <- TRUE
    }

    values_shifted <- Map(
      function(x, shift) x + shift,
      values_by_group,
      shift_to_midpoint
    )

    h1_boot <- h1
    h2_boot <- h2
    if (reverse_bootstrap) {
      h1_boot <- h2
      h2_boot <- h1
    }

    if (!is.null(seed)) {
      set.seed(seed)
    }

    dist <- replicate(
      n_boot,
      {
        means_boot <- mapply(
          function(x, n) mean(sample(x, size = n, replace = TRUE)),
          values_shifted,
          n_by_group
        )
        means_boot <- as.numeric(means_boot)
        names(means_boot) <- groups

        criterion_from_means(
          means = means_boot,
          h1 = h1_boot,
          h2 = h2_boot,
          n = n_by_group
        )$criterion
      }
    )
    dist <- sort(as.numeric(dist))

    bootstrap <- list(
      reverse_bootstrap = reverse_bootstrap,
      dist = dist,
      var_criterion_boot = stats::var(dist),
      sd_criterion_boot = stats::sd(dist),
      z_boot = z_from_sd(observed$criterion, stats::sd(dist)),
      p_left_boot = mean(dist <= observed$criterion),
      p_right_boot = mean(dist >= observed$criterion),
      p_two_sided_boot = mean(abs(dist) >= abs(observed$criterion))
    )
    bootstrap$p_boot <- p_value_for_alternative(
      p_left = bootstrap$p_left_boot,
      p_right = bootstrap$p_right_boot,
      p_two_sided = bootstrap$p_two_sided_boot,
      alternative = alternative
    )
  }

  normal <- list()
  if (method %in% c("normal", "both")) {
    var_y_by_group <- 4 * (h2 - h1)^2 * variance_empirical
    var_criterion_by_group <- n_by_group * var_y_by_group
    var_criterion_formula <- sum(var_criterion_by_group)
    sd_criterion_formula <- sqrt(var_criterion_formula)
    p_values <- normal_p_values(observed$criterion, sd_criterion_formula)

    normal <- list(
      var_y_by_group = var_y_by_group,
      var_criterion_by_group = var_criterion_by_group,
      var_criterion_formula = var_criterion_formula,
      sd_criterion_formula = sd_criterion_formula,
      z_formula = p_values$z,
      p_left_normal = p_values$p_left,
      p_right_normal = p_values$p_right,
      p_two_sided_normal = p_values$p_two_sided,
      p_normal = p_value_for_alternative(
        p_left = p_values$p_left,
        p_right = p_values$p_right,
        p_two_sided = p_values$p_two_sided,
        alternative = alternative
      )
    )
  }

  df_error <- sum(n_by_group) - length(groups)
  effect_numerator_group <- observed$dev2 - observed$dev1
  effect_denominator_group <- sum(n_by_group * variance_empirical)
  cada_effect_group <- if (is.na(effect_denominator_group) || effect_denominator_group == 0) {
    NA_real_
  } else {
    effect_numerator_group / effect_denominator_group
  }

  group_results <- data.frame(
    level = groups,
    n = as.integer(n_by_group),
    mean = unname(means_empirical),
    variance = unname(variance_empirical),
    h1 = unname(h1),
    h2 = unname(h2),
    midpoint = unname(midpoint),
    shift_to_midpoint = unname(shift_to_midpoint),
    dev1 = unname(observed$dev1_by_level),
    dev2 = unname(observed$dev2_by_level),
    criterion_component = unname(observed$dev1_by_level - observed$dev2_by_level),
    effect_numerator_component = unname(observed$dev2_by_level - observed$dev1_by_level),
    effect_denominator_component = unname(n_by_group * variance_empirical),
    stringsAsFactors = FALSE
  )

  if (!is.null(normal$var_y_by_group)) {
    group_results$var_y <- unname(normal$var_y_by_group)
    group_results$var_criterion_component <- unname(normal$var_criterion_by_group)
  }

  c(
    list(
      design = "between",
      dv = dv,
      between = between,
      h1 = h1,
      h2 = h2,
      results_by_level = group_results,
      dev1 = observed$dev1,
      dev2 = observed$dev2,
      criterion = observed$criterion,
      n_total = as.integer(sum(n_by_group)),
      n_levels = as.integer(length(groups)),
      df_error = as.integer(df_error),
      effect_numerator_group = effect_numerator_group,
      effect_denominator_group = effect_denominator_group,
      cada_effect_group = cada_effect_group,
      better_hypothesis = better_hypothesis(observed$criterion)
    ),
    bootstrap,
    normal
  )
}
