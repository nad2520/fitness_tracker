// Photo de chaque exercice (cours : Map, chapitre 1)
const Map<String, String> exerciseImages = {
  "Hip thrust": "assets/images/hip_thrust.jpg",
  "Romanian deadlift": "assets/images/romanian_deadlift.jpg",
  "Goblet squat": "assets/images/goblet_squat.jpg",
  "Lat pulldown": "assets/images/lat_pulldown.jpg",
  "Shoulder press": "assets/images/shoulder_press.jpg",
  "Bulgarian split squat": "assets/images/bulgarian_split_squat.jpg",
  "Calf raise": "assets/images/calf_raise.jpg",
  "Leg press": "assets/images/leg_press.jpg",
  "Walking lunge": "assets/images/walking_lunge.jpg",
};

String imageForExercise(String name) {
  if (exerciseImages.containsKey(name)) {
    return exerciseImages[name]!;
  }
  return "assets/images/hip_thrust.jpg";
}
