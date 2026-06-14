import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de la App'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Launcher Icon in Large Format with Premium Styling
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFFFD700), // Gold border
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'World Cup Schedule App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            // Version Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E294B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                'v0.6.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Personal FIFA World Cup 2026 Match Tracker',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            // Features Card
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CARACTERÍSTICAS PRINCIPALES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1E294B).withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  _buildFeatureRow(
                    Icons.calendar_month_outlined,
                    'Calendario de Partidos',
                    'Consulta los 104 partidos del fixture oficial del Mundial 2026.',
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildFeatureRow(
                    Icons.favorite_border_rounded,
                    'Favoritos Offline',
                    'Guarda tus partidos preferidos con persistencia local.',
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildFeatureRow(
                    Icons.filter_alt_outlined,
                    'Filtros Avanzados',
                    'Filtra por selección, ciudad, fase y estado de resultados.',
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildFeatureRow(
                    Icons.schedule,
                    'Estatus en Tiempo Real',
                    'Controla partidos hoy, mañana, en curso y terminados.',
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildFeatureRow(
                    Icons.emoji_events_outlined,
                    'Marcadores Offline',
                    'Captura y edita marcadores manuales de partidos jugados.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Footer credits
            const Text(
              'FIFA World Cup 2026™ Match Schedule App\nDesarrollado para fans del fútbol offline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white38,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E294B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00FF87),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
