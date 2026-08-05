# "Taller · W.E.B. Du Bois y el análisis cuantitativo de la sociedad"
Ingreso, costo de vida y la Ley de Engel: de Atlanta (1900) a Colombia.
Curso de Análisis Cuantitativo — ESPI, Universidad del Rosario"

# Presentación

Solemos contar la historia del análisis cuantitativo de la sociedad a partir de
Quetelet, Galton o Pearson: una estadística que nace ligada a la medición de "lo
normal" y, con frecuencia, al proyecto eugenésico. Este taller propone otra
genealogía. **W.E.B. Du Bois (1868–1963)** fue uno de los primeros sociólogos en
producir conocimiento social a partir de datos empíricos sistemáticos —encuestas,
censos, presupuestos familiares, cartografía— y en usar la **visualización de
datos** como argumento público.

En *The Philadelphia Negro* (1899) y en los *Atlanta University Studies*, Du Bois
trató los hechos sociales como medibles, en un momento en que las explicaciones
de la desigualdad racial eran especulativas o abiertamente biologicistas. Para
la **Exposición Universal de París de 1900** ("The Exhibit of American Negroes"),
Du Bois y sus estudiantes de Atlanta University elaboraron a mano decenas de
gráficos —los hoy célebres *data portraits*— para mostrar, ante un público
internacional, las condiciones de vida de la población afroamericana con rigor y
dignidad.

Su aporte al análisis cuantitativo puede resumirse en tres puntos que
trabajaremos en la sesión:

1. **Empirismo riguroso al servicio de una crítica.** Du Bois cuantifica para
   *refutar* el racismo científico, no para confirmarlo. Los números son
   evidencia dentro de un argumento sobre la estructura de la desigualdad.
2. **Datos + estructura social.** No presenta cifras "neutras": las lee a la luz
   de la raza y la clase. La medición está *situada*.
3. **La visualización como razonamiento.** El diseño gráfico es parte del
   argumento, no su decoración.

Esto desactiva la falsa oposición según la cual "lo cuantitativo" sería
positivista y apolítico y "lo cualitativo" crítico. Du Bois muestra que el
análisis cuantitativo puede ser **crítico, reflexivo y situado** —una idea que
conecta directamente con los estudios de ciencia y tecnología (STS) y con los
métodos digitales.

## Objetivos de aprendizaje

Al terminar el taller cada participante podrá:

- Explicar por qué Du Bois es una referencia fundacional del análisis cuantitativo
  y de la visualización de datos en ciencias sociales.
- Importar, ordenar y describir tablas de presupuestos/gasto en **R**.
- Identificar y visualizar la **Ley de Engel** (la proporción del gasto en
  alimentos disminuye a medida que aumenta el ingreso) y, más en general, la
  distinción entre bienes de **necesidad** y bienes **discrecionales**.
- Trasladar el marco analítico de Du Bois al caso colombiano usando datos del
  **DANE**, y discutir críticamente qué muestran y qué ocultan las categorías.

## Formato sugerido

Trabajo en **grupos de 3 personas**. Duración aproximada **90 minutos**:
Ejercicio 1 (40 min) · Ejercicio 2 (35 min) · Puesta en común (15 min).
Entregable al final del documento.

---

# Preparación del entorno

Instale (una sola vez) y cargue los paquetes. Trabajaremos con el `tidyverse`.

```{r paquetes}
# install.packages(c("tidyverse","scales"))  # <- ejecutar solo la primera vez
install.packages("readr")
install.packages("dplyr")
library(readr)    # leer datos
library(dplyr)    # transformar
library(tidyr)    # ordenar (formato largo/ancho)
library(ggplot2)  # graficar
library(forcats)  # manejo de factores
library(scales)   # formatos de ejes (%, $)
library(stringr)  # texto
```

Definimos una **paleta y un tema** inspirados en los *data portraits* de Du Bois
(fondo tipo pergamino, rojo, ocre, azul), para que nuestras figuras dialoguen con
las suyas.

