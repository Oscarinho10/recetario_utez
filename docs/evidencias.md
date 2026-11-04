# Evidencias — Recetario UTEZ

**Nombre:** _Oscar Giovanni Pedraza López_
**Matrícula:** _20233TN143_
**Fecha:** _03/11/2026_
**Dispositivo donde se probó:** _Chrome Windows_

## 1. Del JSON a Dart

| JSON | Campo Dart | Tipo | Regla (obligatorio, tolerado, valor por defecto) |
|---|---|---|---|
| `id` | `id` | `int` | Obligatorio; si falta o no es entero → `FormatException` |
| `name` | `nombre` | `String` | Obligatorio; si falta o no es texto → `FormatException` |
| `cuisine` | `cocina` | `String` | Obligatorio; si falta o no es texto → `FormatException` |
| `prepTimeMinutes` | `minutosPreparacion` | `int` | Obligatorio; si falta o no es entero → `FormatException` |
| `cookTimeMinutes` | `minutosCoccion` | `int` | Obligatorio; si falta o no es entero → `FormatException` |
| `servings` | `porciones` | `int` | Obligatorio; si falta o no es entero → `FormatException` |
| `rating` | `calificacion` | `double` | Obligatorio; se acepta entero o decimal (`num` → `.toDouble()`) |
| `difficulty` | `dificultad` | `Dificultad` | Tolerado: `Easy`/`Medium`/`Hard`; cualquier otro valor → `desconocida` |
| `tags` | `etiquetas` | `List<String>` | Opcional: si falta → `[]`; si no es lista de textos → `FormatException` |
| `ingredients` | `ingredientes` | `List<String>` | Opcional: si falta → `[]`; si no es lista de textos → `FormatException` |
| `instructions`, `image`, `caloriesPerServing`, etc. | — | — | Se ignoran |

## 2. Escenarios probados con el servicio real

| Escenario | Cómo lo provoqué | Qué vio la persona                                                                | Línea de la bitácora | Captura | Prueba del kit que lo cubre |
|---|---|-----------------------------------------------------------------------------------|--|---|---|
| Éxito | Busqué `chicken` | Vi las 8 de 8 recetas con Chicken y 1 rápida.                                     | 200 GET /recipes/search | `01_exito.png` | `etapa3_datos_test.dart`: «200 → PaginaRecetas» |
| Vacío | Busqué `zzzz` | Me salió el mensaje de que no encontraron ninguna receta.                         | 200 GET /recipes/search | `02_vacio.png` | `etapa3_datos_test.dart`: «200 sin resultados → página vacía» |
| Error del servidor | Cambio temporal A (`/http/503`) y busqué | En la pantalla al buscar algo, me salió el error 503                              | badResponse 503 | `03_error_servidor.png` | `etapa3_datos_test.dart`: «503 → ErrorDelServidor(503)» |
| Sin red | Modo avión / sin Wi-Fi (o cambio temporal C) y busqué | Me apareció el error de Sin conexión                                              | connectionError GET /recipes | `04_sin_red.png` | `etapa3_datos_test.dart`: «sin red → SinConexion» |
| Tiempo agotado | Cambio temporal B (`delay=5000`, timeouts de 2 s) y busqué | Después de 2 segundos, me salió el mensaje de que el recetario tardo en responder | receiveTimeout GET /recipes | `05_tiempo_agotado.png` | `etapa3_datos_test.dart`: «connectTimeout/receiveTimeout → TiempoAgotado» |

## 3. Preguntas de reflexión

1. ¿En qué se diferencian el escenario «Error del servidor» y «Sin red» desde el punto de vista de HTTP?

   _Respuesta: En “Error del servidor” sí hubo comunicación HTTP: DummyJSON recibió la petición y respondió con un código 5xx (503). Dio lo reporta como badResponse y sí hay statusCode. En “Sin red” nunca hubo respuesta HTTP: la conexión falló antes (Wi‑Fi apagado/modo avión), Dio lo reporta como connectionError y no existe código de estado. La diferencia clave es que uno tiene respuesta con código y el otro no._

2. ¿Por qué «Vacío» no es un error?

   _Respuesta: Porque el servidor respondió correctamente con 200 y un cuerpo válido con "recipes": [] y total: 0. No falló la red ni el protocolo: simplemente no hay coincidencias. Por eso se muestra el estado RecetasVacias (mensaje “No encontramos recetas…”), distinto de RecetasFallidas._

3. La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?

   _Respuesta: Para no filtrar datos de la persona: lo que escribe puede ser información privada y no debe quedar en logs. Además, la bitácora solo registra método, ruta, código y tiempo; usa options.path (que no incluye la query) en lugar de options.uri o queryParameters. Así se puede depurar sin exponer qué buscó el usuario._

4. Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo esos?

   _Respuesta: Solo lib/datos/recetas_json.dart (la función recetaDesdeJson), porque es la única capa que conoce las llaves del JSON y las traduce a objetos del dominio. El dominio (Receta.calificacion) y las capas de presentación trabajan con el objeto ya convertido, así que no saben si el campo se llamaba rating o score. Por eso el cambio queda aislado en la capa de datos._
