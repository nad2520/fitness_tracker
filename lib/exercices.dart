import 'package:flutter/material.dart';

import 'exercise_images.dart';
import 'fittrack_pages.dart';
import 'routines.dart';

void main() {
  runApp(const MyApp());
}

// Le défilement s'arrête net, sans étirer l'image ni le texte
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const AppScrollBehavior(),
      home: const WelcomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/routines': (context) => const RoutinesPage(),
        '/exercises': (context) => const ExercisesPage(),
      },
    );
  }
}

// Une classe simple (cours Chapitre 1, §4.9)
class Exercise {
  String name;
  String muscles;
  String equipment;
  bool selected;

  Exercise(this.name, this.muscles, this.equipment, this.selected);
}

// Widget réutilisable pour les boutons "Muscle" et "Equipment"
class FilterButton extends StatelessWidget {
  final String label;
  final bool active;

  const FilterButton({super.key, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF7B2150) : const Color(0xFFF3DCE6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: active ? Colors.white : Colors.black),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: active ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }
}

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final Color plum = const Color(0xFF7B2150);
  final TextEditingController searchController = TextEditingController();
  String muscleFilter = "All";
  String equipmentFilter = "All";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Exercise> exercises = [
    Exercise("Hip thrust", "Glutes · Hamstrings", "Barbell · Dumbbells · Bench", true),
    Exercise("Romanian deadlift", "Hamstrings · Glutes", "Dumbbells · Barbell", true),
    Exercise("Goblet squat", "Quads · Glutes", "Dumbbell · Kettlebell", false),
    Exercise("Lat pulldown", "Back · Biceps", "Cable machine", false),
    Exercise("Shoulder press", "Shoulders · Triceps", "Dumbbells", false),
    Exercise("Bulgarian split squat", "Quads · Glutes", "Dumbbells · Bench", false),
    Exercise("Walking lunge", "Quads · Glutes", "Dumbbells", false),
    Exercise("Leg press", "Quads · Glutes", "Leg press", false),
    Exercise("Calf raise", "Calves", "Dumbbells", false),
  ];

  // Compte les exercices sélectionnés
  int countSelected() {
    int n = 0;
    for (var e in exercises) {
      if (e.selected) {
        n++;
      }
    }
    return n;
  }

  // Même principe que increment() du cours §5.4
  void toggle(Exercise exercise) {
    setState(() {
      exercise.selected = !exercise.selected;
    });
  }

  // Les choix du menu, lus dans la liste des exercices
  List<String> choices(bool muscles) {
    List<String> options = ["All"];
    for (var e in exercises) {
      String text = muscles ? e.muscles : e.equipment;
      List<String> parts = text.split(" · ");
      for (var part in parts) {
        if (part == "Dumbbell") {
          part = "Dumbbells";
        }
        if (!options.contains(part)) {
          options.add(part);
        }
      }
    }
    return options;
  }

  bool matchesSearch(Exercise e) {
    String query = searchController.text.trim().toLowerCase();
    if (query == "") {
      return true;
    }
    String text = "${e.name} ${e.muscles} ${e.equipment}".toLowerCase();
    return text.contains(query);
  }

  bool matchesChoice(String value, String filter) {
    if (filter == "All") {
      return true;
    }
    if (filter == "Dumbbells") {
      return value.toLowerCase().contains("dumbbell");
    }
    return value.toLowerCase().contains(filter.toLowerCase());
  }

  // Exercices qui passent la recherche et les deux filtres
  List<Exercise> visibleExercises() {
    List<Exercise> result = [];
    for (var e in exercises) {
      if (!matchesSearch(e)) {
        continue;
      }
      if (!matchesChoice(e.muscles, muscleFilter)) {
        continue;
      }
      if (!matchesChoice(e.equipment, equipmentFilter)) {
        continue;
      }
      result.add(e);
    }
    return result;
  }

  Widget buildFilter(
    String title,
    String selected,
    List<String> options,
    void Function(String) onSelected,
  ) {
    String label = selected == "All" ? title : selected;

    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          onSelected(value);
        });
      },
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList();
      },
      child: FilterButton(label: label, active: selected != "All"),
    );
  }

  // Une ligne de la liste
  Widget buildItem(Exercise e) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Photo de l'exercice
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageForExercise(e.name),
              width: 110,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          

          // Textes : prennent tout l'espace restant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(e.muscles),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e.equipment)),
                  ],
                ),
              ],
            ),
          ),

          // Bouton + (devient ✓ quand sélectionné)
          IconButton(
            onPressed: () {
              toggle(e);
            },
            icon: Icon(
              e.selected ? Icons.check_circle : Icons.add_circle_outline,
              color: plum,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Exercise> shown = visibleExercises();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Titre + coeur
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Exercises",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: plum,
                    ),
                  ),
                  Icon(Icons.favorite_border, color: plum, size: 30),
                ],
              ),
            ),

            // 2. Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Search exercises",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text == ""
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFF7ECF1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 3. Filtres
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  buildFilter("Muscle", muscleFilter, choices(true), (value) {
                    muscleFilter = value;
                  }),
                  const SizedBox(width: 12),
                  buildFilter(
                    "Equipment",
                    equipmentFilter,
                    choices(false),
                    (value) {
                      equipmentFilter = value;
                    },
                  ),
                ],
              ),
            ),

            // 4. Liste (Expanded obligatoire dans une Column)
            Expanded(
              child: shown.isEmpty
                  ? const Center(child: Text("No exercises found"))
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, index) {
                        return buildItem(shown[index]);
                      },
                    ),
            ),

            // 5. Barre "2 selected" + bouton
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF7ECF1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${countSelected()} selected",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ajouté à la routine")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plum,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Add to routine"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. Barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: plum,
        onTap: (index) {
          if (index == 0) {
            openAppPage(context, '/home');
          }
          if (index == 1) {
            openAppPage(context, '/routines');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: "Routines"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Exercises"),
        ],
      ),
    );
  }
}