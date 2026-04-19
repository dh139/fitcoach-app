import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/report_model.dart';

class ReportRepository {
  const ReportRepository();

  Future<ReportModel> getReport(String type, {bool refresh = false}) async {
    final res = await ApiClient.get(
      ApiEndpoints.report(type),
params: refresh ? {'refresh': 'true'} : null,
    );
    if (res.statusCode == 200 && res.data['success'] == true) {
      return ReportModel.fromJson(
        res.data as Map<String, dynamic>,
        cached: res.data['cached'] as bool? ?? false,
      );
    }
    throw Exception(res.data['message'] ?? 'Failed to load report');
  }
}