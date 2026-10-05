# =============================================================================
#  TALLER: MEDIDAS DE RESUMEN NUMÉRICO
#  Análisis Cuantitativo · Ciencias Sociales
# -----------------------------------------------------------------------------
#  Objetivo: aprender a describir una variable con pocos números
#  (tendencia central, dispersión, posición, forma y desigualdad) y a
#  interpretarlos sociológicamente con ejemplos de pobreza, equidad y
#  acceso a recursos.
#
#  Instrucciones:
#   - Ejecute el script línea por línea (Ctrl + Enter / Cmd + Enter).
#   - Lea los comentarios antes de correr cada bloque.
#   - Las preguntas marcadas con  >>  son para discutir en grupo.
#   - Los datos son SIMULADOS: se parecen a la realidad colombiana, pero
#     no son cifras oficiales.
#   - No se necesita instalar ningún paquete: todo es R base.
# =============================================================================


# -----------------------------------------------------------------------------
# 0. PREPARACIÓN
# -----------------------------------------------------------------------------

rm(list = ls())          # limpia el ambiente de trabajo
options(scipen = 999)    # evita la notación científica (1e+06)
set.seed(2026)           # fija el azar: todos obtendremos los mismos datos


# -----------------------------------------------------------------------------
# 1. CONSTRUCCIÓN DEL DATASET: "Encuesta de hogares" ficticia
# -----------------------------------------------------------------------------
# Simulamos 500 hogares de un departamento con zona urbana y zona rural.
# Cada fila es un hogar. Variables:
#   zona        : urbana / rural
#   estrato     : estrato socioeconómico de la vivienda (1 a 6)
#   personas    : número de personas en el hogar
#   ingreso     : ingreso mensual total del hogar (pesos)
#   educ_jefe   : años de educación de la persona jefa de hogar
#   dist_salud  : distancia al centro de salud más cercano (km)
#   internet    : el hogar tiene internet fijo (Sí / No)

n <- 500

zona <- sample(c("urbana", "rural"), n, replace = TRUE, prob = c(0.7, 0.3))

# El estrato depende de la zona: en lo rural predominan los estratos bajos
estrato <- ifelse(
  zona == "urbana",
  sample(1:6, n, replace = TRUE, prob = c(.22, .33, .25, .12, .05, .03)),
  sample(1:6, n, replace = TRUE, prob = c(.55, .35, .08, .02, 0, 0))
)

# Hogares más grandes en estratos bajos
personas <- 1 + rpois(n, lambda = 3 - 0.3 * estrato)

# Ingreso: crece con el estrato, es menor en lo rural y tiene "cola larga"
# (pocos hogares con ingresos muy altos), como ocurre en la realidad.
ingreso <- exp(rnorm(n,
                     mean = log(1300000) + 0.38 * (estrato - 1) - 0.25 * (zona == "rural"),
                     sd   = 0.5))
ingreso <- round(ingreso, -3)   # redondeamos a miles de pesos

educ_jefe <- round(rnorm(n, mean = 6 + 1.8 * (estrato - 1) - 1.5 * (zona == "rural"), sd = 3))
educ_jefe <- pmin(pmax(educ_jefe, 0), 22)   # entre 0 y 22 años

dist_salud <- round(ifelse(zona == "rural", rexp(n, 1 / 12), rexp(n, 1 / 2)), 1)

internet <- ifelse(runif(n) < plogis(-1 + 0.8 * (estrato - 1) - 1.2 * (zona == "rural")),
                   "Sí", "No")

hogares <- data.frame(id = 1:n, zona, estrato, personas, ingreso,
                      educ_jefe, dist_salud, internet)

# Exploramos la base
head(hogares)      # primeras filas
str(hogares)       # tipo de cada variable
View(hogares)      # abre la base en una pestaña de RStudio

# Creamos el ingreso per cápita: el ingreso del hogar repartido entre sus miembros.
# Es la variable con la que normalmente se mide la pobreza monetaria.
hogares$ingreso_pc <- hogares$ingreso / hogares$personas


# -----------------------------------------------------------------------------
# 2. UNA PRIMERA MIRADA: summary()
# -----------------------------------------------------------------------------
# summary() entrega de una vez: mínimo, cuartil 1, mediana, media,
# cuartil 3 y máximo.

summary(hogares$ingreso)
summary(hogares$dist_salud)

# >> ¿Qué diferencia observa entre la media y la mediana del ingreso?
# >> ¿Cuál de las dos cree que describe mejor al "hogar típico"?


