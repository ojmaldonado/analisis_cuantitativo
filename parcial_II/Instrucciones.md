# Parcial II  Análisis Cuantitativo

**Universidad del Rosario · Escuela de Ciencias Humanas · Programa de Sociología**

**Proyecto de investigación: contar desde otro lugar. Un diseño cuantitativo inspirado en el feminismo de datos**

| | |
|---|---|
| Modalidad | [Individual / parejas / grupos de 3] |
| Fecha de entrega | [02/09/2026], [23:59], vía [e-aulas] |
| Extensión | 2.000 a 3.000 palabras, sin contar tablas, anexos ni referencias |
| Formato | PDF, letra 12, interlineado 1,5, normas APA 7 |

## Objetivo

En este parcial usted diseñará un proyecto de investigación cuantitativo que pueda ejecutarse en cuatro semanas con datos secundarios disponibles hoy. El proyecto debe estar inspirado en el feminismo de datos (D'Ignazio y Klein, 2020). Eso significa que no basta con desagregar por sexo: los datos deben servir para examinar cómo se distribuye el poder, y hay que interrogar cómo fueron producidas las cifras que se usan. No se evalúa la ejecución del análisis, sino la calidad, coherencia y viabilidad del diseño.

## Punto de partida: los siete principios del feminismo de datos

Su proyecto debe apoyarse explícitamente en al menos dos de estos principios. Debe mostrar cómo cada uno orienta decisiones concretas del diseño, no solo mencionarlo en la introducción.

| Principio | Pregunta guía para su proyecto |
|---|---|
| Examinar el poder | ¿Qué desigualdad estructural hace visible mi análisis? ¿Quién gana y quién pierde? |
| Desafiar el poder | ¿Mi análisis podría usarse para cuestionar una narrativa o política dominante? |
| Elevar la emoción y la corporalidad | ¿Cómo comunico los resultados sin borrar la experiencia de las personas detrás de los números? |
| Repensar binarios y jerarquías | ¿Qué categorías de mi fuente simplifican o excluyen (sexo binario, "jefe de hogar", "inactivo")? |
| Abrazar el pluralismo | ¿Qué otros saberes o fuentes (organizaciones, contradatos) complementan la mirada estadística? |
| Considerar el contexto | ¿Quién produjo estos datos, con qué propósito y bajo qué condiciones? |
| Hacer visible el trabajo | ¿Qué trabajo, a menudo invisible, está detrás de los datos y de mi propio proyecto? |

## Estructura obligatoria del proyecto

### 1. Título y resumen

Un título informativo y un resumen de máximo 150 palabras que indique la pregunta, la fuente, las variables principales y el aporte desde el feminismo de datos.

### 2. Definición del objeto de investigación

Distinga claramente entre tema (por ejemplo, "trabajo de cuidado") y objeto (por ejemplo, "la distribución del tiempo dedicado al cuidado no remunerado entre mujeres y hombres de hogares urbanos colombianos según nivel de ingreso, 2020–2021"). Esta sección debe incluir el problema y su relevancia sociológica, una pregunta de investigación principal (y máximo dos secundarias) formulada en términos medibles, la delimitación de población, territorio y periodo, y un argumento sobre qué principios del feminismo de datos orientan el objeto y por qué.

### 3. Fuentes estadísticas

Use al menos una fuente oficial de microdatos o de datos agregados descargables. Para cada fuente presente una ficha técnica con productor, año o años, universo y unidad de análisis, tipo de diseño (censo, encuesta por muestreo, registro administrativo), cobertura, forma de acceso y documentación consultada (cuestionario, diccionario de datos, metodología).

Añada después una breve biografía de los datos, de media página a una página: quién decidió contar esto, con qué fin, qué categorías usa, quién queda fuera o mal representado y qué riesgos de subregistro existen. Puede complementar con contradatos producidos por organizaciones sociales, siempre que discuta su método y sus límites.

### 4. Variables a analizar

Presente una tabla de operacionalización con, como mínimo, una variable dependiente y dos independientes. [Ver explicación] (https://repositorio-uapa.cuaed.unam.mx/repositorio/moodle/pluginfile.php/3217/mod_resource/content/1/UAPA-Las-Variables-y-su-Clasificacion/index.html) 
La tabla debe tener estas columnas:

| Concepto | Nombre en la base | Pregunta del cuestionario | Nivel de medición | Categorías o rango | Rol en el análisis | Transformación prevista |
|---|---|---|---|---|---|---|
| | | | | | | |

Además, elija al menos una variable y discuta críticamente cómo fue construida por la fuente. Algunas opciones son la variable sexo y la ausencia de otras identidades de género, la noción de jefatura de hogar, la frontera entre trabajo y "oficios del hogar" o la categoría étnica autorreconocida. Explique cómo esa construcción limita o sesga su análisis y qué hará al respecto.

### 5. Hipótesis

Formule exactamente dos hipótesis que se desprendan de su pregunta de investigación. Cada una debe nombrar explícitamente la variable dependiente y al menos una independiente de su tabla de operacionalización. También debe indicar la dirección esperada de la relación (mayor o menor, más o menos) y la población a la que se refiere. Acompañe cada hipótesis con una o dos frases que la justifiquen desde la literatura o desde alguno de los principios del feminismo de datos.

**Ejemplos de hipótesis bien formuladas**

*Con la ENUT:*

- **H1.** En los hogares urbanos colombianos, las mujeres dedican más horas semanales al trabajo de cuidado no remunerado que los hombres, y esa brecha es mayor en los quintiles de ingreso más bajos.
- **H2.** La brecha de horas de cuidado entre mujeres y hombres es mayor en los hogares donde hay niñas o niños menores de cinco años que en los hogares sin menores.

*Con la GEIH:*

- **H1.** Entre personas ocupadas con educación universitaria completa, las mujeres reciben ingresos laborales mensuales inferiores a los de los hombres.
- **H2.** La brecha de ingresos entre mujeres y hombres es mayor en el empleo informal que en el formal.

*Con la ENDS y Forensis:*

- **H1.** La proporción de mujeres que declaran en encuesta haber sufrido violencia física de pareja es mayor que la tasa de casos registrados por Medicina Legal en el mismo departamento.
- **H2.** La distancia entre violencia declarada y registrada es mayor en los departamentos con mayor proporción de población rural.

**Ejemplo de hipótesis mal formulada**

> "La desigualdad de género afecta a las mujeres en el mercado laboral."

No identifica variables medibles, ni dirección, ni población, así que no puede contrastarse con datos.

### 6. Plan de trabajo de cuatro semanas

Presente un cronograma realista. Como referencia:

| Semana | Actividades mínimas | Producto |
|---|---|---|
| 1 | Descarga de datos, lectura de documentación, selección y recodificación de variables | Base depurada y script de limpieza en R |
| 2 | Análisis descriptivo univariado y primeras visualizaciones | Tablas y gráficos descriptivos |
| 3 | Análisis bivariado y contraste de hipótesis | Resultados preliminares |
| 4 | Interpretación, reflexión feminista sobre los hallazgos, redacción | Informe final y repositorio del código |

Identifique al menos dos riesgos que podrían retrasar el proyecto (por ejemplo, variables mal documentadas, bases muy pesadas, pocos casos en subgrupos) y un plan de contingencia para cada uno.

### 7. Consideraciones éticas, límites y trabajo visible

Discuta riesgos de estigmatización, anonimato y usos posibles de sus resultados. Cierre con una declaración de créditos: quién hizo qué dentro del equipo, qué fuentes, personas o herramientas (incluidas herramientas de IA, si las usó) contribuyeron al proyecto.

### 8. Referencias

En APA 7, incluyendo la documentación técnica de las fuentes.

## Fuentes sugeridas

Estas fuentes son un punto de partida, no una lista cerrada. Verifique la disponibilidad y la última versión antes de elegir.

| Fuente | Productor | Temas posibles |
|---|---|---|
| Encuesta Nacional de Uso del Tiempo (ENUT) | DANE | Trabajo de cuidado no remunerado, distribución del tiempo |
| Gran Encuesta Integrada de Hogares (GEIH) | DANE | Brechas de ingreso, informalidad, participación laboral |
| Encuesta de Calidad de Vida (ECV) | DANE | Condiciones del hogar, jefatura, acceso a servicios |
| Estadísticas vitales | DANE | Embarazo adolescente, mortalidad materna |
| Encuesta Nacional de Demografía y Salud (ENDS) | MinSalud / Profamilia | Salud sexual y reproductiva, violencia de pareja |
| Forensis y boletines de violencia | Medicina Legal | Violencia sexual, violencia intrafamiliar, feminicidios |
| SIVIGILA (evento de violencia de género) | INS | Notificación de violencias por territorio |
| Resultados electorales | Registraduría | Participación y elección de mujeres candidatas |
| Saber 11 / SNIES | ICFES / MinEducación | Brechas educativas, elección de carreras |
| Observatorio Colombiano de las Mujeres | Vicepresidencia / DANE | Indicadores de género agregados |

## Ejemplos de preguntas (ilustrativos, no para copiar)

- ¿Cómo varía la brecha de horas dedicadas al cuidado no remunerado entre mujeres y hombres según quintil de ingreso y zona urbana o rural (ENUT)?
- ¿Persiste la brecha de ingresos laborales entre mujeres y hombres con el mismo nivel educativo en las principales ciudades (GEIH)?
- ¿Qué relación existe entre la tasa de fecundidad adolescente y la pobreza multidimensional a nivel municipal (estadísticas vitales e IPM)?
- ¿Qué distancia hay entre la violencia de pareja declarada en encuesta y la registrada por Medicina Legal, y qué dice esa distancia sobre el subregistro (ENDS y Forensis)?

## Criterios de viabilidad

El proyecto no debe requerir recolección de datos primarios. Los datos deben ser descargables desde ya, y la base resultante debe poder trabajarse en R en un computador personal. Si propone combinar fuentes, explique la variable de unión (por ejemplo, código DIVIPOLA) y verifique que los periodos sean comparables.

## Rúbrica de evaluación

| Criterio | Peso |
|---|---|
| Definición del objeto: pregunta clara, medible y delimitada; relevancia sociológica | 20 % |
| Fuentes estadísticas: ficha técnica completa y biografía crítica de los datos | 20 % |
| Variables: operacionalización coherente, niveles de medición correctos, crítica de al menos una categoría | 25 % |
| Hipótesis: dos hipótesis contrastables, coherentes con la pregunta y la tabla de variables | 10 % |
| Integración del feminismo de datos: principios que orientan decisiones concretas y no son decorativos | 15 % |
| Viabilidad y plan de cuatro semanas: cronograma realista, riesgos y contingencias | 5 % |
| Escritura, créditos y referencias | 5 % |
| **Total** | **100 %** |

## Lecturas de apoyo

- D'Ignazio, C. y Klein, L. F. (2020). *Data Feminism*. MIT Press. Acceso abierto en https://data-feminism.mitpress.mit.edu
- Criado Perez, C. (2019). *Invisible Women: Exposing Data Bias in a World Designed for Men*. Chatto & Windus.

