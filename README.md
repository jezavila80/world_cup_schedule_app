# FIFA World Cup 2026™ Schedule App

Una aplicación móvil moderna, inmersiva y de alto rendimiento desarrollada en Flutter para consultar el calendario oficial de los 104 partidos de la Copa Mundial de la FIFA 2026™. La aplicación cuenta con conversión dinámica de zonas horarias locales, sistema de favoritos offline, filtros avanzados y una interfaz visual premium inspirada en noches de estadio.

---

## 🚀 Características Principales

- **Calendario Oficial de 104 Partidos**: Datos reales y oficiales extraídos de la programación de la FIFA, incluyendo fase de grupos y todas las fases de eliminación directa.
- **Zonas Horarias Inteligentes**: Muestra tanto la hora local del estadio (con desfases reales según la ciudad sede) como la hora local de tu dispositivo, asegurando que nunca te pierdas un partido.
- **Banderas Vectoriales Offline (CustomPainter)**: Sistema de rendering nativo y offline basado en vectores para representar con alta fidelidad visual las banderas de los 48 equipos participantes, evitando la carga lenta de imágenes por red.
- **Buscador y Filtros Avanzados**: Filtra partidos por ciudad sede, fecha específica, fase del torneo o busca directamente escribiendo el nombre de tu selección preferida.
- **Sistema de Favoritos**: Guarda partidos de interés localmente utilizando almacenamiento persistente offline (`SharedPreferences`).
- **Simulador de Alineaciones**: Vista detallada de partidos con un campo de fútbol visualizado en perspectiva con posibles formaciones y alineaciones.
- **Detalle de Estadios Oficiales**: Información técnica real de las 16 sedes de Norteamérica (capacidad oficial, tipo de césped y año de inauguración).

---

## 🛠️ Requisitos Técnicos y Dependencias

- **Flutter SDK**: `^3.5.1` (o compatible con Dart `^3.5.1`)
- **Plataformas Soportadas**: Android, iOS, Windows, macOS, Linux, Web.
- **Dependencias del Proyecto**:
  - `shared_preferences: ^2.2.3` — Para el almacenamiento local de favoritos.
  - `cupertino_icons: ^1.0.8` — Para iconografía complementaria.
  - **Pruebas (`dev_dependencies`)**: `flutter_test` y `flutter_lints` para análisis estático y pruebas de widgets.

---

## 📂 Estructura de Carpetas (`lib/`)

