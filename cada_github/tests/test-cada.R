library(cada)

d_between <- simulate_cada_between_data(n_per_group = 20, seed = 123)
h_between <- make_cada_between_hypotheses("allgh1vsh2")

res_between <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h_between$h1,
  h2 = h_between$h2,
  data = d_between,
  design = "between",
  method = "both",
  n_boot = 30,
  seed = 123,
  alternative = "h1"
)

stopifnot(inherits(res_between, "cada"))
stopifnot(length(res_between$dist) == 30)
stopifnot(is.finite(res_between$criterion))
stopifnot(is.finite(res_between$var_criterion_formula))
stopifnot(is.finite(res_between$cada_effect_group))
stopifnot(identical(res_between$alternative, "h1"))
stopifnot(identical(res_between$p_boot, res_between$p_left_boot))
stopifnot(identical(res_between$p_normal, res_between$p_left_normal))

effect_from_components <- (res_between$dev2 - res_between$dev1) /
  sum(res_between$results_by_level$n * res_between$results_by_level$variance)
stopifnot(isTRUE(all.equal(res_between$cada_effect_group, effect_from_components)))
stopifnot(!"p_left_boot" %in% names(summary(res_between)$results))
stopifnot(!"p_right_boot" %in% names(summary(res_between)$results))
stopifnot(!"p_two_sided_boot" %in% names(summary(res_between)$results))
stopifnot("cada_effect_group" %in% names(summary(res_between)$results))
stopifnot("effect_denominator_group" %in% names(summary(res_between)$results))

res_between_h2 <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h_between$h1,
  h2 = h_between$h2,
  data = d_between,
  design = "between",
  method = "both",
  n_boot = 30,
  seed = 123,
  alternative = "h2"
)

stopifnot(identical(res_between_h2$p_boot, res_between_h2$p_right_boot))
stopifnot(identical(res_between_h2$p_normal, res_between_h2$p_right_normal))

res_between_two_sided <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h_between$h1,
  h2 = h_between$h2,
  data = d_between,
  design = "between",
  method = "both",
  n_boot = 30,
  seed = 123,
  alternative = "two.sided"
)

stopifnot(identical(res_between_two_sided$p_boot, res_between_two_sided$p_two_sided_boot))
stopifnot(identical(res_between_two_sided$p_normal, res_between_two_sided$p_two_sided_normal))

res_between_multi <- calc_cada_multi(
  dvs = c("allg", "verbal"),
  between = "condition",
  h1 = h_between$h1,
  h2 = h_between$h2,
  data = d_between,
  design = "between",
  method = "normal",
  alternative = "h2"
)

stopifnot(inherits(res_between_multi, "cada_multi"))
stopifnot(nrow(res_between_multi$results) == 2)
stopifnot(all(res_between_multi$results$alternative == "h2"))
stopifnot(all(is.finite(res_between_multi$results$cada_effect_group)))
stopifnot(all(!c("p_left_normal", "p_right_normal", "p_two_sided_normal") %in%
  names(res_between_multi$results)))
stopifnot(all(vapply(
  res_between_multi$analyses,
  function(x) identical(x$p_normal, x$p_right_normal),
  logical(1)
)))