# -----------------------------------------------------------------------------
# 3. MEDIDAS DE TENDENCIA CENTRAL
# -----------------------------------------------------------------------------
# Responden a la pregunta: ¿alrededor de qué valor se ubican los datos?

# 3.1 Media aritmética: suma de los valores dividida por el número de casos
mean(hogares$ingreso)
sum(hogares$ingreso) / length(hogares$ingreso)   # lo mismo, "a mano"

# 3.2 Mediana: el valor que deja al 50 % de los casos por debajo y al 50 % por encima
median(hogares$ingreso)

# 3.3 Moda: el valor más frecuente. R no trae una función para la moda
# estadística, así que la construimos. Es útil sobre todo en variables
# discretas o categóricas.
moda <- function(x) {
  tabla <- table(x)
  names(tabla)[tabla == max(tabla)]
}

moda(hogares$personas)    # tamaño de hogar más común
moda(hogares$estrato)     # estrato más común
moda(hogares$internet)    # también funciona con categorías

# 3.4 Media recortada: calcula la media quitando el 10 % de valores más
# bajos y el 10 % más altos. Es más "resistente" a valores extremos.
mean(hogares$ingreso, trim = 0.10)

# --- EXPERIMENTO: llega un hogar muy rico al municipio -----------------------
# ¿Qué le pasa a cada medida si agregamos un solo hogar con ingresos de
# 300 millones de pesos al mes?

ingreso_con_rico <- c(hogares$ingreso, 300000000)

data.frame(
  medida      = c("Media", "Mediana", "Media recortada 10%"),
  original    = c(mean(hogares$ingreso), median(hogares$ingreso),
                  mean(hogares$ingreso, trim = 0.1)),
  con_un_rico = c(mean(ingreso_con_rico), median(ingreso_con_rico),
                  mean(ingreso_con_rico, trim = 0.1))
)

# >> Un solo hogar entre 501 movió la media de forma notable, pero la mediana
#    casi no cambió. ¿Por qué? ¿Qué implica esto cuando un gobierno anuncia
#    que "el ingreso promedio de la región subió"?

# 3.5 Media ponderada: cambiar la unidad de análisis
# La media de ingreso per cápita por HOGAR trata igual a un hogar de 1 persona
# y a uno de 8. Si queremos el ingreso per cápita que recibe la PERSONA
# promedio, ponderamos por el número de personas.

mean(hogares$ingreso_pc)                                  # promedio entre hogares
weighted.mean(hogares$ingreso_pc, w = hogares$personas)   # promedio entre personas

# >> ¿Por qué el promedio por persona es más bajo? Pista: ¿en qué hogares
#    vive más gente?


# -----------------------------------------------------------------------------
# 4. MEDIDAS DE TENDENCIA CENTRAL APLICADAS A LA POBREZA
# -----------------------------------------------------------------------------
# Usamos una línea de pobreza HIPOTÉTICA de 450.000 pesos por persona al mes.
# Un hogar es pobre si su ingreso per cápita está por debajo de esa línea.

linea_pobreza <- 450000

hogares$pobre <- hogares$ingreso_pc < linea_pobreza   # TRUE / FALSE

# 4.1 Incidencia de la pobreza: proporción de hogares pobres.
# Truco: la media de una variable TRUE/FALSE es una proporción.
mean(hogares$pobre)
round(mean(hogares$pobre) * 100, 1)   # en porcentaje

# Incidencia por personas (ponderada por tamaño del hogar)
round(weighted.mean(hogares$pobre, w = hogares$personas) * 100, 1)

# 4.2 Brecha de pobreza: no solo cuántos son pobres, sino QUÉ TAN LEJOS
# están de la línea. Para cada hogar pobre se calcula la distancia
# relativa a la línea; los no pobres cuentan como 0.
brecha <- pmax(0, (linea_pobreza - hogares$ingreso_pc) / linea_pobreza)
round(mean(brecha) * 100, 1)

# >> Dos municipios pueden tener la misma incidencia de pobreza y brechas
#    muy distintas. ¿Qué tipo de política pública sugiere cada indicador?


# -----------------------------------------------------------------------------
# 5. MEDIDAS DE DISPERSIÓN
# -----------------------------------------------------------------------------
# Responden a la pregunta: ¿qué tan diferentes son los casos entre sí?
# Dos grupos pueden tener la misma media y vivir realidades muy distintas.

