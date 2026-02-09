// To parse this JSON data, do
//
//     final getMvCountModalClass = getMvCountModalClassFromJson(jsonString);

import 'dart:convert';

GetMvCountModalClass getMvCountModalClassFromJson(String str) =>
    GetMvCountModalClass.fromJson(json.decode(str));

String getMvCountModalClassToJson(GetMvCountModalClass data) =>
    json.encode(data.toJson());

class GetMvCountModalClass {
  Message message;

  GetMvCountModalClass({required this.message});

  factory GetMvCountModalClass.fromJson(Map<String, dynamic> json) =>
      GetMvCountModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  int totalCount;
  Breakdown breakdown;

  Message({
    required this.success,
    required this.message,
    required this.totalCount,
    required this.breakdown,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    totalCount: json["total_count"] ?? 0,
    breakdown: Breakdown.fromJson(json["breakdown"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "total_count": totalCount,
    "breakdown": breakdown.toJson(),
  };
}

class Breakdown {
  ByCompletionStatus byCompletionStatus;
  ByCustomVisitStatus byCustomVisitStatus;

  Breakdown({
    required this.byCompletionStatus,
    required this.byCustomVisitStatus,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) => Breakdown(
    byCompletionStatus: ByCompletionStatus.fromJson(
      json["by_completion_status"] ?? {},
    ),
    byCustomVisitStatus: ByCustomVisitStatus.fromJson(
      json["by_custom_visit_status"] ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "by_completion_status": byCompletionStatus.toJson(),
    "by_custom_visit_status": byCustomVisitStatus.toJson(),
  };
}

class ByCompletionStatus {
  int fullyCompleted;
  int partiallyCompleted;

  ByCompletionStatus({
    required this.fullyCompleted,
    required this.partiallyCompleted,
  });

  factory ByCompletionStatus.fromJson(Map<String, dynamic> json) =>
      ByCompletionStatus(
        fullyCompleted: json["Fully Completed"] ?? 0,
        partiallyCompleted: json["Partially Completed"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "Fully Completed": fullyCompleted,
    "Partially Completed": partiallyCompleted,
  };
}

class ByCustomVisitStatus {
  int assigned;
  int completed;
  int inProgress;
  int open;

  ByCustomVisitStatus({
    required this.assigned,
    required this.completed,
    required this.inProgress,
    required this.open,
  });

  factory ByCustomVisitStatus.fromJson(Map<String, dynamic> json) =>
      ByCustomVisitStatus(
        assigned: json["Assigned"] ?? 0,
        completed: json["Completed"] ?? 0,
        inProgress: json["In Progress"] ?? 0,
        open: json["Open"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "Assigned": assigned,
    "Completed": completed,
    "In Progress": inProgress,
    "Open": open,
  };
}
