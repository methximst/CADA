\encoding{UTF-8}
\name{make_cada_between_hypotheses}
\alias{make_cada_between_hypotheses}
\title{Beispielhypothesen für Between-Daten erzeugen}
\usage{
make_cada_between_hypotheses(
  pattern = c("allgh1vsh2", "verbalh1vsh2", "mathh1vsh2", "othersh1vsh2")
)
}
\arguments{
\item{pattern}{Name des gewünschten Beispielmusters.}
}
\value{
Eine Liste mit zwei numerischen Vektoren: \code{h1} für Hypothese 1 und
\code{h2} für Hypothese 2.
}
\description{
Erzeugt Beispielhypothesen für drei unabhängige Gruppen. Die Namen der
Hypothesenwerte passen zu den Gruppen \code{Gruppe1}, \code{Gruppe2} und
\code{Gruppe3}.
}
\details{
Diese Funktion ist vor allem zum Lernen und Testen gedacht. Für eigene Daten
können Sie Hypothesenwerte auch direkt selbst schreiben, z. B.
\code{c(Gruppe1 = 80, Gruppe2 = 95, Gruppe3 = 110)}.
}
\examples{
library(cada)

h <- make_cada_between_hypotheses("allgh1vsh2")
h

d <- simulate_cada_between_data(seed = 123)

calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h$h1,
  h2 = h$h2,
  data = d,
  design = "between",
  method = "normal"
)
}