# 5.1 Rango: distancia entre el valor máximo y el mínimo
range(hogares$ingreso)
diff(range(hogares$ingreso))

# 5.2 Varianza y desviación estándar
# La varianza promedia las distancias al cuadrado respecto a la media.
# La desviación estándar es su raíz cuadrada: vuelve a quedar en pesos.
var(hogares$ingreso)
sd(hogares$ingreso)
sqrt(var(hogares$ingreso))   # lo mismo

# 5.3 Rango intercuartílico (RIC): distancia entre el cuartil 3 y el cuartil 1.
# Mide la dispersión del 50 % central y no se afecta por los extremos.
IQR(hogares$ingreso)

# 5.4 Coeficiente de variación (CV): desviación estándar / media.
# Permite comparar dispersiones de variables con unidades distintas
# (pesos vs. kilómetros vs. años).
cv <- function(x) sd(x) / mean(x)

cv(hogares$ingreso)
cv(hogares$dist_salud)
cv(hogares$educ_jefe)

# >> ¿Cuál de las tres variables es relativamente más desigual?

# --- EJEMPLO: ACCESO A SALUD EN DOS ZONAS ------------------------------------
dist_urbana <- hogares$dist_salud[hogares$zona == "urbana"]
dist_rural  <- hogares$dist_salud[hogares$zona == "rural"]

data.frame(
  zona    = c("Urbana", "Rural"),
  media   = c(mean(dist_urbana), mean(dist_rural)),
  mediana = c(median(dist_urbana), median(dist_rural)),
  desv_est = c(sd(dist_urbana), sd(dist_rural)),
  RIC     = c(IQR(dist_urbana), IQR(dist_rural)),
  maximo  = c(max(dist_urbana), max(dist_rural))
)

# >> Además de estar más lejos en promedio, ¿qué nos dice la dispersión
#    sobre la experiencia de los hogares rurales para llegar a un centro
#    de salud?


# -----------------------------------------------------------------------------
# 6. MEDIDAS DE POSICIÓN: CUARTILES, QUINTILES, DECILES, PERCENTILES
# -----------------------------------------------------------------------------
# Dividen la distribución ordenada en partes iguales.

# Cuartiles (4 partes)
quantile(hogares$ingreso_pc)

# Quintiles (5 partes): muy usados en estudios de desigualdad
quantile(hogares$ingreso_pc, probs = seq(0, 1, 0.2))

# Deciles (10 partes)
quantile(hogares$ingreso_pc, probs = seq(0, 1, 0.1))

# Un percentil específico: ¿cuánto gana el hogar del percentil 90?
quantile(hogares$ingreso_pc, 0.90)

# ¿En qué percentil está la línea de pobreza? (proporción de hogares por debajo)
mean(hogares$ingreso_pc <= linea_pobreza)

# 6.1 Razón P90/P10: cuántas veces más recibe el hogar del percentil 90
# que el del percentil 10. Es una medida sencilla de desigualdad.
p90 <- quantile(hogares$ingreso_pc, 0.90)
p10 <- quantile(hogares$ingreso_pc, 0.10)
as.numeric(p90 / p10)

# 6.2 Asignar a cada hogar su quintil de ingreso
hogares$quintil <- cut(hogares$ingreso_pc,
                       breaks = quantile(hogares$ingreso_pc, probs = seq(0, 1, 0.2)),
                       labels = c("Q1 (más pobre)", "Q2", "Q3", "Q4", "Q5 (más rico)"),
                       include.lowest = TRUE)
table(hogares$quintil)

# 6.3 ¿Qué parte del ingreso total recibe cada quintil?
participacion <- tapply(hogares$ingreso, hogares$quintil, sum) / sum(hogares$ingreso)
round(participacion * 100, 1)

# >> Si la distribución fuera perfectamente igualitaria, cada quintil
#    recibiría el 20 %. ¿Qué tan lejos estamos de eso?


# -----------------------------------------------------------------------------
# 7. MEDIDAS DE FORMA: ASIMETRÍA Y CURTOSIS
# -----------------------------------------------------------------------------
# Describen la "silueta" de la distribución.
#  - Asimetría > 0 : cola larga a la derecha (típico del ingreso)
#  - Asimetría = 0 : distribución simétrica
#  - Asimetría < 0 : cola larga a la izquierda
#  - Curtosis (exceso) > 0 : más casos extremos de los esperados en una normal

