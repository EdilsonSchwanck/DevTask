enum TaskPriority {
  low(0),
  medium(1),
  high(2);

  const TaskPriority(this.weight);

  final int weight;

  static TaskPriority fromName(String? name) => values.firstWhere(
    (p) => p.name == name,
    orElse: () => TaskPriority.medium,
  );
}
