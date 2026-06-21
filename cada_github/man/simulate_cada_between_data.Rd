\encoding{UTF-8}
\name{simulate_cada_between_data}
\alias{simulate_cada_between_data}
\title{Beispieldaten für Between-Analysen erzeugen}
\usage{
simulate_cada_between_data(n_per_group = 40L, seed = 123)
}
\arguments{
\item{n_per_group}{Anzahl der Beobachtungen pro Gruppe.}
\item{seed}{Optionaler Seed, damit dieselben Zufallsdaten erneut erzeugt werden
können.}
}
\value{
Ein Dataframe mit einer Gruppierungsvariable \code{condition} und den vier
abhängigen Variablen \code{allg}, \code{verbal}, \code{math} und
\code{others}.
}
\description{
Erzeugt einen kleinen Beispieldatensatz für unabhängige Gruppen. Die Daten sind
bereits so aufgebaut, dass sie direkt mit \code{\link{calc_cada}} verwendet
werden können.
}
\examples{
library(cada)

d <- simulate_cada_between_data(seed = 123)
head(d)

h <- make_cada_between_hypotheses("allgh1vsh2")

res <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h$h1,
  h2 = h$h2,
  data = d,
  design = "between",
  method = "normal"
)

print(res)
}
