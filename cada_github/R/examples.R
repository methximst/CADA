simulate_cada_between_data <- function(n_per_group = 40L, seed = 123) {
  n_per_group <- assert_count(n_per_group, "n_per_group")

  if (!is.null(seed)) {
    set.seed(seed)
  }

  groups <- rep(c("Gruppe1", "Gruppe2", "Gruppe3"), each = n_per_group)

  data.frame(
    id = seq_along(groups),
    condition = groups,
    allg = c(
      stats::rnorm(n_per_group, mean = 85, sd = 15),
      stats::rnorm(n_per_group, mean = 100, sd = 15),
      stats::rnorm(n_per_group, mean = 115, sd = 15)
    ),
    verbal = c(
      stats::rnorm(n_per_group, mean = 90, sd = 15),
      stats::rnorm(n_per_group, mean = 100, sd = 15),
      stats::rnorm(n_per_group, mean = 100, sd = 15)
    ),
    math = c(
      stats::rnorm(n_per_group, mean = 110, sd = 15),
      stats::rnorm(n_per_group, mean = 100, sd = 15),
      stats::rnorm(n_per_group, mean = 110, sd = 15)
    ),
    others = c(
      stats::rnorm(n_per_group, mean = 130, sd = 15),
      stats::rnorm(n_per_group, mean = 120, sd = 15),
      stats::rnorm(n_per_group, mean = 115, sd = 15)
    ),
    stringsAsFactors = FALSE
  )
}

make_cada_between_hypotheses <- function(pattern = c(
  "allgh1vsh2",
  "verbalh1vsh2",
  "mathh1vsh2",
  "othersh1vsh2"
)) {
  pattern <- match.arg(pattern)

  switch(
    pattern,
    allgh1vsh2 = list(
      h1 = c(Gruppe1 = 80, Gruppe2 = 95, Gruppe3 = 110),
      h2 = c(Gruppe1 = 90, Gruppe2 = 105, Gruppe3 = 120)
    ),
    verbalh1vsh2 = list(
      h1 = c(Gruppe1 = 90, Gruppe2 = 90, Gruppe3 = 100),
      h2 = c(Gruppe1 = 90, Gruppe2 = 100, Gruppe3 = 110)
    ),
    mathh1vsh2 = list(
      h1 = c(Gruppe1 = 115, Gruppe2 = 100, Gruppe3 = 115),
      h2 = c(Gruppe1 = 90, Gruppe2 = 105, Gruppe3 = 120)
    ),
    othersh1vsh2 = list(
      h1 = c(Gruppe1 = 115, Gruppe2 = 130, Gruppe3 = 115),
      h2 = c(Gruppe1 = 130, Gruppe2 = 120, Gruppe3 = 110)
    )
  )
}