```text
lib/
├── main.dart                 # Punto de entrada de la aplicación e inicialización de servicios.
├── app.dart                  # Declaración de MaterialApp, tema oscuro y paleta de colores.
├── core/
│   └── storage/
│       └── favorites_storage.dart  # Persistencia de partidos favoritos (SharedPreferences).
└── features/
    └── matches/
        ├── data/
        │   ├── flag_style_repository.dart  # Carga y parseo de las banderas nacionales.
        │   ├── match_local_data_source.dart # Lector del JSON de partidos en los assets.
        │   └── match_repository.dart       # Repositorio centralizador de datos de partidos.
        ├── models/
        │   ├── flag_style.dart           # Estilos gráficos de las banderas (patrones, colores).
        │   ├── world_cup_match.dart      # Modelo de partido, estados (Live, Finished) y zonas horarias.
        │   ├── match_result_status.dart  # Enum para el estado de marcador (pending, completed).
        │   └── match_lifecycle_status.dart # Enum para el ciclo de vida del partido (upcoming, today, live, finished).
        ├── services/
        │   └── match_result_service.dart # Persistencia offline de los marcadores guardados (SharedPreferences).
        ├── screens/
        │   ├── match_detail_screen.dart  # Detalle del partido, datos de estadios y alineaciones.
        │   └── match_list_screen.dart    # Dashboard con pestañas, filtros y listado de partidos.
        └── widgets/
            ├── flag_circle_avatar.dart   # Widget de bandera pintada dinámicamente con CustomPainter.
            ├── match_card.dart           # Tarjetas de partido reutilizables con flags y detalles.
            ├── score_display.dart        # Marcador visual de goles para partidos completados.
            ├── match_result_badge.dart   # Etiqueta indicadora de estatus de partido finalizado.
            └── edit_result_dialog.dart   # Modal de captura interactivo con controles incremento/decremento.
    └── standings/
        ├── models/
        │   └── group_standing.dart       # Modelo de estadísticas de tabla por selección.
        ├── services/
        │   └── group_standings_service.dart # Servicio de cálculo de standings en tiempo real.
        ├── screens/
        │   └── group_standings_dashboard_screen.dart # Dashboard principal de las tablas de posiciones.
        └── widgets/
            ├── group_standings_card.dart # Tarjeta contenedora de grupo con cabecera y tabla.
            ├── standings_table.dart      # Tabla responsiva con columnas congeladas y scroll horizontal.
            └── qualified_badge.dart      # Badge de clasificado ("Clasifica" / "Qualified").
    └── knockout/
        ├── models/
        │   ├── qualification_type.dart   # Enum con tipos de clasificación.
        │   ├── qualified_team.dart       # Modelo de datos para un equipo clasificado.
        │   ├── knockout_qualification_result.dart # Resultados agregados de clasificados de grupos.
        │   └── knockout_match_slot.dart  # Ranura de partido con equipos o TBD.
        ├── services/
        │   ├── knockout_qualification_service.dart # Lógica de ordenación y clasificación de mejores terceros.
        │   └── knockout_bracket_service.dart       # Resolución de emparejamientos de dieciseisavos.
        ├── screens/
        │   └── knockout_dashboard_screen.dart      # Pantalla con pestañas de clasificados y llaves.
        └── widgets/
            ├── qualification_badge.dart  # Indicador dinámico de estado (Clasificado, Pendiente, etc).
            ├── qualified_teams_section.dart  # Lista de clasificados directos (1° y 2°).
            ├── best_third_places_section.dart # Tabla ordenadora de terceros lugares.
            ├── knockout_match_card.dart  # Tarjeta de partido para bracket.
            └── knockout_bracket_view.dart # Visualizador del bracket de Ronda de 32.

```

---

## 🚀 Pasos de Instalación y Ejecución Local

1. **Clonar el Repositorio**:
   ```bash
   git clone <url-del-repositorio>
   cd world_cup_schedule_app
   ```

2. **Obtener Dependencias**:
   ```bash
   flutter pub get
   ```

3. **Verificar Compilación y Lints**:
   ```bash
   flutter analyze
   ```

4. **Ejecutar Pruebas**:
   ```bash
   flutter test
   ```

5. **Ejecutar en Dispositivo o Emulador**:
   - Para listar los dispositivos disponibles:
     ```bash
     flutter devices
     ```
   - Para correr la app en el dispositivo seleccionado:
     ```bash
     flutter run
     ```
   - Para compilar el APK de depuración:
     ```bash
     flutter build apk --debug
     ```

---

## 🗺️ Mapa de Ruta (Roadmap)

Sigue el progreso y la planeación del desarrollo de la aplicación:

```text
v0.5.0 Resultados (Completado)
    │
    ▼
v0.7.0 Tabla de grupos (Completado)
    │
    ▼
v0.7.5 Idioma personalizado (Completado)
    │
    ▼
v0.8.0 Clasificados automáticos (Completado)
    │
    ▼
v0.8.1 Validación del Motor (Completado)
    │
    ▼
v0.8.2 Centralización de Branding (Completado)
    │
    ▼
v0.9.0 Llaves eliminatorias (Próxima fase)
    │
    ▼
v1.0.0 Mundial completo (Versión Final)
```

---

## 📅 Cronograma y Registro de Versiones

### **v1.0.0 (Mundial Completo) - Planificado**
- **Simulación y Cierre**: Cierre del torneo mundialista con estadísticas globales finales y coronación del campeón.

### **v0.9.0 (Llaves Eliminatorias) - Planificado**
- **Cuadro de Eliminación Directa**: Visualización interactiva y responsiva del bracket del mundial (desde dieciseisavos de final hasta la gran final) alimentado dinámicamente con los clasificados.

