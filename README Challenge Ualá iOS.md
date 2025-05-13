\# Mobile Challenge \- Ualá (Solución iOS en SwiftUI)

Esta aplicación iOS fue desarrollada como solución al "Mobile Challenge \- Ualá". Permite a los usuarios explorar una extensa lista de ciudades (aproximadamente 200,000), filtrarlas de manera eficiente por el prefijo del nombre, visualizar su ubicación en un mapa interactivo, gestionar una lista de ciudades favoritas y acceder a información detallada de cada una.

\#\# 🚀 Características Implementadas

\* \*\*Descarga de Datos:\*\* Carga y parseo de la lista completa de ciudades desde el Gist proporcionado.  
\* \*\*Búsqueda Optimizada:\*\* Filtrado por prefijo del nombre de la ciudad, insensible a mayúsculas/minúsculas y diacríticos, optimizado para un gran conjunto de datos.  
\* \*\*Visualización Ordenada:\*\* Muestra las ciudades en una lista desplazable, ordenadas alfabéticamente (primero el nombre de la ciudad, luego el código del país).  
\* \*\*UI Responsiva:\*\* La lista de ciudades se actualiza dinámicamente al escribir en el campo de búsqueda, con un mecanismo de \`debounce\` para mejorar la experiencia.  
\* \*\*Gestión de Favoritos:\*\*  
    \* Permite marcar y desmarcar ciudades como favoritas.  
    \* Los favoritos se guardan y persisten entre sesiones de la aplicación (\`UserDefaults\`).  
    \* Opción para filtrar la lista y mostrar únicamente las ciudades favoritas.  
\* \*\*Detalle de Ciudad en Celda:\*\* Cada celda en la lista muestra:  
    \* Nombre de la ciudad y código del país.  
    \* Coordenadas geográficas (latitud y longitud).  
    \* Un botón para alternar el estado de favorito.  
    \* Un botón para mostrar una pantalla de información detallada.  
\* \*\*Integración de Mapa:\*\* Al seleccionar una ciudad de la lista, se muestra un mapa (\`MKMapView\`) centrado en sus coordenadas con un marcador.  
\* \*\*Pantalla de Información Adicional:\*\* Se presenta una vista modal (sheet) con detalles adicionales de la ciudad seleccionada.  
\* \*\*Interfaz de Usuario Dinámica (Adaptativa):\*\*  
    \* \*\*Modo Portrait:\*\* Lista y mapa/detalle en pantallas separadas (navegación tipo pila).  
    \* \*\*Modo Landscape:\*\* Lista y mapa/detalle en una única pantalla con dos paneles (usando \`NavigationSplitView\`).  
\* \*\*Pruebas Rigurosas:\*\*  
    \* \*\*Tests Unitarios:\*\* Para la lógica del algoritmo de búsqueda, el servicio de persistencia de favoritos y el \`CitiesViewModel\`.  
    \* \*\*Tests de UI (XCUITest):\*\* Para los flujos principales de la aplicación, incluyendo la carga de datos, búsqueda, selección de ciudades, visualización de detalles/mapa y la pantalla de información.  
\* \*\*Preprocesamiento de Datos:\*\* La lista de ciudades se ordena una vez al cargar para optimizar las búsquedas subsecuentes.  
\* \*\*Tecnología Nativa:\*\* Desarrollado completamente en SwiftUI, utilizando la última versión de Swift y iOS, sin librerías de terceros, cumpliendo con los requisitos del challenge.

\#\# 🛠️ Enfoque Técnico y Decisiones de Diseño

\#\#\# 1\. Arquitectura de Software  
La aplicación adopta el patrón de diseño \*\*MVVM (Model-View-ViewModel)\*\*, ideal para desarrollos con SwiftUI y Combine, facilitando un manejo de estado reactivo y una clara separación de concerns:

\* \*\*Model:\*\*  
    \* \`City\`: Estructura \`Codable\` e \`Identifiable\` para representar cada ciudad. Incluye \`\_id\`, \`name\`, \`country\`, y \`coord\`.  
    \* \`Coordinate\`: Estructura \`Codable\` para \`lat\` y \`lon\`.  
    \* Se añade una propiedad computada \`displayName\` (\`"\\(name), \\(country)"\`) para la visualización y \`sortKey\` (\`"\\(name.lowercased()), \\(country.lowercased())"\`) para un ordenamiento alfabético consistente e insensible a mayúsculas/minúsculas.  
\* \*\*View:\*\*  
    \* Todas las vistas están construidas con SwiftUI (\`ContentView\`, \`CitiesListView\`, \`CityRowView\`, \`CityDetailView\`, \`MapView\`, \`CityInfoSheetView\`).  
    \* \`NavigationSplitView\` es el componente central en \`ContentView\` para la UI adaptativa Portrait/Landscape.  
\* \*\*ViewModel:\*\*  
    \* \`CitiesViewModel\`: Clase \`ObservableObject\` que maneja la lógica de presentación, el estado de la UI (ciudades filtradas, texto de búsqueda, estado de carga, favoritos), y la comunicación con los servicios (red, persistencia, búsqueda).

\#\#\# 2\. Descarga y Preprocesamiento de Datos  
\* Los datos de las ciudades se obtienen del Gist especificado mediante \`CityNetworkService\`, que utiliza \`URLSession\` y el framework \`Combine\` para operaciones asíncronas.  
\* Al recibir los datos, se decodifican en un array \`\[City\]\`.  
\* \*\*Preprocesamiento Clave:\*\* La lista completa (\`allCities\` en \`CitiesViewModel\`) se \*\*ordena una única vez\*\* después de la descarga, utilizando la \`sortKey\`. Este paso es fundamental para la eficiencia del algoritmo de búsqueda por prefijo implementado, ya que el challenge prioriza la velocidad de búsqueda sobre el tiempo de carga inicial.

\#\#\# 3\. Optimización de la Búsqueda por Prefijo  
Dado el requisito de optimizar para búsquedas rápidas en \~200k entradas, se implementó la siguiente estrategia en \`OptimizedPrefixSearchService\`:

1\.  La búsqueda opera sobre la lista \`allCities\` (previamente ordenada por \`sortKey\`).  
2\.  Se utiliza una \*\*búsqueda binaria (lower bound)\*\* para localizar eficientemente el índice del primer elemento cuya \`sortKey\` es mayor o igual al prefijo de búsqueda (convertido a minúsculas). Esto reduce la complejidad de la localización inicial a O(log N).  
3\.  Desde este índice, se itera secuencialmente hacia adelante. Para cada ciudad:  
    \* El nombre de la ciudad (en minúsculas) se compara con el prefijo de búsqueda usando \`String.range(of:options:)\` con las opciones \`\[.anchored, .diacriticInsensitive, .caseInsensitive\]\`. Esto asegura una comparación de prefijo precisa, insensible a mayúsculas/minúsculas y a diacríticos (p. ej., "cordoba" encuentra "Córdoba").  
4\.  La iteración se detiene de forma optimizada tan pronto como la \`sortKey\` de una ciudad ya no puede comenzar con el prefijo, evitando recorrer innecesariamente el resto del array.  
5\.  Un \`debounce\` de 300ms se aplica al \`TextField\` de búsqueda para mejorar la responsividad y evitar ejecuciones excesivas del filtro durante el tecleo rápido.

\#\#\# 4\. Gestión y Persistencia de Favoritos  
\* Un \`Set\<Int\>\` en \`CitiesViewModel\` (\`favoriteCityIDs\`) almacena los IDs de las ciudades marcadas como favoritas.  
\* \`UserDefaultsFavoritesService\` se encarga de la persistencia, guardando y cargando este conjunto de IDs en \`UserDefaults\`, asegurando que los favoritos se recuerden entre sesiones.

\#\#\# 5\. Interfaz de Usuario Dinámica y Navegación  
\* \`ContentView\` utiliza \`NavigationSplitView\` para presentar una interfaz de dos columnas en modo landscape (lista y detalle/mapa) y una navegación de pila en modo portrait.  
\* La selección de una ciudad en \`CitiesListView\` actualiza una propiedad \`@State selectedCityID\` en \`ContentView\`, lo que provoca que el panel de detalle de \`NavigationSplitView\` muestre la \`CityDetailView\` correspondiente.  
\* La pantalla de información adicional se presenta como un sheet modal (\`CityInfoSheetView\`) desde \`CitiesListView\`.

\#\#\# 6\. Pruebas  
Se ha puesto énfasis en la calidad y robustez mediante la implementación de:  
\* \*\*Tests Unitarios:\*\*  
    \* \`OptimizedPrefixSearchServiceTests\`: Validan el algoritmo de búsqueda con diversos prefijos, incluyendo casos límite y entradas "inválidas" (prefijos no coincidentes).  
    \* \`UserDefaultsFavoritesServiceTests\`: Aseguran la correcta funcionalidad de guardado y carga de favoritos.  
    \* \`CitiesViewModelTests\`: Prueban la lógica de carga de datos, aplicación de filtros combinados (texto y favoritos), manejo de estados (carga, error) y la interacción con los servicios mockeados.  
\* \*\*Tests de UI (XCUITest):\*\*  
    \* \`CityListUITests\`: Cubren los flujos de usuario esenciales como el lanzamiento de la app, la carga de la lista, la funcionalidad de búsqueda, la selección de una ciudad para ver su detalle en el mapa, y la apertura de la pantalla de información. Se utilizan \`accessibilityIdentifier\` para mejorar la robustez de los selectores.

\#\#\# 7\. Suposiciones Realizadas  
\* La estructura del JSON del Gist es estable y no cambia.  
\* El requisito de "información de la ciudad" para la pantalla modal se interpreta como mostrar los datos básicos disponibles (nombre, país, coordenadas, ID).  
\* El ordenamiento "ciudad primero, país después" se logra mediante la comparación de la \`sortKey\` (ej. \`"buenos aires, ar"\`).  
