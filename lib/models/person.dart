class Person {
  final String idCustomerService;
  final String nim;
  final String titleIssues;
  final String descriptionIssues;
  final int rating;
  final String imageUrl;
  final int idDivisionTarget;
  final int idPriority;
  final String divisionDepartmentName;
  final String priorityName;

  Person({
    required this.idCustomerService,
    required this.nim,
    required this.titleIssues,
    required this.descriptionIssues,
    required this.rating,
    required this.imageUrl,
    required this.idDivisionTarget,
    required this.idPriority,
    required this.divisionDepartmentName,
    required this.priorityName,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    idCustomerService: json["id_customer_service"]?.toString() ?? '',
    nim: json["nim"]?.toString() ?? '',
    titleIssues: json["title_issues"]?.toString() ?? '',
    descriptionIssues: json["description_issues"]?.toString() ?? '',
    rating: json["rating"] as int? ?? 0,
    imageUrl: json["image_url"]?.toString() ?? '',
    idDivisionTarget: json["id_division_target"] as int? ?? 0,
    idPriority: json["id_priority"] as int? ?? 0,
    divisionDepartmentName: json["division_department_name"]?.toString() ?? '',
    priorityName: json["priority_name"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id_customer_service": idCustomerService,
    "nim": nim,
    "title_issues": titleIssues,
    "description_issues": descriptionIssues,
    "rating": rating,
    "image_url": imageUrl,
    "id_division_target": idDivisionTarget,
    "id_priority": idPriority,
    "division_department_name": divisionDepartmentName,
    "priority_name": priorityName,
  };
}