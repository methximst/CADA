\encoding{UTF-8}
\name{cada-package}
\alias{cada-package}
\docType{package}
\title{CADA: Competitive Absolute/Quadratic Deviation Analysis}
\description{
Das Paket \pkg{cada} vergleicht zwei vorab spezifizierte Hypothesen über
Gruppenmittelwerte. Diese Version ist auf unabhängige Gruppen
(\code{design = "between"}) und quadratische Abweichungen fokussiert.
}
\details{
Der Kern der Analyse ist der Vergleich zweier Abweichungssummen:

\deqn{
D_1 = \sum_{j=1}^{J} n_j (\bar{x}_j - h_{1j})^2
}

\deqn{
D_2 = \sum_{j=1}^{J} n_j (\bar{x}_j - h_{2j})^2
}

Das Paket berichtet das Kriterium \eqn{K = D_1 - D_2}. Negative Werte sprechen
für Hypothese 1, positive Werte für Hypothese 2.

Zusätzlich wird eine standardisierte Effektgröße ausgegeben:

\deqn{
\Delta^{(2)}_{\mathrm{CADA,Gruppe}}
=
\frac{D_2 - D_1}{\sum_{j=1}^{J} n_j s_j^2}
}

Diese Effektgröße bezieht die Passungsdifferenz auf die gewichtete empirische
Gruppenvarianz. Positive Werte bedeuten bessere Passung von Hypothese 1,
negative Werte bessere Passung von Hypothese 2.

Wichtige Funktionen:

\itemize{
  \item \code{\link{calc_cada}}: Eine CADA-Analyse für eine abhängige Variable.
  \item \code{\link{calc_cada_multi}}: Mehrere abhängige Variablen auf einmal.
  \item \code{\link{simulate_cada_between_data}}: Beispieldaten simulieren.
  \item \code{\link{make_cada_between_hypotheses}}: Beispielhypothesen erzeugen.
}
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
