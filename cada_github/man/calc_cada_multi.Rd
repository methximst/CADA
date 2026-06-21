\encoding{UTF-8}
\name{calc_cada_multi}
\alias{calc_cada_multi}
\title{Mehrere abhängige Variablen mit CADA analysieren}
\usage{
calc_cada_multi(
  dvs,
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
  reverse_bootstrap = NULL
)
}
\arguments{
\item{dvs}{Namen der abhängigen Variablen als Textvektor, z. B.
\code{c("allg", "verbal", "math")}.}

\item{h1, h2}{Hypothesenwerte. Entweder ein numerischer Vektor, der für alle
abhängigen Variablen verwendet wird, oder eine benannte Liste mit einem
Hypothesenvektor pro abhängiger Variable.}

\item{data}{Ein Dataframe mit den Daten.}

\item{design}{Derzeit nur \code{"between"}.}

\item{method}{\code{"bootstrap"}, \code{"normal"} oder \code{"both"}.}

\item{between}{Name der Gruppierungsvariable als Text.}

\item{n_boot}{Anzahl der Bootstrap-Stichproben pro abhängiger Variable.}

\item{seed}{Optionaler Seed für reproduzierbare Ergebnisse.}

\item{bootstrap_deviation}{Derzeit nur \code{"squared"}.}

\item{deviation}{Derzeit nur \code{"squared"}.}

\item{variance}{\code{"sample"} oder \code{"population"}.}

\item{alternative}{Legt fest, welcher p-Wert als zentraler p-Wert berichtet
wird: \code{"h1"}, \code{"h2"} oder \code{"two.sided"}.}

\item{na.rm}{Wenn \code{TRUE}, werden unvollständige Zeilen entfernt.}

\item{reverse_bootstrap}{Spezialoption für die Bootstrap-Nullverteilung.}
}
\value{
Ein Objekt der Klasse \code{"cada_multi"} mit einer Ergebnistabelle und einer
Liste einzelner \code{"cada"}-Analysen.
}
\description{
\code{calc_cada_multi()} ist eine Abkürzung, wenn dieselbe CADA-Analyse für
mehrere abhängige Variablen gerechnet werden soll.
}
\details{
Diese Funktion ruft intern für jede abhängige Variable einmal
\code{\link{calc_cada}} auf. Die Ergebnistabelle enthält danach eine Zeile pro
abhängiger Variable. Die neue Effektgröße steht pro Zeile in
\code{cada_effect_group}.
}
\examples{
library(cada)

d <- simulate_cada_between_data(seed = 123)

h_allg <- make_cada_between_hypotheses("allgh1vsh2")
h_verbal <- make_cada_between_hypotheses("verbalh1vsh2")

h1_list <- list(
  allg = h_allg$h1,
  verbal = h_verbal$h1
)

h2_list <- list(
  allg = h_allg$h2,
  verbal = h_verbal$h2
)

res_multi <- calc_cada_multi(
  dvs = c("allg", "verbal"),
  between = "condition",
  h1 = h1_list,
  h2 = h2_list,
  data = d,
  design = "between",
  method = "normal",
  alternative = "two.sided"
)

print(res_multi)
summary(res_multi)
}

