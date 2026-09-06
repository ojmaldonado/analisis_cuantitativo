# =============================================================================
# ANÁLISIS DESCRIPTIVO DE VIOLENCIA INTRAFAMILIAR
# Tipos de violencia por edad, sexo, localidad y relación con el agresor
# -----------------------------------------------------------------------------
# Fuente: Subsistema de vigilancia epidemiológica de la violencia intrafamiliar
#         y de género (SIVIM). Serie 2013–2026. Bogotá D.C.
#
# Nota metodológica clave (ver diccionario 'metadato-osb_v-intrafamiliar.xlsx'):
#   El tipo de violencia NO viene como una sola variable. Cada tipo se registra
#   en su propia columna 'lugocurrencia*', que guarda el LUGAR de ocurrencia.
#   Un caso presenta un tipo de violencia cuando ese lugar es distinto de
#   "Sin dato". Por tanto, un mismo caso puede tener varios tipos simultáneos
#   (co-ocurrencia). Antes de describir se reestructura la base a formato largo:
#   una fila por (caso x tipo de violencia efectivamente presente).
# =============================================================================


# -----------------------------------------------------------------------------
# 0. PAQUETES  (instala automáticamente los que falten)
# -----------------------------------------------------------------------------
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


# -----------------------------------------------------------------------------
# 1. PARÁMETROS  (ajústelos a su equipo)
# -----------------------------------------------------------------------------
ruta_csv     <- "osb_saludmental-vintrafamiliar.csv"  # <-- ruta a los datos
dir_salidas  <- "resultados"                            # carpeta de exportación

# Si quiere excluir del análisis las categorías sin información demográfica
# ("Sin dato", localidad vacía o desconocida), déjelo en TRUE.
excluir_sindato <- TRUE

if (!dir.exists(dir_salidas)) dir.create(dir_salidas, recursive = TRUE)


# -----------------------------------------------------------------------------
# 2. LECTURA
# -----------------------------------------------------------------------------
# El archivo es UTF-8 con BOM, separado por ';'. fread lo maneja bien y rápido.
vif <- fread(
  ruta_csv,
  sep      = ";",
  encoding = "UTF-8",
  na.strings = c("", "NA")
) |> as_tibble()

cat("Registros leídos:", format(nrow(vif), big.mark = "."), "\n")
cat("Variables:", ncol(vif), "\n\n")


# -----------------------------------------------------------------------------
# 3. LIMPIEZA Y RECODIFICACIÓN
# -----------------------------------------------------------------------------

# 3.1 Niveles canónicos y orden del grupo de edad ----------------------------
#     (así los gráficos y tablas quedan ordenados por ciclo de vida)
niveles_edad <- c("Menor 1 año", "De 1 - 5 años", "De 6 - 13 años",
                  "De 14 - 17 años", "De 18 - 26 años", "De 27 - 44 años",
                  "De 45 - 59 años", "De 60 - 69 años", "De 70 - 79 años",
                  "De 80 - 99 años", "De 100 - 105 años")

vif <- vif |>
  mutate(
    # Corrige una inconsistencia de captura ("14 - 17 años" -> "De 14 - 17 años")
    grupoedad = str_squish(grupoedad),
    grupoedad = if_else(grupoedad == "14 - 17 años",
                        "De 14 - 17 años", grupoedad),
    # Cualquier valor fuera de la malla estándar (p. ej. "De 30 - 34 años",
    # 2 casos) queda como NA para no romper el orden; se reporta abajo.
    grupoedad = factor(grupoedad, levels = niveles_edad, ordered = TRUE),

    sexo = factor(str_squish(sexo)),

    NOMBRE_LOCALIDAD = str_squish(NOMBRE_LOCALIDAD),
    NOMBRE_LOCALIDAD = if_else(is.na(NOMBRE_LOCALIDAD) | NOMBRE_LOCALIDAD == "",
                               "Sin dato", NOMBRE_LOCALIDAD),

    relacion_agresor = str_squish(relacion_agresor),
    relacion_agresor = if_else(is.na(relacion_agresor) | relacion_agresor == "",
                               "Sin dato", relacion_agresor)
  )

# Reporte de calidad: edades no estándar
n_edad_na <- sum(is.na(vif$grupoedad))
if (n_edad_na > 0)
  cat("Aviso de calidad:", n_edad_na,
      "registro(s) con grupo de edad no estándar -> NA.\n\n")


# 3.2 Construcción de los indicadores de tipo de violencia --------------------
#     Un tipo está presente si su columna de lugar NO es "Sin dato".
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


# 3.3 Base en formato LARGO: una fila por (caso x tipo presente) --------------
orden_tipos <- names(cols_lugar)   # para ordenar factor 'tipo_violencia'

vif_largo <- vif |>
  select(ano, grupoedad, sexo, NOMBRE_LOCALIDAD, relacion_agresor,
         starts_with("viol_")) |>
  pivot_longer(
    cols = starts_with("viol_"),
    names_to = "tipo_violencia",
    names_prefix = "viol_",
    values_to = "presente"
  ) |>
  filter(presente) |>                       # sólo tipos efectivamente presentes
  mutate(tipo_violencia = factor(tipo_violencia, levels = orden_tipos)) |>
  select(-presente)

cat("Eventos (caso x tipo de violencia):",
    format(nrow(vif_largo), big.mark = "."), "\n\n")