```{r tema-dubois}
dubois_bg <- "#e5d5c0"
pal <- c(Vivienda = "#e02c37", Alimentos = "#f0b323", Vestido = "#98867e",
         Impuestos = "#7c1c1c", `Otros/Ahorro` = "#4b7a9d")

theme_dubois <- theme_minimal(base_size = 12) +
  theme(plot.background  = element_rect(fill = dubois_bg, color = NA),
        panel.background = element_rect(fill = dubois_bg, color = NA),
        panel.grid       = element_line(color = "#c9b79c"),
        plot.title       = element_text(face = "bold", hjust = 0.5),
        legend.position  = "bottom")
```

> **Datos del taller.** Coloque los dos archivos en una subcarpeta `datos/`
> junto a este `.Rmd`: `data_dubois.csv` y
> `distribucion_gasto_por_clase_social.csv`.

---

# Ejercicio 1 · La tabla de Du Bois: ingreso y costo de vida

Usaremos los datos de la **Lámina 31** de la Exposición de París:
*"Income and Expenditure of 150 Negro Families in Atlanta, Ga., U.S.A."*
Para 150 familias afroamericanas de Atlanta (1900), agrupadas por **clase de
ingreso anual**, la tabla registra el porcentaje del gasto destinado a
**Vivienda (Rent), Alimentos (Food), Vestido (Clothes), Impuestos (Tax)** y
**Otros gastos y Ahorro (Other)**.

```{r datos-dubois}
db <- read_csv("/Users/oscar/Downloads/data_dubois.csv", show_col_types = FALSE) |>
  rename(clase = Class, promedio = `Actual Average`,
         Vivienda = Rent, Alimentos = Food, Vestido = Clothes,
         Impuestos = Tax, `Otros/Ahorro` = Other)

# Ordenamos las clases de ingreso de menor a mayor
db$clase <- factor(db$clase, levels = db$clase)
db
```

## Paso 1 — Análisis descriptivo

**a) ¿En qué gastan más las familias, en promedio?** Pasamos la tabla a formato
largo (una fila por clase y categoría) y resumimos.

```{r desc-dubois}
db_long <- db |>
  pivot_longer(c(Vivienda, Alimentos, Vestido, Impuestos, `Otros/Ahorro`),
               names_to = "categoria", values_to = "pct")

db_long |>
  group_by(categoria) |>
  summarise(media = round(mean(pct), 1)) |>
  arrange(desc(media))
```

**b) ¿Se cumple la Ley de Engel?** Correlacionamos el ingreso promedio con el
porcentaje gastado en alimentos. Un valor negativo indica que, a mayor ingreso,
menor peso de los alimentos.

```{r engel-cor}
cor(db$promedio, db$Alimentos)  # esperamos un valor negativo (~ -0.79)
```

> **Discuta en el grupo:** las familias más ricas destinan **50,5 %** de su gasto
> a "Otros gastos y Ahorro"; las más pobres, solo **9,9 %** —y buena parte de eso
> no es ahorro, sino otras necesidades. ¿Qué revela ese contraste sobre la
> *capacidad de acumular* y sobre la estructura de la pobreza, más allá del
> ingreso individual?

## Paso 2 — Reconstruir la lámina de Du Bois

Barras apiladas horizontales, al estilo de la Lámina 31.

```{r fig-barras, fig.width=9, fig.height=5.5}
db_long$categoria <- factor(
  db_long$categoria,
  levels = c("Vivienda","Alimentos","Vestido","Impuestos","Otros/Ahorro"))

ggplot(db_long, aes(fct_rev(clase), pct, fill = categoria)) +
  geom_col(width = 0.8, color = dubois_bg) +
  coord_flip() +
  scale_fill_manual(values = pal, name = NULL) +
  scale_y_continuous(labels = label_percent(scale = 1), expand = c(0, 0)) +
  labs(title = "INGRESO Y GASTO DE 150 FAMILIAS NEGRAS EN ATLANTA, GA.",
       subtitle = "Proporción del gasto por clase de ingreso anual (Du Bois, 1900)",
       x = "Clase de ingreso anual (USD)", y = NULL) +
  theme_dubois
```

