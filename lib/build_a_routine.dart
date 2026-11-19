import 'package:flutter/material.dart';

import 'exercise_images.dart';

// Une classe simple (cours Chapitre 1, §4.9)
class Exercise {
  String name;
  String sets;
  String reps;
  String rest;
  String weight;
  bool expanded; // true = la zone de détails est ouverte

  Exercise(this.name, this.sets, this.reps, this.rest, this.weight, this.expanded);
}

// Une routine complete, avec la liste de ses exercices
class RoutineData {
  String title;
  String level;
  String equipment;
  String description;
  List<Exercise> exercises;

  RoutineData(
    this.title,
    this.level,
    this.equipment,
    this.description,
    this.exercises,
  );
}

class BuildRoutinePage extends StatefulWidget {
  const BuildRoutinePage({super.key});

  @override
  State<BuildRoutinePage> createState() => _BuildRoutinePageState();
}

class _BuildRoutinePageState extends State<BuildRoutinePage> {
  // Couleurs de la maquette
  final Color plum = const Color(0xFF7B2150);
  final Color rose = const Color(0xFFB34A74);
  final Color lightPink = const Color(0xFFF7ECF1);
  final Color mediumPink = const Color(0xFFF3DCE6);

  // Champ "Routine name" (cours §2.6)
  final TextEditingController nameController =
      TextEditingController(text: "My lower body day");

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // Choix proposés dans les listes déroulantes
  List<String> setsOptions = ["1", "2", "3", "4", "5"];
  List<String> repsOptions = ["6-8", "8-10", "10-12", "12-15"];
  List<String> restOptions = ["30s", "60s", "90s", "120s"];

  // Les exercices de la routine
  List<Exercise> exercises = [
    Exercise("Hip thrust", "3", "10-12", "90s", "20", true),
    Exercise("Romanian deadlift", "3", "8-10", "90s", "", false),
    Exercise("Goblet squat", "3", "10-12", "90s", "", false),
    Exercise("Bulgarian split squat", "3", "8-10", "90s", "", false),
  ];

  // Exercices qu'on pourra ajouter avec le bouton "Add exercises"
  List<Exercise> extras = [
    Exercise("Calf raise", "3", "12-15", "60s", "", false),
    Exercise("Leg press", "3", "10-12", "90s", "", false),
    Exercise("Walking lunge", "3", "8-10", "90s", "", false),
  ];

  // Afficher un message en bas de l'écran (cours §3.5)
  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // Ouvrir / fermer les détails d'un exercice
  void toggle(int index) {
    setState(() {
      exercises[index].expanded = !exercises[index].expanded;
    });
  }

  // Ajouter un exercice à la liste
  void addExercise() {
    if (extras.isEmpty) {
      showMessage("Plus d'exercices disponibles");
      return;
    }
    setState(() {
      exercises.add(extras.removeAt(0));
    });
  }

  // Liste déroulante réutilisable (Sets, Rep range, Rest)
  Widget buildDropdown(
    List<String> options,
    String value,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(), // cache le trait sous la liste
        onChanged: onChanged,
        items: options
            .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
            .toList(),
      ),
    );
  }

  // Zone de détails (Sets, Rep range, Weight, Rest)
  Widget buildDetails(Exercise e) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: lightPink,
        borderRadius: BorderRadius.circular(12),
      ),
      // Wrap = une Row qui passe à la ligne s'il n'y a plus de place
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          // Sets
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sets", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              buildDropdown(setsOptions, e.sets, (value) {
                setState(() {
                  e.sets = value!;
                });
              }),
            ],
          ),

          // Rep range
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rep range", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              buildDropdown(repsOptions, e.reps, (value) {
                setState(() {
                  e.reps = value!;
                });
              }),
            ],
          ),

          // Weight (optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Weight (optional)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      initialValue: e.weight,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        e.weight = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text("kg per dumbbell", style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),

          // Rest
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rest", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              buildDropdown(restOptions, e.rest, (value) {
                setState(() {
                  e.rest = value!;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Une ligne de la liste (+ ses détails si elle est ouverte)
  Widget buildItem(int index) {
    Exercise e = exercises[index];

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Poignée de déplacement (6 points)
              const Icon(Icons.drag_indicator, color: Colors.grey),
              const SizedBox(width: 8),

              // Photo de l'exercice
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageForExercise(e.name),
                  width: 90,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Nom + résumé : prennent tout l'espace restant
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
                    Text("${e.sets} sets × ${e.reps} reps · Rest ${e.rest}"),
                  ],
                ),
              ),

              // Flèche haut / bas
              IconButton(
                onPressed: () {
                  toggle(index);
                },
                icon: Icon(
                  e.expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
        ),

        // Les détails ne s'affichent que si expanded == true
        if (e.expanded) buildDetails(e),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barre du haut : retour, titre, Cancel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: plum),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Build a routine",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: plum,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16, color: plum),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Contenu défilant
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),

                  // Libellé + champ de saisie
                  const Text(
                    "Routine name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ligne "4 exercises · About 35 min"
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "${exercises.length} exercises · About ${exercises.length * 9} min",
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // La liste des exercices (une boucle for dans la liste)
                  for (int i = 0; i < exercises.length; i++) buildItem(i),

                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Bouton "Add exercises"
                  GestureDetector(
                    onTap: () {
                      addExercise();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: mediumPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: plum),
                          const SizedBox(width: 8),
                          Text(
                            "Add exercises",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: plum,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 3. Bouton "Save routine" (fixe en bas)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String name = nameController.text.trim();
                    if (name.isEmpty) {
                      name = "My routine";
                    }

                    String equipment = "";
                    for (var e in exercises) {
                      if (equipment.isEmpty) {
                        equipment = e.name;
                      } else {
                        equipment = "$equipment · ${e.name}";
                      }
                    }
                    if (equipment.isEmpty) {
                      equipment = "No exercises";
                    }

                    List<Exercise> copy = [];
                    for (var e in exercises) {
                      copy.add(
                        Exercise(e.name, e.sets, e.reps, e.rest, e.weight, false),
                      );
                    }

                    Navigator.pop(
                      context,
                      RoutineData(
                        name,
                        "${exercises.length} exercises · About ${exercises.length * 9} min",
                        equipment,
                        "Saved routine",
                        copy,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Save routine",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}