# 3.4 (Opcional) filtrar categorías sin información demográfica ----------------
if (excluir_sindato) {
  vif_largo_an <- vif_largo |>
    filter(!is.na(grupoedad),
           !NOMBRE_LOCALIDAD %in% c("Sin dato", "Localidad Desconocida"),
           relacion_agresor != "Sin dato")
} else {
  vif_largo_an <- vif_largo
}


# -----------------------------------------------------------------------------
# 4. FUNCIÓN AUXILIAR DE RESUMEN
#    Cuenta eventos por 'tipo_violencia' x una variable, con % dentro de cada
#    categoría de esa variable (perfil de tipos por grupo).
# -----------------------------------------------------------------------------
resumen_tipo <- function(datos, variable) {
  datos |>
    filter(!is.na({{ variable }})) |>
    count({{ variable }}, tipo_violencia, name = "casos") |>
    group_by({{ variable }}) |>
    mutate(pct_en_grupo = casos / sum(casos)) |>
    ungroup() |>
    arrange({{ variable }}, desc(casos))
}


# -----------------------------------------------------------------------------
# 5. ANÁLISIS DESCRIPTIVO
# -----------------------------------------------------------------------------

## 5.0 Panorama general -------------------------------------------------------
cat("========== PANORAMA GENERAL ==========\n")
cat("Total de casos:", format(nrow(vif), big.mark = "."), "\n")
cat("Periodo:", min(vif$ano), "-", max(vif$ano), "\n\n")

# Casos por tipo de violencia (un caso puede sumar a varios tipos)
tab_tipos <- vif_largo |>
  count(tipo_violencia, name = "casos") |>
  mutate(pct_sobre_casos = casos / nrow(vif)) |>   # % de casos que presentan el tipo
  arrange(desc(casos))
print(tab_tipos)

# Distribución de la co-ocurrencia (nº de tipos por caso)
tab_coocurrencia <- vif |>
  count(n_tipos, name = "casos") |>
  mutate(pct = casos / sum(casos))
cat("\nCo-ocurrencia (número de tipos por caso):\n")
print(tab_coocurrencia)


## 5.1 Tipo de violencia x SEXO ----------------------------------------------
cat("\n========== TIPO x SEXO ==========\n")
tab_sexo <- resumen_tipo(vif_largo_an, sexo)
print(tab_sexo)


## 5.2 Tipo de violencia x GRUPO DE EDAD -------------------------------------
cat("\n========== TIPO x GRUPO DE EDAD ==========\n")
tab_edad <- resumen_tipo(vif_largo_an, grupoedad)
print(tab_edad, n = Inf)


## 5.3 Tipo de violencia x LOCALIDAD -----------------------------------------
cat("\n========== TIPO x LOCALIDAD ==========\n")
tab_localidad <- resumen_tipo(vif_largo_an, NOMBRE_LOCALIDAD)
print(tab_localidad, n = Inf)


## 5.4 Tipo de violencia x RELACIÓN CON EL AGRESOR ---------------------------
cat("\n========== TIPO x RELACIÓN CON EL AGRESOR ==========\n")
tab_relacion <- resumen_tipo(vif_largo_an, relacion_agresor)
print(tab_relacion, n = Inf)


## 5.5 (Extra) Tendencia por año ---------------------------------------------
tab_anio <- vif_largo |>
  count(ano, tipo_violencia, name = "casos")


# -----------------------------------------------------------------------------
# 6. EXPORTACIÓN DE TABLAS
# -----------------------------------------------------------------------------
write_csv(tab_tipos,        file.path(dir_salidas, "01_tipos_totales.csv"))
write_csv(tab_coocurrencia, file.path(dir_salidas, "02_coocurrencia.csv"))
write_csv(tab_sexo,         file.path(dir_salidas, "03_tipo_x_sexo.csv"))
write_csv(tab_edad,         file.path(dir_salidas, "04_tipo_x_edad.csv"))
write_csv(tab_localidad,    file.path(dir_salidas, "05_tipo_x_localidad.csv"))
write_csv(tab_relacion,     file.path(dir_salidas, "06_tipo_x_relacion.csv"))
write_csv(tab_anio,         file.path(dir_salidas, "07_tipo_x_anio.csv"))
cat("\nTablas exportadas a la carpeta:", dir_salidas, "\n")


# -----------------------------------------------------------------------------
# 7. VISUALIZACIONES  (ggplot2)
# -----------------------------------------------------------------------------
tema_vif <- theme_minimal(base_size = 12) +
  theme(plot.title    = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey30"),
        legend.position = "bottom")

guardar <- function(plot, nombre, w = 9, h = 6) {
  ggsave(file.path(dir_salidas, nombre), plot, width = w, height = h, dpi = 300)
}

## 7.1 Casos por tipo de violencia -------------------------------------------
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

## 7.2 Tipo x sexo (% dentro de cada sexo) -----------------------------------
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

## 7.3 Mapa de calor Tipo x Grupo de edad (% dentro de cada edad) ------------
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

## 7.4 Tipo x localidad (barras apiladas por composición) --------------------
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

## 7.5 Tipo x relación con el agresor (top relaciones) -----------------------
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

## 7.6 Tendencia anual por tipo ----------------------------------------------
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

cat("Gráficos exportados a la carpeta:", dir_salidas, "\n")
cat("\n--- Análisis finalizado ---\n")
