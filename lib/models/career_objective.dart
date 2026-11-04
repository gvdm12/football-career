enum CareerObjectiveMetric { goals, assists, appearances }

class CareerObjective {
  final String id;
  final int season;
  final CareerObjectiveMetric metric;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int reward;
  final bool completed;

  const CareerObjective({
    required this.id,
    required this.season,
    required this.metric,
    required this.title,
    required this.description,
    required this.target,
    this.progress = 0,
    required this.reward,
    this.completed = false,
  });

  double get progressRatio => target <= 0 ? 0 : (progress / target).clamp(0.0, 1.0).toDouble();

  CareerObjective updateProgress(int value) {
    final nextProgress = value.clamp(0, target).toInt();
    return CareerObjective(
      id: id,
      season: season,
      metric: metric,
      title: title,
      description: description,
      target: target,
      progress: nextProgress,
      reward: reward,
      completed: completed || nextProgress >= target,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'season': season,
    'metric': metric.name,
    'title': title,
    'description': description,
    'target': target,
    'progress': progress,
    'reward': reward,
    'completed': completed,
  };

  factory CareerObjective.fromJson(Map<String, dynamic> json) {
    final metricName = json['metric'] as String?;
    return CareerObjective(
      id: json['id'] as String? ?? '',
      season: (json['season'] as num?)?.toInt() ?? 1,
      metric: CareerObjectiveMetric.values.firstWhere(
        (value) => value.name == metricName,
        orElse: () => CareerObjectiveMetric.appearances,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      target: ((json['target'] as num?)?.toInt() ?? 1).clamp(1, 999).toInt(),
      progress: ((json['progress'] as num?)?.toInt() ?? 0).clamp(0, 999).toInt(),
      reward: ((json['reward'] as num?)?.toInt() ?? 0).clamp(0, 10000000).toInt(),
      completed: json['completed'] as bool? ?? false,
    );
  }
}
