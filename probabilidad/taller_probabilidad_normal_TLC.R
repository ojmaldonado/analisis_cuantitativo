# =============================================================================
#  TALLER 
#  Probabilidad, Distribución Normal y Teorema del Límite Central (TLC)
#
#  Curso: Análisis Cuantitativo
#  Duración estimada: 60-75 minutos
#
#  Cómo usarlo:
#   - Abra este archivo en RStudio.
#   - Ejecute el código bloque por bloque (Ctrl+Enter o Cmd+Enter línea a línea;
#     Ctrl+Shift+Enter para correr una sección completa).
#   - Use el panel "Outline" de RStudio (arriba a la derecha del editor) para
#     navegar entre secciones: cada título que termina en "----" es una sección.
# =============================================================================


# 0. Preparación -----------------------------------------------------------

# Instala ggplot2 solo si no está instalado, y luego lo carga.
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library(ggplot2)

# Fijamos una "semilla" para que la aleatoriedad sea reproducible:
# todos en el salón obtendrán exactamente los mismos números aleatorios.
set.seed(123)


# =============================================================================
# PARTE 1 — PROBABILIDAD: DE LA MONEDA A LA REGULARIDAD
# =============================================================================
# Idea central: la probabilidad de un evento es la frecuencia con la que ocurre
# "a la larga". Con pocas repeticiones hay mucho ruido; con muchas, aparece una
# regularidad estable. A eso se le llama la Ley de los Grandes Números.

# 1.1 Simular el lanzamiento de una moneda ----

# Lanzamos una moneda 10 veces (cara/sello):
sample(c("cara", "sello"), size = 10, replace = TRUE)

# Ahora 1000 veces, y contamos los resultados:
lanzamientos <- sample(c("cara", "sello"), size = 1000, replace = TRUE)
table(lanzamientos)              # frecuencias absolutas
prop.table(table(lanzamientos))  # frecuencias relativas (proporciones)

# Pregunta para discutir: ¿la proporción de "cara" se parece al 0.5 teórico?


# 1.2 La Ley de los Grandes Números, en un gráfico ----

# Codificamos cara = 1, sello = 0, y vamos calculando la proporción ACUMULADA
# de caras conforme aumenta el número de lanzamientos.
n         <- 2000
lanz      <- sample(c(0, 1), size = n, replace = TRUE)   # 1 = cara
prop_acum <- cumsum(lanz) / seq_len(n)                    # proporción acumulada

df_lgn <- data.frame(lanzamiento = seq_len(n), proporcion = prop_acum)

ggplot(df_lgn, aes(x = lanzamiento, y = proporcion)) +
  geom_line(color = "steelblue") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  coord_cartesian(ylim = c(0, 1)) +
  labs(
    title = "Ley de los Grandes Números",
    subtitle = "La proporción de caras se estabiliza en 0.5 al aumentar los lanzamientos",
    x = "Número de lanzamientos",
    y = "Proporción acumulada de caras"
  ) +
  theme_minimal()

# Lección: la probabilidad NO garantiza nada en el corto plazo (la moneda no
# "debe" salir cara porque salieron muchos sellos), pero SÍ produce una
# regularidad estable en el largo plazo.


# =============================================================================
# PARTE 2 — LA DISTRIBUCIÓN NORMAL
# =============================================================================
# La distribución normal (o "campana de Gauss") describe muchas variables
# continuas que se concentran alrededor de un promedio y se vuelven raras en los
# extremos. Queda definida por dos parámetros:
#   - media (mu):  dónde está el centro
#   - desviación estándar (sigma): qué tan ancha/dispersa es la campana

# 2.1 Dibujar la campana ----

x <- seq(-4, 4, length.out = 400)
y <- dnorm(x, mean = 0, sd = 1)   # dnorm = "altura" de la curva normal en cada x

df_normal <- data.frame(x = x, densidad = y)

ggplot(df_normal, aes(x = x, y = densidad)) +
  geom_line(color = "darkred", linewidth = 1) +
  labs(
    title = "Distribución Normal estándar (media = 0, desviación = 1)",
    x = "Valor (z)", y = "Densidad"
  ) +
  theme_minimal()

# 2.2 Las cuatro funciones clave de la normal en R ----
# En R, casi toda distribución tiene 4 funciones. Para la normal:
#   dnorm() -> densidad (altura de la curva)
#   pnorm() -> probabilidad acumulada (área a la izquierda de un valor)
#   qnorm() -> el cuantil (el valor que deja cierta probabilidad a la izquierda)
#   rnorm() -> genera datos aleatorios que siguen la normal

# ¿Qué proporción de casos está por debajo del promedio? (debería ser 0.5)
pnorm(0, mean = 0, sd = 1)

# ¿Por debajo de qué valor está el 95% de los casos?
qnorm(0.95, mean = 0, sd = 1)

# Generamos 5 "personas" con estatura ~ Normal(media = 170 cm, sd = 8 cm):
rnorm(5, mean = 170, sd = 8)

# 2.3 La regla 68 - 95 - 99.7 ----
# En una normal, alrededor del 68% de los casos cae a 1 desviación de la media,
# el 95% a 2 desviaciones, y el 99.7% a 3. Comprobémoslo con pnorm():

pnorm(1)  - pnorm(-1)    # ~ 0.68  -> dentro de +/- 1 sd
pnorm(2)  - pnorm(-2)    # ~ 0.95  -> dentro de +/- 2 sd
pnorm(3)  - pnorm(-3)    # ~ 0.997 -> dentro de +/- 3 sd

# Esta regla es la base para interpretar puntajes, valores atípicos e
# intervalos de confianza.


