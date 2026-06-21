# cada

`cada` vergleicht zwei vorab festgelegte Hypothesen über Gruppenmittelwerte.
Das Paket ist für Between-Designs mit unabhängigen Gruppen ausgelegt und nutzt
quadratische Abweichungen.

## Installation aus einer lokalen Datei

```r
install.packages("cada.tar.gz", repos = NULL, type = "source")
library(cada)
```

## Installation aus GitHub

Nach dem Hochladen auf GitHub kann das Paket zum Beispiel so installiert
werden:

```r
install.packages("remotes")
remotes::install_github("DEIN_GITHUB_NAME/cada")
library(cada)
```

Ersetze `DEIN_GITHUB_NAME` durch den Namen deines GitHub-Accounts.

## Beispiel

```r
library(cada)

d <- simulate_cada_between_data(seed = 123)
h <- make_cada_between_hypotheses("allgh1vsh2")

res <- calc_cada(
  dv = "allg",
  between = "condition",
  h1 = h$h1,
  h2 = h$h2,
  data = d,
  design = "between",
  method = "both",
  n_boot = 1000,
  seed = 123,
  alternative = "two.sided"
)

print(res)
summary(res)
plot(res)
```

## Interpretation

Das zentrale Vergleichskriterium lautet:

```text
criterion = D1 - D2
```

- `criterion < 0`: Hypothese 1 passt besser.
- `criterion > 0`: Hypothese 2 passt besser.
- `criterion == 0`: Beide Hypothesen passen gleich gut.

## Effektgröße

Die standardisierte CADA-Effektgröße für quadratische Abweichungen wird als
`cada_effect_group` ausgegeben:

```text
cada_effect_group = (D2 - D1) / sum(n_j * s_j^2)
```

Dabei ist `s_j^2` die empirische Varianz in Gruppe `j`. Positive Werte bedeuten,
dass Hypothese 1 stärker unterstützt wird; negative Werte bedeuten, dass
Hypothese 2 stärker unterstützt wird.

## Wichtigste Funktionen

- `calc_cada()`: CADA-Analyse für eine abhängige Variable
- `calc_cada_multi()`: CADA-Analyse für mehrere abhängige Variablen
- `simulate_cada_between_data()`: simulierte Beispieldaten
- `make_cada_between_hypotheses()`: Beispielhypothesen

