import 'package:get/get.dart';

enum ReportType {
  finance,
  employee,
  stock,
  crop
}

enum ReportFormat {
  pdf,
  excel
}

enum ChartType {
  bar,
  line,
  pie,
  scatter
}

class ReportModel {
  final String id;
  final String title;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> filters;
  final ChartType chartType;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? exportedAt;
  final ReportFormat? exportFormat;

  ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.filters,
    required this.chartType,
    required this.data,
    required this.createdAt,
    this.exportedAt,
    this.exportFormat,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${json['type']}',
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      filters: json['filters'] ?? {},
      chartType: ChartType.values.firstWhere(
        (e) => e.toString() == 'ChartType.${json['chart_type']}',
      ),
      data: json['data'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      exportedAt: json['exported_at'] != null 
        ? DateTime.parse(json['exported_at'])
        : null,
      exportFormat: json['export_format'] != null
        ? ReportFormat.values.firstWhere(
            (e) => e.toString() == 'ReportFormat.${json['export_format']}',
          )
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'filters': filters,
      'chart_type': chartType.toString().split('.').last,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'exported_at': exportedAt?.toIso8601String(),
      'export_format': exportFormat?.toString().split('.').last,
    };
  }
} 