# Taller 1 — Cartografía cienciométrica de los métodos en ciencias sociales

**Curso:** Análisis Cuantitativo · Primera sesión
**Formato:** grupos de 3 personas · 40 minutos
**Herramientas:** Scopus (o OpenAlex, de libre acceso) + RawGraphs

---

## Encuadre

La primera sesión de un curso de análisis cuantitativo es un buen lugar para un gesto reflexivo: **usar una técnica cuantitativa —la cienciometría— para estudiar la propia distribución de métodos cuantitativos y cualitativos en las ciencias sociales.** El ejercicio pone a los estudiantes a operar el ciclo completo de la investigación cuantitativa en miniatura (pregunta → fuente → operacionalización → base de datos → visualización → interpretación) y, al mismo tiempo, abre la pregunta que atraviesa todo el semestre: ¿qué cuenta como "un método", y qué se hace visible o invisible cuando lo contamos?

La tensión productiva del taller es que **contar métodos con palabras clave es, en sí mismo, un método discutible**. Esa fricción entre el conteo y la lectura es el objeto de la discusión de cierre.

---

## Objetivos de aprendizaje

Al terminar, cada estudiante debería poder:

1. Formular una pregunta empírica sobre la distribución de métodos y **operacionalizarla** como una búsqueda en una base de datos bibliográfica.
2. Construir una **base de datos sencilla** (formato largo, CSV) a partir de conteos documentales.
3. Producir una **visualización comparativa** con una herramienta de libre acceso (RawGraphs).
4. Interpretar la división cuantitativo/cualitativo como un **hallazgo empírico y variable entre disciplinas**, no como un supuesto.
5. Identificar los **sesgos y límites** del dispositivo (cobertura de Scopus, validez del proxy por palabra clave, sesgo lingüístico y regional).

---

## Materiales y requisitos

- Un computador por grupo con acceso a internet.
- Acceso institucional a **Scopus** (vía VPN o red del campus). *Alternativa libre:* **OpenAlex** (openalex.org), **Lens.org** o **Dimensions**.
- **RawGraphs 2.0** — `rawgraphs.io` (no requiere cuenta).
- Una hoja de cálculo (Excel, Google Sheets o LibreOffice) para armar el CSV.

---

## Cronograma (40 min)

| Tiempo | Actividad |
|---|---|
| 0:00–0:04 | Encuadre, conformación de grupos y **asignación de una disciplina** por grupo |
| 0:04–0:16 | Búsquedas y registro de conteos (repartir los términos entre las 3 personas) |
| 0:16–0:24 | Construcción de la base de datos (CSV) |
| 0:24–0:32 | Visualización en RawGraphs |
| 0:32–0:40 | Puesta en común comparativa + discusión de cierre |

---

## El ejercicio, paso a paso

### Paso 1 — Operacionalizar la disciplina (0:04)

Cada grupo recibe una disciplina asignada (ver tabla más abajo). El primer problema práctico es que **"una disciplina" no existe como tal en la base de datos**: hay que construirla con una consulta. Usaremos un *proxy* por palabra clave.

Plantilla de consulta en Scopus (total de la disciplina):

```
TITLE-ABS-KEY ( <DISCIPLINA> ) AND PUBYEAR > 2014 AND ( LIMIT-TO ( DOCTYPE , "ar" ) )
```

Anoten el número total de documentos: será el **denominador** para normalizar.

### Paso 2 — Contar métodos (proxy por términos) (0:04–0:16)

Para cada **término de método** de la lista compartida, corran:

```
TITLE-ABS-KEY ( <DISCIPLINA> ) AND TITLE-ABS-KEY ( <TÉRMINO> ) AND PUBYEAR > 2014 AND ( LIMIT-TO ( DOCTYPE , "ar" ) )
```

Registren el número de documentos que devuelve cada búsqueda. **Repartan los 7 términos entre las 3 personas** (2–3 cada una) para ganar tiempo.

> *Atajo útil:* en Scopus, "Analyze search results" genera automáticamente la evolución por año y por área — sirve para verificar, pero el objetivo es que ustedes construyan su propia base de datos.

### Paso 3 — Construir la base de datos (0:16–0:24)

Armen un CSV en **formato largo** (una fila por término). Estructura:

```
disciplina,termino,tipo,n_documentos,total_disciplina
```

Ejemplo (⚠ **datos inventados** — reemplácenlos por sus conteos reales):

```
disciplina,termino,tipo,n_documentos,total_disciplina
Sociología,ethnography,cualitativo,430,52000
Sociología,interview,cualitativo,3100,52000
Sociología,case study,cualitativo,2100,52000
Sociología,survey,cuantitativo,4800,52000
Sociología,regression,cuantitativo,1900,52000
Sociología,experiment,cuantitativo,700,52000
Sociología,mixed methods,mixto,610,52000
```

Si el tiempo lo permite, agreguen una columna `porcentaje = n_documentos / total_disciplina * 100`. La normalización es lo que hace comparables disciplinas de tamaños muy distintos.

### Paso 4 — Visualizar en RawGraphs (0:24–0:32)

