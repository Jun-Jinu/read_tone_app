import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/kakao_book_model.dart';

class KakaoBookApiService {
  late final Dio _dio;
  static const String _baseUrl = 'https://dapi.kakao.com/v3/search/book';

  KakaoBookApiService() {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 카카오 API 키를 헤더에 추가
          final apiKey = dotenv.env['KAKAO_REST_API_KEY'];
          if (apiKey != null && apiKey.isNotEmpty) {
            options.headers['Authorization'] = 'KakaoAK $apiKey';
          } else {
            print('경고: KAKAO_REST_API_KEY가 설정되지 않았습니다.');
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print('카카오 API 에러: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// 도서 검색
  Future<KakaoBookSearchResponse> searchBooks({
    required String query,
    String sort = 'accuracy', // accuracy, recency
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'query': query,
          'sort': sort,
          'page': page,
          'size': size,
        },
      );

      return KakaoBookSearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('도서 검색 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('네트워크 연결 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Exception('잘못된 요청입니다. 검색어를 확인해주세요.');
          case 401:
            return Exception('API 키가 유효하지 않습니다.');
          case 403:
            return Exception('API 사용 권한이 없습니다.');
          case 429:
            return Exception('API 호출 한도를 초과했습니다.');
          case 500:
            return Exception('서버 오류가 발생했습니다.');
          default:
            return Exception('서버 응답 오류: $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception('요청이 취소되었습니다.');
      case DioExceptionType.connectionError:
        return Exception('네트워크 연결을 확인해주세요.');
      default:
        return Exception('네트워크 오류가 발생했습니다: ${e.message}');
    }
  }

  void dispose() {
    _dio.close();
  }
}
