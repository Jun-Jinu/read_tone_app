import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/aladin_book_model.dart';

class AladinBookApiService {
  late final Dio _dio;
  static const String _baseUrl =
      'https://www.aladin.co.kr/ttb/api/ItemSearch.aspx';
  static const String _itemLookupUrl =
      'https://www.aladin.co.kr/ttb/api/ItemLookUp.aspx';

  AladinBookApiService() {
    _dio = Dio();
  }

  Future<AladinBookSearchResponse> searchBooks({
    required String query,
    String sort = 'Accuracy',
    int page = 1,
    int size = 10,
  }) async {
    final ttbKey = dotenv.env['ALADIN_TTB_KEY'];
    if (ttbKey == null || ttbKey.isEmpty) {
      throw Exception('ALADIN_TTB_KEY 환경변수가 설정되지 않았습니다.');
    }

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'TTBKey': ttbKey,
          'Query': query,
          'QueryType': 'Keyword',
          'MaxResults': size,
          'Start': page,
          'SearchTarget': 'Book',
          'Sort': sort,
          'Output': 'JS',
          'Version': '20131101',
        },
      );

      return AladinBookSearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('알라딘 API 오류: ${e.message}');
    } catch (e) {
      throw Exception('알라딘 검색 실패: $e');
    }
  }

  /// ISBN13으로 ItemLookUp 호출하여 상세 정보(페이지/설명 등) 조회
  Future<AladinItemDetail?> lookupByIsbn13(String isbn13) async {
    final ttbKey = dotenv.env['ALADIN_TTB_KEY'];
    if (ttbKey == null || ttbKey.isEmpty) {
      throw Exception('ALADIN_TTB_KEY 환경변수가 설정되지 않았습니다.');
    }

    try {
      final response = await _dio.get(
        _itemLookupUrl,
        queryParameters: {
          'TTBKey': ttbKey,
          'itemIdType': 'ISBN13',
          'ItemId': isbn13,
          'Output': 'JS',
          'Version': '20131101',
          'OptResult': 'packing,authors,fulldescription',
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['item'];
        if (items is List && items.isNotEmpty) {
          return AladinItemDetail.fromJson(items.first as Map<String, dynamic>);
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception('알라딘 ItemLookUp 오류: ${e.message}');
    } catch (e) {
      throw Exception('알라딘 ItemLookUp 실패: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
