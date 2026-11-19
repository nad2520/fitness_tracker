import 'package:flutter/material.dart';

import 'build_a_routine.dart';
import 'exercise_images.dart';
import 'fittrack_pages.dart';

// ---------------------------------------------------------
// Couleurs utilisees partout (on les ecrit une seule fois)
// ---------------------------------------------------------
const Color mainColor = Color(0xFF9B3D5E); // bordeaux
const Color lightColor = Color(0xFFF6E7ED); // rose clair

// Routines creees avec "Save routine".
// La liste est en dehors de la page pour rester en memoire
// quand on quitte Routines et qu'on y revient.
List<RoutineData> savedRoutines = [];

// ---------------------------------------------------------
// PAGE PRINCIPALE (StatefulWidget car les onglets changent)
// ---------------------------------------------------------
class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  int selectedTab = 1; // 0 = My routines, 1 = Discover
  int selectedMenu = 1; // 0 = Today, 1 = Routines, 2 = Exercises

  // Les routines proposees, chacune avec ses exercices
  List<RoutineData> routines = [
    RoutineData(
      "Full body foundations",
      "Beginner · 40 min",
      "Dumbbells · Bench",
      "A balanced, beginner-friendly strength routine.",
      [
        Exercise("Goblet squat", "3", "10-12", "90s", "", false),
        Exercise("Romanian deadlift", "3", "8-10", "90s", "", false),
        Exercise("Shoulder press", "3", "8-10", "60s", "", false),
        Exercise("Lat pulldown", "3", "10-12", "60s", "", false),
      ],
    ),
    RoutineData(
      "Lower body focus",
      "Intermediate · 45 min",
      "Dumbbells · Barbell · Bench",
      "Build lower-body strength with targeted, compound lifts.",
      [
        Exercise("Hip thrust", "4", "10-12", "90s", "20", false),
        Exercise("Romanian deadlift", "3", "8-10", "90s", "", false),
        Exercise("Bulgarian split squat", "3", "8-10", "90s", "", false),
        Exercise("Goblet squat", "3", "10-12", "90s", "", false),
        Exercise("Calf raise", "3", "12-15", "60s", "", false),
      ],
    ),
    RoutineData(
      "Upper body strength",
      "Intermediate · 40 min",
      "Dumbbells · Cable machine",
      "Build strength and definition in your upper body.",
      [
        Exercise("Lat pulldown", "4", "8-10", "90s", "", false),
        Exercise("Shoulder press", "4", "6-8", "90s", "", false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Routines",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1) Les deux onglets
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: buildTab("My routines", 0)),
                  Expanded(child: buildTab("Discover", 1)),
                ],
              ),
            ),
          ),

          // 2) La liste (Expanded obligatoire dans une Column)
          Expanded(
            child: selectedTab == 1
                ? ListView.builder(
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      return RoutineCard(routine: routines[index]);
                    },
                  )
                : savedRoutines.isEmpty
                    ? const Center(child: Text("Aucune routine pour le moment"))
                    : ListView.builder(
                        itemCount: savedRoutines.length,
                        itemBuilder: (context, index) {
                          return RoutineCard(routine: savedRoutines[index]);
                        },
                      ),
          ),

          // 3) Le bouton "Create a routine"
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<RoutineData>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuildRoutinePage(),
                    ),
                  );
                  if (result == null || !mounted) {
                    return;
                  }
                  setState(() {
                    savedRoutines.insert(0, result);
                    selectedTab = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightColor,
                  foregroundColor: mainColor,
                  elevation: 0,
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  "Create a routine",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),

      // 4) La barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedMenu,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          if (index == 0) {
            openAppPage(context, '/home');
            return;
          }
          if (index == 2) {
            openAppPage(context, '/exercises');
            return;
          }
          setState(() {
            selectedMenu = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Today",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: "Routines",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Exercises",
          ),
        ],
      ),
    );
  }

  // Un onglet : GestureDetector > Container > Text
  Widget buildTab(String text, int number) {
    bool isSelected = selectedTab == number;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = number;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? mainColor : lightColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET REUTILISABLE : une carte de routine (StatelessWidget)
// ---------------------------------------------------------
class RoutineCard extends StatelessWidget {
  final RoutineData routine;

  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A gauche : l'image (un Container avec une icone)
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fitness_center, size: 40, color: mainColor),
          ),
          const SizedBox(width: 12),

          // A droite : les textes + le bouton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(routine.level),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.fitness_center, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  routine.equipment,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RoutineDetailPage(routine: routine),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mainColor,
                      ),
                      child: const Text("Use routine"),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(routine.description, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Page ouverte par "Use routine" : la routine et tous ses exercices
class RoutineDetailPage extends StatelessWidget {
  final RoutineData routine;

  const RoutineDetailPage({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: mainColor,
        title: Text(
          routine.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(routine.level, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(routine.description, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 20),
          Text(
            "${routine.exercises.length} exercises",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (var e in routine.exercises) buildExercise(e),
        ],
      ),
    );
  }

  Widget buildExercise(Exercise e) {
    String details = "${e.sets} sets × ${e.reps} reps · Rest ${e.rest}";
    if (e.weight != "") {
      details = "$details · ${e.weight} kg";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageForExercise(e.name),
              width: 100,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(details),
              ],
            ),
          ),
        ],
      ),
    );
  }
}