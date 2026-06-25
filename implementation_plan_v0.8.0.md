# Plan de Implementación: Knockout Bracket Dashboard (v0.8.0)

Este plan detalla los pasos para diseñar, implementar y probar la funcionalidad de clasificación a la fase eliminatoria y el visualizador del bracket de dieciseisavos de final del Mundial 2026.

## Propósito
Integrar un algoritmo dinámico que analice el estado del torneo en tiempo real (100% offline) y determine los clasificados a dieciseisavos (primeros, segundos y mejores terceros lugares), mostrando esta información en un nuevo panel de control ("Llaves" / "Bracket") y en las tablas de posiciones de grupos ya existentes.

---

## User Review Required

> [!IMPORTANT]
> **Resolución de Terceros Lugares:** En esta versión `v0.8.0`, tal como se solicita en los requisitos de diseño, los emparejamientos exactos de los mejores terceros lugares no se resolverán de acuerdo a la grilla oficial de la FIFA (que contempla 495 combinaciones). En su lugar, se mostrarán como **"Mejor 3° pendiente"** o **"Best 3rd TBD"** hasta la siguiente versión. Los primeros y segundos lugares se resolverán automáticamente tan pronto como se complete su respectivo grupo.

---

## Open Questions

No hay preguntas abiertas en este momento. La especificación cubre todos los requerimientos y escenarios de manera precisa.

---

## Proposed Changes

### [Component: Knockout Feature]

#### [NEW] [qualification_type.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/models/qualification_type.dart)
- Definición del enum `QualificationType` con valores: `groupWinner`, `groupRunnerUp`, `bestThirdPlace`.

#### [NEW] [qualified_team.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/models/qualified_team.dart)
- Definición de la clase `QualifiedTeam` con campos: `team`, `groupId`, `groupName`, `groupPosition`, `standing`, `qualificationType`.

#### [NEW] [knockout_qualification_result.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/models/knockout_qualification_result.dart)
- Definición de la clase contenedora de resultados de clasificación: `groupWinners`, `groupRunnersUp`, `bestThirdPlacedTeams`, `allQualifiedTeams`, `eliminatedThirdPlacedTeams`.

#### [NEW] [knockout_match_slot.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/models/knockout_match_slot.dart)
- Definición de la clase `KnockoutMatchSlot` con campos: `matchNumber`, `round`, `slotA`, `slotB`, `teamA`, `teamB`.

#### [NEW] [knockout_qualification_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/services/knockout_qualification_service.dart)
- Algoritmo que recibe `Map<String, List<GroupStanding>>` y calcula los clasificados:
  - Identifica el 1° y 2° lugar de cada grupo.
  - Recolecta el 3° de cada grupo y los ordena (Puntos, DG, GF, Nombre en inglés) para seleccionar los 8 mejores y marcar los 4 eliminados.

#### [NEW] [knockout_bracket_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/services/knockout_bracket_service.dart)
- Servicio que procesa partidos del calendario del 73 al 88 (`round_of_32`):
  - Verifica si el grupo relacionado está completo para resolver dinámicamente slots como `group_a_runners-up` o `group_e_winners`.
  - Mapea los slots de terceros a TBD temporalmente.

#### [NEW] [knockout_dashboard_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/screens/knockout_dashboard_screen.dart)
- Pantalla principal del dashboard con pestañas internas o secciones colapsables (Clasificados por grupo, Mejores terceros, Eliminados, y Llave eliminatoria).

#### [NEW] [qualification_badge.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/qualification_badge.dart)
- Widget visual reutilizable para mostrar el estado del equipo: "Clasificado", "Mejor tercero", "Eliminado", "Pendiente" con colores adaptativos de neón.

#### [NEW] [qualified_teams_section.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/qualified_teams_section.dart)
- Widget que renderiza la lista de clasificados agrupados por grupo (A-L).

#### [NEW] [best_third_places_section.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/best_third_places_section.dart)
- Widget para mostrar el ranking de los mejores terceros lugares (clasificados y eliminados).

#### [NEW] [knockout_bracket_view.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/knockout_bracket_view.dart)
- Visualización de la llave de eliminación directa mostrando las 16 tarjetas de dieciseisavos.

#### [NEW] [knockout_match_card.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/knockout_match_card.dart)
- Tarjeta de partido simplificada para las llaves, mostrando los equipos resueltos o su marcador de posición TBD, con flags vectoriales.

---

### [Component: Core and Translations]

#### [MODIFY] [app_translations.json](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/assets/data/app_translations.json)
- Agregar traducciones requeridas (ej: `knockoutTitle`, `qualifiedTeams`, `qualifiedStatus`, `bestThirdStatus`, `eliminatedStatus`, `pendingStatus`, `bestThirds`, `knockoutBracket`, `group`, `groupWinner`, `groupRunnerUp`, `bestThirdTbd`, `notEnoughResults`).

#### [MODIFY] [match_list_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/matches/screens/match_list_screen.dart)
- Integrar la pestaña "Llaves" en el BottomNavigationBar (índice 3).
- Importar y renderizar `KnockoutDashboardScreen`.

#### [MODIFY] [standings_table.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/standings/widgets/standings_table.dart)
- Reemplazar el badge simple de "Clasifica" por el nuevo `QualificationBadge` dinámico para cada una de las 4 posiciones del grupo (siguiendo las reglas de grupo completo o pendiente).

---

## Verification Plan

### Automated Tests
Generaremos los archivos de pruebas requeridos:
- **[NEW]** `test/features/knockout/services/knockout_qualification_service_test.dart` (10 casos de prueba descritos en la especificación).
- **[NEW]** `test/features/knockout/services/knockout_bracket_service_test.dart` (5 casos de prueba descritos en la especificación).

Ejecutaremos los tests con:
```bash
flutter test
```

### Manual Verification
1. Comprobar que no hay resultados y verificar el estado vacío ("Aún no hay suficientes resultados para calcular clasificados").
2. Entrar a partidos y simular resultados para completar grupos:
   - Registrar marcadores en todos los partidos del Grupo A y verificar que el 1° y 2° cambian de "Pendiente" a "Clasificado" en la tabla de posiciones y en el dashboard de Llaves.
   - Completar todos los grupos (A-L) y validar el ranking de mejores terceros, asegurando que se ordenan correctamente y que se resuelven los slots de la ronda de 32.
3. Comprobar que el cambio de idioma (inglés/español) funciona dinámicamente en todo el dashboard.
