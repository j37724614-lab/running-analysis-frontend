class RunnerInfo {
  final String name;
  final String id;
  final String lastVideoId;

  RunnerInfo({required this.name, required this.id, required this.lastVideoId});

  factory RunnerInfo.fromJson(Map<String, dynamic> json) {
    return RunnerInfo(name: json['name'], id: json['id'], lastVideoId: json['lastVideoId'] ?? '');
  }
}