### **v0.8.2 (Centralized App Branding & Version Management)**
- **Centralización de Branding**: Creación de componentes reutilizables como `WorldCupHeader` y `AppVersionBadge` para estandarizar la cabecera visual y la presentación de la versión en toda la app.
- **Fuente de Verdad de Versión**: Integración de `package_info_plus` para extraer la versión real (`0.8.2+15`) directamente de `pubspec.yaml`, eliminando strings de versión estáticos.
- **Inyección mediante InheritedWidget**: Implementación de `AppInfoScope` para ofrecer acceso síncrono y optimizado a la información de la aplicación en el árbol de widgets sin llamadas asíncronas repetitivas.
- **Actualización de Pantallas**: Migración completa de todos los dashboards, listados, ajustes y la sección Acerca de la App para utilizar el nuevo sistema centralizado.
- **Información del Desarrollador**: Inclusión de una tarjeta de metadatos del sistema (plataforma, locale, tema, build) en la pantalla de validación del motor de torneo.

### **v0.8.1 (Tournament Engine Validation)**
- **Motor de Validación Interno**: Capa de validación para asegurar la integridad de standings, reglas aritméticas de partidos, clasificados automáticos, mejores terceros y slots del bracket (M73-M88).
- **Dashboard de Validación**: Interfaz de depuración accesible desde los ajustes para monitorizar el estado matemático y lógico del torneo en tiempo real.
- **Servicio de Ordenamiento Compartido**: Unificación de las reglas de desempate en standings, mejores terceros y motores de clasificación mediante `StandingSortService`.
- **UI de Ganadores Mejorada**: Visualización detallada de puntos, diferencia de goles (`+5`, `+0`, `-2`) y badges de estado (`Clasificado`/`Pendiente`) para cada selección en la sección Winners.

### **v0.8.0 (Knockout Bracket Dashboard)**
- **Cálculo de Clasificaciones**: Algoritmo para la determinación automática de los clasificados de la fase de grupos (primeros, segundos y selección reglamentaria de los mejores terceros lugares) para nutrir las llaves eliminatorias.
- **Mapeo Dinámico de Ronda de 32**: Resolución de slots de partidos (M73 a M88) a partir de los standings reales (ganadores y segundos lugares) de forma reactiva y offline.
- **UI de Clasificados y Bracket**: Nueva pestaña interactiva con 3 pestañas internas ("Clasificados", "Mejores 3°", "Llaves") para seguir al detalle el estado de clasificación y los cruces definidos o pendientes (TBD).
- **Indicadores Dinámicos en Posiciones**: Integración de badges de estado dinámicos (Clasificado, Mejor 3°, Pendiente, Eliminado) para cada equipo en las tablas de grupo de la app.


### **v0.7.5 (Language Settings Preference)**
- **Selección Manual de Idioma**: Nueva opción en la configuración para alternar manualmente el idioma entre Sistema, Español e Inglés, independientemente de la configuración global del celular.
- **Persistencia Local**: Guardado offline de la preferencia de idioma usando `SharedPreferences`.
- **Cambio en Tiempo Real**: Actualización inmediata del idioma en toda la interfaz sin necesidad de reiniciar la aplicación.


### **v0.7.0 (Group Standings Dashboard)**
- **Dashboard de Posiciones por Grupo**: Nueva pestaña integrada en la barra de navegación para visualizar la tabla de posiciones en tiempo real calculada automáticamente a partir de los marcadores guardados offline.
- **Servicio de Standings**: Algoritmo de cálculo en tiempo real que filtra partidos finalizados de la fase de grupos y clasifica los equipos ordenando por puntos acumulados (3 por victoria, 1 por empate), diferencia de goles, goles a favor y orden alfabético final.
- **Visualización Responsiva Premium**: Tabla adaptativa con columna fija para nombres y banderas de los equipos, y scroll horizontal fluido para métricas detalladas (PJ, G, E, P, GF, GC, DG, PTS), resaltando con badges de "Clasifica" / "Qualified" a los dos primeros clasificados de cada grupo.
- **Internacionalización Completa**: Soporte total en inglés y español respetando la localización actual y reaccionando dinámicamente al cambio de idioma.

