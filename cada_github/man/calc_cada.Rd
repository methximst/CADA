\encoding{UTF-8}
\name{calc_cada}
\alias{calc_cada}
\title{Eine CADA-Analyse für unabhängige Gruppen rechnen}
\usage{
calc_cada(
  dv,
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
\item{dv}{Name der abhängigen Variable als Text, z. B. \code{dv = "allg"}.}

\item{h1, h2}{Numerische Vektoren mit den erwarteten Mittelwerten für
Hypothese 1 und Hypothese 2. Die Namen der Vektoren sollten zu den Gruppen
passen, z. B. \code{c(Gruppe1 = 80, Gruppe2 = 95, Gruppe3 = 110)}.}

\item{data}{Ein Dataframe mit den Daten.}

\item{design}{Derzeit nur \code{"between"} für unabhängige Gruppen.}

\item{method}{Legt fest, welche Testvariante berechnet wird:
\code{"bootstrap"}, \code{"normal"} oder \code{"both"}.}

\item{between}{Name der Gruppierungsvariable als Text, z. B.
\code{between = "condition"}.}

\item{n_boot}{Anzahl der Bootstrap-Stichproben. Höhere Werte sind genauer,
dauern aber länger.}

\item{seed}{Optionaler Startwert für den Zufallsgenerator. Wenn ein Seed gesetzt
wird, sind Bootstrap-Ergebnisse reproduzierbar.}

\item{bootstrap_deviation}{Derzeit nur \code{"squared"}. Das Argument bleibt
erhalten, damit ältere Skripte mit \code{bootstrap_deviation = "squared"}
weiterlaufen.}

\item{deviation}{Derzeit nur \code{"squared"}.}

\item{variance}{\code{"sample"} verwendet die Stichprobenvarianz mit
Nenner \eqn{n_j - 1}. \code{"population"} verwendet den Nenner \eqn{n_j}.}

\item{alternative}{Legt fest, welcher p-Wert als zentraler p-Wert berichtet
wird. \code{"h1"} testet gerichtet, ob Hypothese 1 besser passt
(\code{criterion < 0}). \code{"h2"} testet gerichtet, ob Hypothese 2 besser
passt (\code{criterion > 0}). \code{"two.sided"} testet ungerichtet, ob eine
der beiden Hypothesen besser passt.}

\item{na.rm}{Wenn \code{TRUE}, werden unvollständige Zeilen entfernt.}

\item{reverse_bootstrap}{Spezialoption für die Bootstrap-Nullverteilung. In der
Regel kann diese Option auf \code{NULL} bleiben.}
}
\value{
Ein Objekt der Klasse \code{"cada"}. Es enthält unter anderem das
Vergleichskriterium, die Abweichungssummen, p-Werte, Varianzen, die neue
Effektgröße \code{cada_effect_group}, eine Ergebnistabelle und bei
Bootstrap-Analysen die Bootstrap-Verteilung.
}
\description{
\code{calc_cada()} vergleicht zwei Hypothesen über erwartete Gruppenmittelwerte.
Die Analyse ist für unabhängige Gruppen und quadratische Abweichungen
implementiert.
}
\details{
\strong{CADA-Kriterium}

Für jede Gruppe \eqn{j} werden die empirischen Mittelwerte \eqn{\bar{x}_j} mit
den Hypothesenwerten \eqn{h_{1j}} und \eqn{h_{2j}} verglichen:

\deqn{
D_1 = \sum_{j=1}^{J} n_j (\bar{x}_j - h_{1j})^2
}

\deqn{
D_2 = \sum_{j=1}^{J} n_j (\bar{x}_j - h_{2j})^2
}

Das im Paket ausgegebene Kriterium lautet:

\deqn{
K = D_1 - D_2
}

\itemize{
  \item \eqn{K < 0}: Hypothese 1 passt besser.
  \item \eqn{K > 0}: Hypothese 2 passt besser.
  \item \eqn{K = 0}: Beide Hypothesen passen gleich gut.
}

\strong{Neue Effektgröße}

Zusätzlich wird die standardisierte CADA-Effektgröße für quadratische
Abweichungen berechnet:

\deqn{
V_{\mathrm{Gruppe}} = \sum_{j=1}^{J} n_j s_j^2
}

mit

\deqn{
s_j^2 =
\frac{1}{n_j - 1}
\sum_{i=1}^{n_j}
(x_{ij} - \bar{x}_j)^2
}

für \code{variance = "sample"}. Die Effektgröße lautet:

\deqn{
\Delta^{(2)}_{\mathrm{CADA,Gruppe}}
=
\frac{D_2 - D_1}{V_{\mathrm{Gruppe}}}
}

und wird als \code{cada_effect_group} ausgegeben. Positive Werte bedeuten, dass
Hypothese 1 besser passt; negative Werte bedeuten, dass Hypothese 2 besser
passt.
}
\examples{
library(cada)

d_between <- simulate_cada_between_data(seed = 123)
h_between <- make_cada_between_hypotheses("allgh1vsh2")

res_between <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h_between$h1,
  h2 = h_between$h2,
  data = d_between,
  design = "between",
  method = "both",
  n_boot = 100,
  seed = 123,
  alternative = "two.sided"
)

print(res_between)
summary(res_between)
plot(res_between)

res_between$cada_effect_group
}

