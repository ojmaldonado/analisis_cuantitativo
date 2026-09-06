# Documentos y scripts para análizar violencia intrafamiliar y de género en Bogotá

Bajar la base de datos completa en: (https://datosabiertos.bogota.gov.co/dataset/numero-de-casos-de-violencia-intrafamiliar)

# Análisis descriptivo de violencia intrafamiliar

**Tipos de violencia por edad, sexo, localidad y relación con el agresor**

- **Fuente:** Subsistema de vigilancia epidemiológica de la violencia intrafamiliar y de género (SIVIM). Bogotá D.C.
- **Serie:** 2013–2026 · 492.837 casos notificados
- **Insumos:** `osb_saludmental-vintrafamiliar.csv` (datos) y `metadato-osb_v-intrafamiliar.xlsx` (diccionario)

---

## Nota metodológica

El tipo de violencia **no** viene como una sola variable. Según el diccionario de metadatos, cada tipo (emocional, física, sexual, económica, negligencia, abandono) se registra en su propia columna `lugocurrencia*`, que guarda el **lugar de ocurrencia** del hecho. Un caso presenta un tipo de violencia cuando ese lugar es distinto de `"Sin dato"`.

De ahí se derivan dos consecuencias para el análisis:

1. **Un mismo caso puede acumular varios tipos** de violencia simultáneamente (co-ocurrencia). En estos datos la mayoría de casos registra 2 tipos, y algunos hasta 6.
2. Para describir "tipos de violencia" se debe reestructurar la base a **formato largo**: una fila por cada par *(caso × tipo efectivamente presente)*. Sólo así los conteos por tipo son correctos.

> La violencia **emocional** aparece en ~99,7% de los casos, por lo que domina cualquier total absoluto. La variación relevante entre grupos se aprecia mejor en los otros cinco tipos y en las vistas de **porcentaje dentro de cada grupo**.

---

## 0. Paquetes

```r
paquetes <- c("data.table", "dplyr", "tidyr", "readr",
              "ggplot2", "forcats", "stringr", "scales")

nuevos <- paquetes[!paquetes %in% rownames(installed.packages())]
if (length(nuevos) > 0) install.packages(nuevos)

library(data.table)   # lectura rápida de archivos grandes (~110 MB)
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(forcats)
library(stringr)
library(scales)

options(scipen = 999)  # evita notación científica en las tablas
```

## 1. Parámetros

Ajuste la ruta a los datos y el manejo de las categorías sin información demográfica.

```r
ruta_csv     <- "osb_saludmental-vintrafamiliar.csv"  # <-- ruta a los datos
dir_salidas  <- "resultados"                            # carpeta de exportación

# Si quiere excluir del análisis las categorías sin información demográfica
# ("Sin dato", localidad vacía o desconocida), déjelo en TRUE.
excluir_sindato <- TRUE

if (!dir.exists(dir_salidas)) dir.create(dir_salidas, recursive = TRUE)
```

## 2. Lectura

El archivo es UTF-8 con BOM y está separado por `;`. `fread` lo maneja bien y rápido.

```r
vif <- fread(
  ruta_csv,
  sep      = ";",
  encoding = "UTF-8",
  na.strings = c("", "NA")
) |> as_tibble()

cat("Registros leídos:", format(nrow(vif), big.mark = "."), "\n")
cat("Variables:", ncol(vif), "\n\n")
```

## 3. Limpieza y recodificación

### 3.1 Grupo de edad como factor ordenado

Se corrige una inconsistencia de captura (`"14 - 17 años"` → `"De 14 - 17 años"`) y se ordena el grupo de edad por ciclo de vida. Los valores fuera de la malla estándar (p. ej. `"De 30 - 34 años"`, 2 casos) quedan como `NA` para no romper el orden y se reportan.

```r
niveles_edad <- c("Menor 1 año", "De 1 - 5 años", "De 6 - 13 años",
                  "De 14 - 17 años", "De 18 - 26 años", "De 27 - 44 años",
                  "De 45 - 59 años", "De 60 - 69 años", "De 70 - 79 años",
                  "De 80 - 99 años", "De 100 - 105 años")

vif <- vif |>
  mutate(
    grupoedad = str_squish(grupoedad),
    grupoedad = if_else(grupoedad == "14 - 17 años",
                        "De 14 - 17 años", grupoedad),
    grupoedad = factor(grupoedad, levels = niveles_edad, ordered = TRUE),

    sexo = factor(str_squish(sexo)),

    NOMBRE_LOCALIDAD = str_squish(NOMBRE_LOCALIDAD),
    NOMBRE_LOCALIDAD = if_else(is.na(NOMBRE_LOCALIDAD) | NOMBRE_LOCALIDAD == "",
                               "Sin dato", NOMBRE_LOCALIDAD),

    relacion_agresor = str_squish(relacion_agresor),
    relacion_agresor = if_else(is.na(relacion_agresor) | relacion_agresor == "",
                               "Sin dato", relacion_agresor)
  )

n_edad_na <- sum(is.na(vif$grupoedad))
if (n_edad_na > 0)
  cat("Aviso de calidad:", n_edad_na,
      "registro(s) con grupo de edad no estándar -> NA.\n\n")
```

### 3.2 Indicadores de tipo de violencia

Un tipo está presente si su columna de lugar **no** es `"Sin dato"`.

```r
cols_lugar <- c(
  Emocional   = "lugocurrenciaemocional",
  "Física"    = "lugocurrenciafisica",
  Sexual      = "lugocurrenciasexual",
  "Económica" = "lugocurrenciaeconomica",
  Negligencia = "lugocurrencianegligencia",
  Abandono    = "lugocurrenciaabandono"
)

# Crea columnas lógicas viol_Emocional, viol_Física, ... (TRUE / FALSE)
for (i in seq_along(cols_lugar)) {
  col_orig <- cols_lugar[i]
  vif[[paste0("viol_", names(cols_lugar)[i])]] <-
    !is.na(vif[[col_orig]]) & vif[[col_orig]] != "Sin dato"
}

# Nº de tipos de violencia por caso (medida de co-ocurrencia)
vif <- vif |>
  mutate(n_tipos = rowSums(across(starts_with("viol_"))))
```

### 3.3 Base en formato largo

Una fila por *(caso × tipo presente)*.

```r
orden_tipos <- names(cols_lugar)

vif_largo <- vif |>
  select(ano, grupoedad, sexo, NOMBRE_LOCALIDAD, relacion_agresor,
         starts_with("viol_")) |>
  pivot_longer(
    cols = starts_with("viol_"),
    names_to = "tipo_violencia",
    names_prefix = "viol_",
    values_to = "presente"
  ) |>
  filter(presente) |>
  mutate(tipo_violencia = factor(tipo_violencia, levels = orden_tipos)) |>
  select(-presente)

cat("Eventos (caso x tipo de violencia):",
    format(nrow(vif_largo), big.mark = "."), "\n\n")
```

### 3.4 Filtro opcional de categorías sin dato

```r
if (excluir_sindato) {
  vif_largo_an <- vif_largo |>
    filter(!is.na(grupoedad),
           !NOMBRE_LOCALIDAD %in% c("Sin dato", "Localidad Desconocida"),
           relacion_agresor != "Sin dato")
} else {
  vif_largo_an <- vif_largo
}
```

## 4. Función auxiliar de resumen

Cuenta eventos por `tipo_violencia` × una variable, con el porcentaje **dentro de cada categoría** de esa variable (perfil de tipos por grupo).

```r
resumen_tipo <- function(datos, variable) {
  datos |>
    filter(!is.na({{ variable }})) |>
    count({{ variable }}, tipo_violencia, name = "casos") |>
    group_by({{ variable }}) |>
    mutate(pct_en_grupo = casos / sum(casos)) |>
    ungroup() |>
    arrange({{ variable }}, desc(casos))
}
```

## 5. Análisis descriptivo

### 5.0 Panorama general

```r
cat("========== PANORAMA GENERAL ==========\n")
cat("Total de casos:", format(nrow(vif), big.mark = "."), "\n")
cat("Periodo:", min(vif$ano), "-", max(vif$ano), "\n\n")

# Casos por tipo de violencia (un caso puede sumar a varios tipos)
tab_tipos <- vif_largo |>
  count(tipo_violencia, name = "casos") |>
  mutate(pct_sobre_casos = casos / nrow(vif)) |>
  arrange(desc(casos))
print(tab_tipos)

# Distribución de la co-ocurrencia (nº de tipos por caso)
tab_coocurrencia <- vif |>
  count(n_tipos, name = "casos") |>
  mutate(pct = casos / sum(casos))
cat("\nCo-ocurrencia (número de tipos por caso):\n")
print(tab_coocurrencia)
```

### 5.1 Tipo de violencia × sexo

```r
tab_sexo <- resumen_tipo(vif_largo_an, sexo)
print(tab_sexo)
```

### 5.2 Tipo de violencia × grupo de edad

```r
tab_edad <- resumen_tipo(vif_largo_an, grupoedad)
print(tab_edad, n = Inf)
```

### 5.3 Tipo de violencia × localidad

```r
tab_localidad <- resumen_tipo(vif_largo_an, NOMBRE_LOCALIDAD)
print(tab_localidad, n = Inf)
```

### 5.4 Tipo de violencia × relación con el agresor

```r
tab_relacion <- resumen_tipo(vif_largo_an, relacion_agresor)
print(tab_relacion, n = Inf)
```

### 5.5 Tendencia por año

```r
tab_anio <- vif_largo |>
  count(ano, tipo_violencia, name = "casos")
```

## 6. Exportación de tablas

```r
write_csv(tab_tipos,        file.path(dir_salidas, "01_tipos_totales.csv"))
write_csv(tab_coocurrencia, file.path(dir_salidas, "02_coocurrencia.csv"))
write_csv(tab_sexo,         file.path(dir_salidas, "03_tipo_x_sexo.csv"))
write_csv(tab_edad,         file.path(dir_salidas, "04_tipo_x_edad.csv"))
write_csv(tab_localidad,    file.path(dir_salidas, "05_tipo_x_localidad.csv"))
write_csv(tab_relacion,     file.path(dir_salidas, "06_tipo_x_relacion.csv"))
write_csv(tab_anio,         file.path(dir_salidas, "07_tipo_x_anio.csv"))
cat("\nTablas exportadas a la carpeta:", dir_salidas, "\n")
```

## 7. Visualizaciones (`ggplot2`)

```r
tema_vif <- theme_minimal(base_size = 12) +
  theme(plot.title    = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey30"),
        legend.position = "bottom")

guardar <- function(plot, nombre, w = 9, h = 6) {
  ggsave(file.path(dir_salidas, nombre), plot, width = w, height = h, dpi = 300)
}
```

### 7.1 Casos por tipo de violencia

```r
g1 <- ggplot(tab_tipos,
             aes(x = fct_reorder(tipo_violencia, casos), y = casos)) +
  geom_col(fill = "#2c7fb8") +
  geom_text(aes(label = comma(casos)), hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Casos por tipo de violencia intrafamiliar",
       subtitle = "Un caso puede presentar más de un tipo (co-ocurrencia)",
       x = NULL, y = "Número de casos") +
  tema_vif
guardar(g1, "g1_tipos_totales.png")
```

### 7.2 Tipo × sexo (% dentro de cada sexo)

```r
g2 <- ggplot(tab_sexo,
             aes(x = tipo_violencia, y = pct_en_grupo, fill = sexo)) +
  geom_col(position = position_dodge(width = 0.8)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("Mujeres" = "#d95f0e", "Hombres" = "#2c7fb8")) +
  labs(title = "Perfil de tipos de violencia según sexo de la víctima",
       subtitle = "Porcentaje dentro de cada sexo",
       x = NULL, y = "% de eventos", fill = "Sexo") +
  tema_vif +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
guardar(g2, "g2_tipo_x_sexo.png")
```

### 7.3 Mapa de calor: tipo × grupo de edad

```r
g3 <- ggplot(tab_edad,
             aes(x = tipo_violencia, y = fct_rev(grupoedad), fill = pct_en_grupo)) +
  geom_tile(color = "white") +
  geom_text(aes(label = percent(pct_en_grupo, accuracy = 1)), size = 3) +
  scale_fill_viridis_c(labels = percent_format(accuracy = 1), option = "C") +
  labs(title = "Tipo de violencia por grupo de edad",
       subtitle = "Porcentaje de eventos dentro de cada grupo de edad",
       x = NULL, y = NULL, fill = "% en edad") +
  tema_vif +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
guardar(g3, "g3_tipo_x_edad.png", w = 9, h = 7)
```

### 7.4 Tipo × localidad (composición)

```r
g4 <- ggplot(tab_localidad,
             aes(x = fct_reorder(NOMBRE_LOCALIDAD, casos, sum),
                 y = casos, fill = tipo_violencia)) +
  geom_col(position = "fill") +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Composición de tipos de violencia por localidad",
       subtitle = "Participación de cada tipo dentro de la localidad",
       x = NULL, y = "% de eventos", fill = "Tipo") +
  tema_vif
guardar(g4, "g4_tipo_x_localidad.png", w = 9, h = 8)
```

### 7.5 Tipo × relación con el agresor (top 12)

```r
top_relaciones <- vif_largo_an |>
  count(relacion_agresor, name = "n") |>
  slice_max(n, n = 12) |>
  pull(relacion_agresor)

g5 <- tab_relacion |>
  filter(relacion_agresor %in% top_relaciones) |>
  ggplot(aes(x = fct_reorder(relacion_agresor, casos, sum),
             y = casos, fill = tipo_violencia)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Tipos de violencia según relación con el agresor",
       subtitle = "12 relaciones más frecuentes",
       x = NULL, y = "Número de eventos", fill = "Tipo") +
  tema_vif
guardar(g5, "g5_tipo_x_relacion.png", w = 9, h = 7)
```

### 7.6 Tendencia anual por tipo

```r
g6 <- ggplot(tab_anio, aes(x = ano, y = casos, color = tipo_violencia)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.6) +
  scale_y_continuous(labels = comma) +
  scale_color_brewer(palette = "Dark2") +
  labs(title = "Evolución de los tipos de violencia intrafamiliar",
       subtitle = paste0("Bogotá, ", min(vif$ano), "–", max(vif$ano)),
       x = NULL, y = "Número de eventos", color = "Tipo") +
  tema_vif
guardar(g6, "g6_tendencia_anual.png")
```

---

## Salidas generadas

En la carpeta `resultados/`:

| Archivo | Contenido |
|---|---|
| `01_tipos_totales.csv` | Casos por tipo de violencia |
| `02_coocurrencia.csv` | Nº de tipos por caso |
| `03_tipo_x_sexo.csv` | Tipo × sexo |
| `04_tipo_x_edad.csv` | Tipo × grupo de edad |
| `05_tipo_x_localidad.csv` | Tipo × localidad |
| `06_tipo_x_relacion.csv` | Tipo × relación con el agresor |
| `07_tipo_x_anio.csv` | Tipo × año |
| `g1`–`g6 .png` | Gráficos correspondientes (300 dpi) |