### **v0.6.0 (Bilingual Match Data & Locale Detection & Branding)**
- **Soporte Bilingüe (Inglés/Español)**: Migración completa del JSON de partidos y de los strings de la interfaz de usuario (`assets/data/app_translations.json`) para ofrecer localización dinámica basada en el idioma configurado en el dispositivo.
- **Búsqueda Dinámica**: Localización y normalización de consultas de búsqueda (sin acentos, tolerando coincidencia tanto en inglés como en español).
- **Actualización de Vistas**: Traducción automática de estados de partidos, chips de filtros activos, detalles de sede, tarjetas de partido y diálogos de edición de marcador.
- **Integración de Imagen Promocional**: Incorporación de un banner/imagen promocional (`assets/icons/match_promo.jpg`) en la parte superior de la pantalla de detalles de partidos clave (como Argentina vs Austria/Australia) con bordes dorados `#FFFFD700` y sombras suavizadas.

### **v0.5.0 (Gestión de Resultados y Marcadores)**
- **Persistencia Local Offline**: Desarrollo de `MatchResultService` e inyección de dependencias para persistir y recuperar marcadores directamente en el dispositivo (`SharedPreferences`).
- **Editor de Resultados**: Desarrollo de modal interactivo `EditResultDialog` con botones táctiles `-` y `+` para ingresar marcadores de forma fluida, con validaciones integradas para limitar a valores sugeridos de 0 a 20 goles.
- **Visualizador Scoreboard**: Creación de los componentes `ScoreDisplay` y `MatchResultBadge` para reflejar el estado "FINAL" y los goles convertidos en las tarjetas y vista de detalle de partidos finalizados.
- **Progreso del Mundial**: Añadido del widget "World Cup Progress" en el dashboard de partidos con una barra de progreso lineal de Neon y cálculo dinámico de partidos jugados vs programados.
- **Filtro de Marcador**: Implementación de filtros y chips interactivos para filtrar partidos por "Con Marcador" (resultados cargados) y "Sin Marcador" (pendientes).

### **v0.4.0 (Filtros Colapsables y Diseño Centrado en Partidos)**
- Refactorización del dashboard principal para mover las opciones de filtros permanentes a un panel modal `FilterBottomSheet` colapsable.
- Creación de los componentes `FilterState`, `FilterBottomSheet` y `ActiveFilterChips` para la gestión de filtros activos y su descarte dinámico.
- Compactación del diseño y dimensiones verticales de `MatchCard` en un 25-35% (reduciendo márgenes, espaciados, tamaños de avatars de iniciales y fuentes) para permitir la visualización directa de múltiples partidos.
- Creación de una barra horizontal de resumen rápido con estadísticas dinámicas en tiempo real (partidos en curso, hoy, favoritos).
- Limpieza y organización de dependencias de visualización responsivas.

### **v0.3.1 (Corrección de Compilación)**
- Resolución de un fallo de Gradle al compilar y emular en dispositivos móviles debido a un plugin de Kotlin obsoleto (`1.7.10`).
- Actualización de la versión del plugin de Kotlin a `1.9.0` en `android/settings.gradle`.
- Verificación exitosa de compilación del APK y validación del 100% de la suite de pruebas unitarias.

### **v0.3.0 (Calendario Real e Integración de Datos)**
- Migración al calendario oficial de 104 partidos del Mundial 2026.
- Refactorización de `WorldCupMatch.fromJson` para procesar la nueva estructura anidada de equipos (`homeTeam`), sedes (`venue`) e información temporal (`kickoff`).
- Implementación de mapeo automático de zonas horarias locales para las 16 sedes reales (EDT, CDT, PDT y CST de México).
- Inclusión de estadísticas técnicas de los 16 estadios (capacidad, césped, año) en la vista de detalles del partido.

### **v0.2.0 (Sistema de Banderas Offline)**
- Creación del modelo `FlagStyle` y repositorio para mapear las 48 selecciones.
- Implementación de `FlagCircleAvatar` usando `CustomPainter` para dibujar banderas nacionales (patrones de franjas, cruces, círculos y colores oficiales) de forma rápida y sin requerir conexión a internet.
- Integración en las tarjetas de partidos sustituyendo los degradados genéricos anteriores.

### **v0.1.0 (Lanzamiento Base)**
- Estructuración inicial de pantallas y widgets de marcador.
- Diseño visual preliminar de listado y filtrado básico.
- Base de datos simplificada (11 partidos en modo de marcador de posición).
