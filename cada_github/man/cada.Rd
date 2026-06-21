\encoding{UTF-8}
\name{cada}
\alias{cada}
\title{CADA-Hilfe und Paketüberblick}
\usage{
cada()
}
\description{
Öffnet eine kurze Übersicht über das Paket \pkg{cada}. Das Paket vergleicht
zwei vorab festgelegte Hypothesen über Gruppenmittelwerte in unabhängigen
Gruppen.
}
\details{
Diese Version des Pakets konzentriert sich auf Between-Designs und quadratische
Abweichungen.

Das zentrale Kriterium lautet:

\preformatted{
D1 = sum_j n_j * (mean_j - h1_j)^2
D2 = sum_j n_j * (mean_j - h2_j)^2
K  = D1 - D2
}

Interpretation:

\itemize{
  \item \code{K < 0}: Hypothese 1 passt besser.
  \item \code{K > 0}: Hypothese 2 passt besser.
  \item \code{K = 0}: Beide Hypothesen passen gleich gut.
}

Die standardisierte CADA-Effektgröße lautet:

\preformatted{
cada_effect_group = (D2 - D1) / sum_j(n_j * s_j^2)
}

Positive Werte sprechen für Hypothese 1, negative Werte für Hypothese 2.

Die wichtigste Analysefunktion ist \code{\link{calc_cada}}. Für mehrere
abhängige Variablen kann \code{\link{calc_cada_multi}} verwendet werden.
}
\value{
\code{cada()} öffnet diese Hilfeseite und gibt unsichtbar \code{NULL} zurück.
}
\examples{
library(cada)

d <- simulate_cada_between_data(seed = 123)
h <- make_cada_between_hypotheses("allgh1vsh2")

res <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h$h1,
  h2 = h$h2,
  data = d,
  method = "both",
  n_boot = 100,
  seed = 123
)

summary(res)
}