## Paso 3 — Visualizar la Ley de Engel

```{r fig-engel}
ggplot(db, aes(promedio, Alimentos)) +
  geom_line(color = "#7c1c1c", linewidth = 1) +
  geom_point(color = "#7c1c1c", size = 3) +
  geom_smooth(method = "lm", se = FALSE, linetype = 2, color = "#4b7a9d") +
  scale_x_continuous(labels = label_dollar()) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(title = "La Ley de Engel en los datos de Du Bois",
       subtitle = "A mayor ingreso, menor proporción gastada en alimentos",
       x = "Ingreso anual promedio", y = "% del gasto en alimentos") +
  theme_dubois
```

Y el contraste directo entre **alimentos** (baja) y **otros gastos/ahorro** (sube):

```{r fig-alim-ahorro}
ggplot(filter(db_long, categoria %in% c("Alimentos", "Otros/Ahorro")),
       aes(clase, pct, group = categoria, color = categoria)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c(Alimentos = "#f0b323",
                                `Otros/Ahorro` = "#4b7a9d"), name = NULL) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(title = "Alimentos frente a Otros gastos / Ahorro",
       x = "Clase de ingreso", y = "% del gasto") +
  theme_dubois +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
```

## Preguntas de cierre del Ejercicio 1

1. Du Bois **no** se detiene en la Ley de Engel (un resultado ya conocido en su
   época). ¿Qué *argumento social* construye al mostrar estos datos sobre
   familias **afroamericanas** en particular?
2. ¿Por qué elige gráficos hechos a mano, coloridos y grandes, en lugar de una
   tabla? ¿Qué hace la visualización que la tabla no hace?
3. La visualización, ¿es una representación "neutral" de los datos o parte del
   argumento? Relacione con la idea STS de la **inscripción situada**.

---

# Ejercicio 2 · Del Atlanta de 1900 a la Colombia de hoy

Du Bois midió cómo el peso de los alimentos y la vivienda en el presupuesto marca
la desigualdad. Traigamos ese lente a Colombia con datos del **DANE**.

**Contexto.** Según la Encuesta Nacional de Presupuestos de los Hogares
(ENPH 2016–2017), los alimentos representan cerca del **15,9 %** del gasto
promedio de los hogares colombianos a nivel nacional. Pero ese promedio esconde
enormes diferencias por clase social: son precisamente los datos de la ENPH los
que el DANE usa para fijar las **ponderaciones de la canasta del IPC**. Nuestro
archivo desagrega esas ponderaciones (por divisiones COICOP) en cuatro clases:
**Pobres, Vulnerables, Clase Media e Ingresos Altos**.

## Paso 1 — Cargar y ordenar los datos del DANE

```{r cargar-dane}
dane <- read_csv("/Users/oscar/Downloads/distribucion_gasto_por_clase_social.csv",
                 show_col_types = FALSE)
names(dane)[1] <- "division"   # normaliza el nombre de la 1a columna (trae BOM)

clases <- c("Pobres", "Vulnerables", "Clase Media", "Ingresos Altos")

# Nombres cortos para graficar (detección por subcadena, robusta a tildes)
dane <- dane |>
  mutate(div_corto = case_when(
    str_detect(division, "Alimentos")    ~ "Alimentos",
    str_detect(division, "Tabaco")       ~ "Alcohol y tabaco",
    str_detect(division, "Vestir")       ~ "Vestido y calzado",
    str_detect(division, "Alojamiento")  ~ "Alojamiento y servicios",
    str_detect(division, "Muebles")      ~ "Muebles y hogar",
    str_detect(division, "Salud")        ~ "Salud",
    str_detect(division, "Transporte")   ~ "Transporte",
    str_detect(division, "Comunicaci")   ~ "Información y comunic.",
    str_detect(division, "Cultura")      ~ "Recreación y cultura",
    str_detect(division, "Educaci")      ~ "Educación",
    str_detect(division, "Restaurantes") ~ "Restaurantes y hoteles",
    str_detect(division, "Bienes")       ~ "Bienes/servicios div.",
    TRUE ~ division))

# Formato largo, solo las cuatro clases (sin la columna Total)
dane_long <- dane |>
  select(div_corto, all_of(clases)) |>
  pivot_longer(-div_corto, names_to = "clase", values_to = "pct") |>
  mutate(clase = factor(clase, levels = clases))

head(dane_long)
```