# =============================================================================
# PARTE 3 — EL TEOREMA DEL LÍMITE CENTRAL (TLC)
# =============================================================================
# Enunciado intuitivo:
#   Si tomamos muchas MUESTRAS de una población (no importa su forma) y
#   calculamos el PROMEDIO de cada muestra, la distribución de esos promedios
#   se aproxima a una NORMAL a medida que aumenta el tamaño de muestra (n).
#
#   Además: el promedio de esos promedios ~ media de la población, y su
#   dispersión se reduce en un factor de sqrt(n) (el "error estándar").
#
# Este es el resultado que justifica gran parte de la inferencia estadística
# en ciencias sociales (por qué podemos confiar en promedios de encuestas).

# 3.1 Una población claramente NO normal ----
# Simulamos una población muy asimétrica, parecida a la distribución del ingreso:
# muchas personas con ingresos bajos y unas pocas con ingresos muy altos.

set.seed(2024)
poblacion <- rexp(100000, rate = 1)   # distribución exponencial: cola a la derecha

# Visualizamos la población: NO tiene forma de campana.
ggplot(data.frame(x = poblacion), aes(x = x)) +
  geom_histogram(bins = 60, fill = "grey40", color = "white") +
  labs(
    title = "Población de origen: fuertemente asimétrica (NO normal)",
    subtitle = "Imagine la distribución del ingreso: muchos abajo, pocos muy arriba",
    x = "Valor en la población", y = "Frecuencia"
  ) +
  theme_minimal()

# 3.2 Tomar muchas muestras y guardar sus promedios ----
# Esta función toma 'reps' muestras de tamaño 'n' y devuelve el promedio de cada una.
medias_muestrales <- function(poblacion, n, reps = 1000) {
  replicate(reps, mean(sample(poblacion, size = n, replace = TRUE)))
}

# Repetimos el experimento con tres tamaños de muestra crecientes:
medias_n5   <- medias_muestrales(poblacion, n = 5)
medias_n30  <- medias_muestrales(poblacion, n = 30)
medias_n100 <- medias_muestrales(poblacion, n = 100)

# 3.3 Ver cómo los promedios se "vuelven normales" ----
# Juntamos los tres experimentos en un solo data.frame para graficarlos.
df_tlc <- rbind(
  data.frame(media = medias_n5,   n = "n = 5"),
  data.frame(media = medias_n30,  n = "n = 30"),
  data.frame(media = medias_n100, n = "n = 100")
)
# Ordenamos los niveles para que los paneles salgan de menor a mayor n:
df_tlc$n <- factor(df_tlc$n, levels = c("n = 5", "n = 30", "n = 100"))

ggplot(df_tlc, aes(x = media)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "steelblue", color = "white") +
  geom_density(color = "red", linewidth = 1) +   # forma empírica de los promedios
  facet_wrap(~ n, scales = "free") +
  labs(
    title = "Teorema del Límite Central en acción",
    subtitle = "La distribución de los PROMEDIOS muestrales se acerca a una campana al crecer n",
    x = "Promedio de la muestra", y = "Densidad"
  ) +
  theme_minimal()

# Aunque la población era muy asimétrica, ¡los PROMEDIOS forman una campana!
# Y con n = 100 la campana es más angosta (los promedios varían menos).

# 3.4 Comprobación cuantitativa ----
# El TLC no solo habla de la FORMA, también predice el centro y la dispersión
# de la distribución de los promedios:

media_poblacion <- mean(poblacion)          # media verdadera (mu)
sd_poblacion    <- sd(poblacion)            # desviación de la población (sigma)

# El centro de los promedios debe coincidir con la media poblacional:
media_poblacion
mean(medias_n30)

# La dispersión de los promedios (error estándar) debe ser sigma / sqrt(n):
sd_poblacion / sqrt(30)   # error estándar TEÓRICO
sd(medias_n30)            # error estándar EMPÍRICO (de nuestra simulación)

# Deberían ser muy parecidos: eso es exactamente lo que promete el TLC.


# =============================================================================
# EJERCICIOS PROPUESTOS
# =============================================================================
# Trabaje en grupos y modifique el código anterior:
#
#  1) MONEDA SESGADA: en la Parte 1, simule una moneda cargada donde "cara"
#     tenga probabilidad 0.7. Pista: sample(c(0,1), n, replace = TRUE,
#     prob = c(0.3, 0.7)). ¿Hacia qué valor se estabiliza la proporción?
#
#  2) OTRA NORMAL: en la Parte 2, dibuje la estatura de una población con
#     media = 165 y desviación = 6. ¿Qué proporción mide más de 180 cm?
#     Pista: use 1 - pnorm(180, mean = 165, sd = 6).
#
#  3) TLC CON OTRA POBLACIÓN: en la Parte 3, reemplace la población exponencial
#     por una uniforme: poblacion <- runif(100000, min = 0, max = 1).
#     Vuelva a correr desde 3.2. ¿También se vuelven normales los promedios?
#
#  4) EL PODER DE n: repita el experimento del TLC con n = 2 y con n = 500.
#     ¿Qué le pasa al ANCHO de la campana de promedios? Conéctelo con la
#     fórmula del error estándar (sigma / sqrt(n)).


# =============================================================================
# SÍNTESIS CONCEPTUAL
# =============================================================================
#  - PROBABILIDAD: la frecuencia estable de un evento a largo plazo
#    (Ley de los Grandes Números).
#  - DISTRIBUCIÓN NORMAL: modelo en forma de campana definido por media y
#    desviación estándar; regla 68-95-99.7.
#  - TEOREMA DEL LÍMITE CENTRAL: los PROMEDIOS de muestras tienden a una normal
#    aunque la población no lo sea. Es el puente entre la probabilidad y la
#    inferencia estadística que usamos con datos de encuestas.
# =============================================================================
