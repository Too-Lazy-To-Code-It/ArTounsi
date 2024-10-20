import 'package:flutter/material.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({Key? key}) : super(key: key);

  @override
  _LearningPageState createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  String _searchTerm = '';
  int _selectedTabIndex = 0;

  // Mock data for courses
  final List<Map<String, dynamic>> _courses = [
    {'id': 1, 'title': 'Fondamentaux du dessin', 'type': 'course', 'progress': 60},
    {'id': 2, 'title': 'Peinture numérique avancée', 'type': 'course', 'progress': 30},
    {'id': 3, 'title': 'Animation 3D pour débutants', 'type': 'course', 'progress': 0},
    {'id': 4, 'title': 'Techniques de sculpture digitale', 'type': 'video', 'progress': 80},
    {'id': 5, 'title': 'Atelier en direct: Concept Art', 'type': 'workshop', 'progress': 0},
  ];

  // Mock data for certificates
  final List<Map<String, dynamic>> _certificates = [
    {'id': 1, 'title': 'Maîtrise du dessin digital', 'date': '2023-05-15'},
    {'id': 2, 'title': 'Expert en animation 2D', 'date': '2023-03-22'},
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    return _courses.where((course) =>
        course['title'].toLowerCase().contains(_searchTerm.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion d\'apprentissage'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildCourseList(),
              const SizedBox(height: 24),
              _buildCertificatesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher des cours...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchTerm = value;
        });
      },
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 4,
      child: TabBar(
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        tabs: const [
          Tab(text: 'Tous'),
          Tab(text: 'Cours'),
          Tab(text: 'Vidéos'),
          Tab(text: 'Ateliers'),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    List<Map<String, dynamic>> displayedCourses = _filteredCourses;
    if (_selectedTabIndex > 0) {
      String type = ['course', 'video', 'workshop'][_selectedTabIndex - 1];
      displayedCourses = displayedCourses.where((course) => course['type'] == type).toList();
    }

    return Column(
      children: displayedCourses.map((course) => _buildCourseCard(course)).toList(),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    IconData icon;
    String typeText;
    switch (course['type']) {
      case 'course':
        icon = Icons.book;
        typeText = 'Cours';
        break;
      case 'video':
        icon = Icons.video_library;
        typeText = 'Vidéo';
        break;
      case 'workshop':
        icon = Icons.groups;
        typeText = 'Atelier en direct';
        break;
      default:
        icon = Icons.school;
        typeText = 'Inconnu';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    course['title'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(typeText, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (course['progress'] > 0) ...[
              Text('Progression: ${course['progress']}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: course['progress'] / 100),
            ] else
              Text('Pas encore commencé', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement course start/continue logic
              },
              child: Text(course['progress'] > 0 ? 'Continuer' : 'Commencer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes certificats', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ..._certificates.map((cert) => _buildCertificateCard(cert)),
      ],
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> cert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cert['title'], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Obtenu le ${cert['date']}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement view certificate logic
              },
              child: const Text('Voir le certificat'),
            ),
          ],
        ),
      ),
    );
  }
}