1. Entren a `rawgraphs.io` → **Use it now**.
2. **Peguen** el contenido del CSV en el cuadro de datos.
3. Elijan el gráfico:
   - **Bar chart (apilado):** eje X = `tipo` (o `termino`), altura = `n_documentos`, color = `tipo`. Lo más rápido y legible.
   - **Alluvial diagram:** pasos = `disciplina` → `tipo`, tamaño = `n_documentos`. Ideal para la puesta en común comparativa.
   - **Circle packing:** jerarquía `disciplina > tipo > termino`, tamaño = `n_documentos`.
4. Mapeen las dimensiones a las variables visuales.
5. **Exporten** como SVG o PNG para compartir.

### Paso 5 — Verificación mínima (durante la puesta en común)

Antes de concluir, abran **2 abstracts** que devolvió una de sus búsquedas. ¿El paper efectivamente usa ese método, o solo menciona la palabra? Esta comprobación de un minuto es la puerta de entrada a la discusión.

---

## Disciplinas asignadas

Se sugiere asignar una por grupo para que la puesta en común arme un panorama comparado de las ciencias sociales. Proxy de palabra clave entre paréntesis:

| Grupo | Disciplina | `<DISCIPLINA>` sugerido |
|---|---|---|
| 1 | Sociología | `sociolog*` |
| 2 | Economía | `econom*` |
| 3 | Antropología | `anthropolog*` |
| 4 | Ciencia Política | `"political science" OR politolog*` |
| 5 | Psicología | `psycholog*` |
| 6 | Comunicación / Medios | `"communication studies" OR "media studies"` |
| 7 | Educación | `education* AND research` |
| 8 | Geografía humana | `"human geography"` |

*(Como alternativa gruesa, pueden usar los filtros de área de Scopus: `SOCI`, `ECON`, `PSYC`, `BUSI` — más rápidos, pero mezclan subdisciplinas.)*

## Términos de método (lista compartida)

| Término | Tipo |
|---|---|
| `ethnograph*` | cualitativo |
| `interview*` | cualitativo |
| `"case study"` | cualitativo |
| `survey` | cuantitativo |
| `regression` | cuantitativo |
| `experiment*` | cuantitativo |
| `"mixed methods"` | mixto |

*(Pueden sumar `"discourse analysis"`, `"grounded theory"`, `econometric*` o `"structural equation"` si sobra tiempo.)*

---

## Puesta en común y discusión de cierre (0:32–0:40)

Cada grupo muestra su visualización en 30–45 segundos. Con el panorama comparado a la vista:

- ¿Qué disciplinas se inclinan hacia lo cuantitativo y cuáles hacia lo cualitativo? ¿Algo los sorprendió? (Economía y Psicología suelen aparecer marcadamente cuantitativas; Antropología, marcadamente cualitativa; Sociología y Ciencia Política, más repartidas.)
- ¿La "división" cuant/cual se sostiene como un corte limpio, o se parece más a un continuo con métodos mixtos y computacionales en el medio?
- Cuando abrieron los abstracts, ¿el proxy por palabra clave **sobrecontó** o **subcontó**? ¿Por qué?
- ¿A quién y qué **no vemos** en Scopus? (idioma, tipo de publicación, región)
- El método que ustedes acaban de usar —contar publicaciones— ¿es cuantitativo, cualitativo o algo intermedio?

---

## Nota crítica: el dispositivo tiene sesgos

Vale cerrar (o abrir la siguiente sesión) señalando que **la base de datos no es una ventana neutral** sobre la ciencia:

- **Sesgo lingüístico y de formato.** Scopus privilegia el artículo en inglés. Las tradiciones cualitativas y humanísticas publican más en libros y en lenguas locales, y quedan sistemáticamente subrepresentadas.
- **Sesgo regional.** La producción latinoamericana en ciencias sociales está muy subcubierta en Scopus frente a **SciELO, Redalyc o Latindex**. Contar "los métodos de las ciencias sociales" en Scopus es, en buena medida, contar los métodos del Norte anglófono.
- **Validez del proxy.** Que un abstract diga "qualitative" no lo vuelve cualitativo; muchos estudios no nombran su método en el resumen. La operacionalización *fabrica* el hallazgo tanto como lo *revela*.

**Alternativas de libre acceso** que valen para replicar el ejercicio sin muro de pago: **OpenAlex** (abierto y con API), **Lens.org**, **Dimensions** (nivel gratuito), y para el registro regional, **SciELO** y **Redalyc**.

---

### Extensión opcional (para versión de 60–90 min)

Si se dispone de más tiempo, sustituir el proxy por una **codificación manual**: cada grupo exporta 15 abstracts de su disciplina, los codifica a mano (cuantitativo / cualitativo / mixto / teórico / revisión) y compara ese conteo "leído" con el conteo "contado" del Paso 2. La brecha entre ambos es la lección metodológica central.

---

*Nota:* el ejercicio funciona como un pequeño dispositivo cuali-cuantitativo en la línea de los métodos digitales e inventivos —la fricción entre contar y leer los métodos es exactamente lo que se quiere hacer sentir, no resolver—. Sirve además como gancho para introducir la agenda del curso: la construcción de datos, la operacionalización y la reflexividad sobre las herramientas.
