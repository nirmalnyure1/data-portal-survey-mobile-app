import 'dart:io';

import 'package:data_portal_survey/common/http/http.dart';
import 'package:data_portal_survey/features/media/resource/media_repository.dart';
import 'package:data_portal_survey/features/support/model/support_ticket_result.dart';
import 'package:data_portal_survey/features/support/resource/support_api_provider.dart';

class SupportRepository {
  final SupportApiProvider supportApiProvider;
  final MediaRepository mediaRepository;

  SupportRepository({
    required ApiProvider apiProvider,
    required this.mediaRepository,
  }) : supportApiProvider = SupportApiProvider(apiProvider: apiProvider);

  Future<DataResponse<SupportTicketResult>> applyHelp({
    required String issueType,
    required String description,
    File? imageFile,
  }) async {
    String imageUrl = '';
    if (imageFile != null) {
      final upload = await mediaRepository.uploadMedia(file: imageFile);
      if (upload.status != Status.success || upload.data == null) {
        return DataResponse.error(
          upload.message ?? 'Unable to upload image',
          upload.statusCode,
        );
      }
      imageUrl = upload.data!;
    }

    try {
      final res = await supportApiProvider.applyHelp({
        'issueType': issueType,
        'description': description,
        'image': imageUrl,
      });

      final ticket = _parseTicketFromResponse(res);
      return DataResponse.success(SupportTicketResult(ticketDisplay: ticket));
    } on CustomException catch (e) {
      return DataResponse.error(
        e.message?.toString() ?? 'Request failed',
        e.statusCode,
      );
    } catch (e) {
      return DataResponse.error(e.toString());
    }
  }

  String _parseTicketFromResponse(dynamic res) {
    if (res is! Map) {
      return '';
    }
    final root = Map<String, dynamic>.from(res);
    final inner = root['data'];
    if (inner != null) {
      final fromInner = _findTicketInMap(inner);
      if (fromInner.isNotEmpty) {
        return fromInner;
      }
    }
    return _findTicketInMap(root);
  }

  String _findTicketInMap(dynamic node, [int depth = 0]) {
    if (depth > 6 || node == null) {
      return '';
    }
    if (node is String) {
      return node.trim();
    }
    if (node is List) {
      for (final item in node) {
        final nested = _findTicketInMap(item, depth + 1);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
      return '';
    }
    if (node is! Map) {
      return '';
    }
    final map = Map<String, dynamic>.from(node);
    for (final key in [
      'ticketNumber',
      'ticketId',
      'ticket',
      'reference',
      'id',
    ]) {
      final v = map[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    for (final value in map.values) {
      if (value is Map || value is List) {
        final nested = _findTicketInMap(value, depth + 1);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return '';
  }
}