asimetria <- function(x) mean((x - mean(x))^3) / sd(x)^3
curtosis  <- function(x) mean((x - mean(x))^4) / sd(x)^4 - 3

asimetria(hogares$ingreso)
asimetria(hogares$educ_jefe)

curtosis(hogares$ingreso)
curtosis(hogares$educ_jefe)

# Veámoslo en gráficos
par(mfrow = c(1, 2))   # dos gráficos lado a lado

hist(hogares$ingreso / 1e6, breaks = 30, col = "steelblue", border = "white",
     main = "Ingreso del hogar", xlab = "Millones de pesos")
abline(v = mean(hogares$ingreso) / 1e6,   col = "red",       lwd = 2)
abline(v = median(hogares$ingreso) / 1e6, col = "darkgreen", lwd = 2, lty = 2)
legend("topright", c("Media", "Mediana"), col = c("red", "darkgreen"),
       lwd = 2, lty = c(1, 2), bty = "n")

hist(hogares$educ_jefe, breaks = 15, col = "darkorange", border = "white",
     main = "Educación jefe/a de hogar", xlab = "Años de educación")
abline(v = mean(hogares$educ_jefe),   col = "red",       lwd = 2)
abline(v = median(hogares$educ_jefe), col = "darkgreen", lwd = 2, lty = 2)

par(mfrow = c(1, 1))   # volvemos a un gráfico por ventana

# >> ¿En cuál variable la media y la mediana están más separadas? ¿Por qué
#    ocurre esto con el ingreso y no tanto con la educación?

# 7.1 El diagrama de caja (boxplot) resume en una figura la mediana,
# los cuartiles, el RIC y los valores atípicos (puntos sueltos).
boxplot(ingreso_pc / 1000 ~ estrato, data = hogares,
        col = "lightblue",
        main = "Ingreso per cápita según estrato",
        xlab = "Estrato", ylab = "Miles de pesos por persona")
abline(h = linea_pobreza / 1000, col = "red", lty = 2, lwd = 2)
text(1, linea_pobreza / 1000, "Línea de pobreza", pos = 3, col = "red", cex = 0.8)


# -----------------------------------------------------------------------------
# 8. RESÚMENES POR GRUPOS
# -----------------------------------------------------------------------------
# En sociología casi nunca nos interesa un solo número: queremos comparar
# grupos (zona, estrato, sexo, región...).

# 8.1 tapply(): una medida, una variable de agrupación
tapply(hogares$ingreso, hogares$zona, median)
tapply(hogares$educ_jefe, hogares$estrato, mean)

# 8.2 aggregate(): varias variables a la vez
aggregate(cbind(ingreso_pc, educ_jefe, dist_salud) ~ zona, data = hogares, FUN = median)

# 8.3 Una tabla resumen completa construida por nosotros
resumir <- function(x) {
  c(n        = length(x),
    media    = mean(x),
    mediana  = median(x),
    desv_est = sd(x),
    RIC      = IQR(x),
    CV       = sd(x) / mean(x))
}

round(do.call(rbind, tapply(hogares$ingreso_pc, hogares$zona, resumir)), 2)
round(do.call(rbind, tapply(hogares$ingreso_pc, hogares$estrato, resumir)), 2)

# 8.4 Pobreza por zona y por estrato
round(tapply(hogares$pobre, hogares$zona, mean) * 100, 1)
round(tapply(hogares$pobre, hogares$estrato, mean) * 100, 1)

# 8.5 Variables categóricas: el resumen se hace con frecuencias y proporciones
table(hogares$internet)
prop.table(table(hogares$internet))

# Acceso a internet por zona (proporciones por fila)
round(prop.table(table(hogares$zona, hogares$internet), margin = 1) * 100, 1)

# Acceso a internet por quintil de ingreso
round(prop.table(table(hogares$quintil, hogares$internet), margin = 1) * 100, 1)

# >> ¿La brecha digital sigue el mismo patrón que la brecha de ingresos?


# -----------------------------------------------------------------------------
# 9. UNA MEDIDA DE EQUIDAD: EL COEFICIENTE DE GINI Y LA CURVA DE LORENZ
# -----------------------------------------------------------------------------
# La curva de Lorenz muestra qué porcentaje del ingreso total acumula cada
# porcentaje de la población, ordenada de más pobre a más rica.
# El coeficiente de Gini resume esa curva en un número entre 0 y 1:
#   0 = igualdad perfecta (todos reciben lo mismo)
#   1 = desigualdad máxima (una sola unidad recibe todo)