## Paso 2 — Descriptivo: el gradiente de los alimentos

```{r dane-razon}
alim <- filter(dane, div_corto == "Alimentos")
razon <- alim$Pobres / alim$`Ingresos Altos`

cat("Alimentos — Pobres:", alim$Pobres, "%  |  Ingresos Altos:",
    alim$`Ingresos Altos`, "%\n")
cat("Los hogares pobres destinan", round(razon, 2),
    "veces la proporción que destinan los de ingresos altos.\n")
```

**Necesidad vs. discrecional.** El aporte de Du Bois no es solo el gasto en
alimentos: es la *estructura* del presupuesto. Clasifiquemos cada división según
si su peso **cae** o **sube** de Pobres a Ingresos Altos.

```{r dane-cambio}
cambio <- dane |>
  transmute(div_corto,
            delta = `Ingresos Altos` - Pobres,
            tipo  = ifelse(delta < 0,
                           "Cae con el ingreso (necesidad)",
                           "Sube con el ingreso (discrecional)")) |>
  arrange(delta)
cambio
```

## Paso 3 — Visualizaciones

**a) Peso de los alimentos por clase social** (el eco directo de Du Bois):

```{r fig-dane-alim}
ggplot(filter(dane_long, div_corto == "Alimentos"),
       aes(clase, pct, fill = clase)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = paste0(pct, "%")), vjust = -0.4, size = 4) +
  scale_fill_manual(values = c("#7c1c1c","#e02c37","#f0b323","#4b7a9d"),
                    guide = "none") +
  scale_y_continuous(labels = label_percent(scale = 1),
                     expand = expansion(c(0, .12))) +
  labs(title = "Peso de los alimentos en la canasta por clase social (DANE)",
       subtitle = "Coeficiente de Engel: los hogares pobres destinan casi 3 veces más a alimentos",
       x = NULL, y = "Ponderación de alimentos") +
  theme_dubois
```

**b) Composición completa del gasto** — el análogo colombiano de la Lámina 31:

```{r fig-dane-comp, fig.width=8.5, fig.height=6.5}
pal12 <- c("Alimentos"="#f0b323","Alojamiento y servicios"="#e02c37",
  "Vestido y calzado"="#98867e","Transporte"="#4b7a9d",
  "Restaurantes y hoteles"="#7c1c1c","Bienes/servicios div."="#b5651d",
  "Muebles y hogar"="#c9a227","Educación"="#2f6b52",
  "Recreación y cultura"="#8a5a83","Información y comunic."="#5b8ca5",
  "Salud"="#d98594","Alcohol y tabaco"="#6b6b6b")

# ordenar las divisiones por su peso total (para apilar de mayor a menor)
ord_div <- dane |> arrange(desc(Total)) |> pull(div_corto)
dane_long$div_corto <- factor(dane_long$div_corto, levels = rev(ord_div))

ggplot(dane_long, aes(clase, pct, fill = div_corto)) +
  geom_col(width = 0.8, color = dubois_bg) +
  scale_fill_manual(values = pal12, name = NULL) +
  scale_y_continuous(labels = label_percent(scale = 1), expand = c(0, 0)) +
  guides(fill = guide_legend(ncol = 3, reverse = TRUE)) +
  labs(title = "COMPOSICIÓN DEL GASTO POR CLASE SOCIAL EN COLOMBIA",
       subtitle = "Divisiones COICOP (DANE) — el análogo colombiano de la Lámina 31 de Du Bois",
       x = NULL, y = NULL) +
  theme_dubois +
  theme(legend.text = element_text(size = 8))
```

