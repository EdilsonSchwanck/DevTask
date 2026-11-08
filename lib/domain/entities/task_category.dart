enum TaskCategory {
  work,
  study,
  personal,
  health,
  other;

  static TaskCategory fromName(String? name) => values.firstWhere(
    (c) => c.name == name,
    orElse: () => TaskCategory.other,
  );
}