gini <- function(x) {
  x <- sort(x)
  n <- length(x)
  sum((2 * seq_len(n) - n - 1) * x) / (n * sum(x))
}

# Probemos la función con casos extremos para entenderla
gini(c(100, 100, 100, 100))   # todos iguales
gini(c(0, 0, 0, 400))         # uno tiene todo: da 0.75, no 1
# Con pocos casos el máximo posible es (n - 1) / n; con muchos casos se acerca a 1.

# Gini de nuestros hogares
gini(hogares$ingreso_pc)
gini(hogares$ingreso_pc[hogares$zona == "urbana"])
gini(hogares$ingreso_pc[hogares$zona == "rural"])

# Curva de Lorenz "a mano"
lorenz <- function(x) {
  x <- sort(x)
  data.frame(pob = c(0, seq_along(x) / length(x)),
             ing = c(0, cumsum(x) / sum(x)))
}

lz <- lorenz(hogares$ingreso_pc)

plot(lz$pob, lz$ing, type = "l", lwd = 2, col = "purple",
     xlab = "Proporción acumulada de hogares (de más pobre a más rico)",
     ylab = "Proporción acumulada del ingreso",
     main = paste("Curva de Lorenz · Gini =", round(gini(hogares$ingreso_pc), 3)))
abline(0, 1, lty = 2)   # línea de igualdad perfecta
text(0.6, 0.65, "Igualdad perfecta", srt = 38, cex = 0.8)

# >> Mientras más se aleja la curva de la diagonal, más desigual es la
#    distribución. ¿Qué proporción del ingreso tiene el 50 % más pobre?
lz$ing[which.min(abs(lz$pob - 0.5))]


# -----------------------------------------------------------------------------
# 10. EJERCICIOS
# -----------------------------------------------------------------------------
# Trabaje en grupos. Escriba su código debajo de cada enunciado.

# Ejercicio 1 · Tendencia central
# Calcule la media, la mediana y la moda de los años de educación de las
# personas jefas de hogar en la zona rural y en la urbana. ¿Qué diferencias
# encuentra? ¿Cuál medida reportaría en un informe y por qué?


# Ejercicio 2 · Dispersión
# Compare el coeficiente de variación del ingreso per cápita entre los
# estratos 1, 2 y 3. ¿En qué estrato los hogares son más heterogéneos?


# Ejercicio 3 · Pobreza
# Suponga que el gobierno sube la línea de pobreza a 550.000 pesos.
# Recalcule la incidencia y la brecha de pobreza. ¿Cuál de los dos
# indicadores cambia más? Interprete.


# Ejercicio 4 · Transferencias y desigualdad
# Un programa social entrega 200.000 pesos mensuales a cada hogar del
# quintil 1. Cree una nueva variable de ingreso con la transferencia y
# calcule de nuevo: (a) el Gini del ingreso per cápita, (b) la razón P90/P10,
# (c) la incidencia de pobreza. ¿Cuál medida es más sensible al programa?
# Pista:
# hogares$ingreso_nuevo <- hogares$ingreso + ifelse(hogares$quintil == "Q1 (más pobre)", 200000, 0)


# Ejercicio 5 · Construya su propio dataset
# Cree un vector con el tiempo (en minutos) que tardan 20 estudiantes en
# llegar a la universidad, inventando datos plausibles para Bogotá e
# incluyendo 2 o 3 casos extremos. Calcule todas las medidas vistas en el
# taller y escriba un párrafo que describa la distribución como lo haría
# en un artículo de investigación.
# Pista: tiempos <- c(35, 50, 42, ...)


# =============================================================================
#  CIERRE · Guía rápida de funciones
# -----------------------------------------------------------------------------
#  Tendencia central : mean(), median(), mean(x, trim = ), weighted.mean(), moda()
#  Dispersión        : range(), var(), sd(), IQR(), cv()
#  Posición          : quantile(x, probs = ), cut()
#  Forma             : asimetria(), curtosis(), hist(), boxplot()
#  Por grupos        : tapply(), aggregate(), table(), prop.table()
#  Desigualdad       : gini(), lorenz(), razón P90/P10, participación por quintil
#
#  Idea central: un solo número nunca cuenta toda la historia. Reporte
#  siempre una medida de centro JUNTO a una de dispersión, y elíjalas según
#  la forma de la distribución (mediana y RIC para variables asimétricas
#  como el ingreso; media y desviación estándar para variables simétricas).
# =============================================================================