**c) ¿Qué sube y qué baja con el ingreso?** (necesidades vs. discrecionales):

```{r fig-dane-div, fig.width=8, fig.height=5.5}
ggplot(cambio, aes(reorder(div_corto, delta), delta, fill = tipo)) +
  geom_col(width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c("Cae con el ingreso (necesidad)" = "#e02c37",
                               "Sube con el ingreso (discrecional)" = "#4b7a9d"),
                    name = NULL) +
  labs(title = "¿Qué sube y qué baja con el ingreso?",
       subtitle = "Diferencia (puntos %) entre Ingresos Altos y Pobres, por división de gasto",
       x = NULL, y = "Ingresos Altos − Pobres") +
  theme_dubois
```

## Preguntas de cierre del Ejercicio 2

1. La estructura que Du Bois halló en Atlanta reaparece en Colombia: **alimentos**
   y **alojamiento** dominan el presupuesto de los pobres y ceden peso con el
   ingreso, mientras **transporte, educación, restaurantes y recreación** crecen.
   ¿Qué nos dice esto sobre la relación entre **clase y consumo**?
2. En Estados Unidos, Du Bois cruzó **clase con raza**. En Colombia, ¿dónde
   quedan la población **afrocolombiana** y otros grupos históricamente
   excluidos dentro de "Pobres/Vulnerables/Clase Media/Ingresos Altos"?
   ¿Qué **no** captura una ponderación nacional (p. ej., el Pacífico o el Chocó)?
3. Si mañana suben los precios de los alimentos, ¿a qué clase golpea primero la
   inflación, y por qué? ¿Cómo usaría estos datos en un argumento de política
   pública, al estilo Du Bois?
4. **Reflexividad (STS):** ¿quién define las categorías "clase social" y sus
   umbrales de ingreso? ¿Qué decisiones de medición quedan detrás de una
   "ponderación"? ¿A quién vuelven visible o invisible?

---

# Entregable

Cada grupo entrega un documento breve (puede ser este `.Rmd` **tejido**
—*knit*— a HTML/PDF) que incluya:

- Las visualizaciones del Ejercicio 1 y al menos **dos** del Ejercicio 2.
- Un párrafo (máx. 200 palabras) que responda: *¿por qué Du Bois es relevante
  para el análisis cuantitativo hoy?*, articulando la Ley de Engel con la
  discusión sobre desigualdad, raza/clase y el carácter situado de los datos.
- Una pregunta abierta que su grupo llevaría a una investigación propia.

---

# Referencias y fuentes

- Du Bois, W. E. B. (1899). *The Philadelphia Negro: A Social Study*.
- Battle-Baptiste, W. & Rusert, B. (eds.) (2018). *W. E. B. Du Bois's Data
  Portraits: Visualizing Black America*. Princeton Architectural Press.
- Lámina 31, "Income and Expenditure of 150 Negro Families in Atlanta, Ga.",
  *The Exhibit of American Negroes*, Exposición de París, 1900 (Library of
  Congress).
- DANE. *Encuesta Nacional de Presupuestos de los Hogares (ENPH) 2016–2017* y
  ponderaciones del Índice de Precios al Consumidor (IPC) por clase social.

*Nota técnica: los gráficos usan `ggplot2`. Si al tejer aparecen caracteres raros
en las tildes, agregue `options(encoding = "UTF-8")` o guarde el `.Rmd` como
UTF-8.*
