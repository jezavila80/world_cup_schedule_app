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

## 📅 Cronograma y Registro de Versiones

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
