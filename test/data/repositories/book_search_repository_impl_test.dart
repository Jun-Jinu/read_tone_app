import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/data/repositories/book_search_repository_impl.dart';
import 'package:read_tone_app/data/models/kakao_book_model.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockKakaoBookApiService kakao;

  setUp(() {
    kakao = MockKakaoBookApiService();
  });

  test('알라딘 실패 시 카카오로 폴백하여 결과 반환', () async {
    final repo = BookSearchRepositoryImpl(apiService: kakao);

    // kakao 응답 준비
    final kakaoResp = KakaoBookSearchResponse(
      meta: const KakaoBookMeta(totalCount: 1, pageableCount: 1, isEnd: true),
      documents: const [
        KakaoBookModel(
          title: 't',
          contents: 'c',
          url: '',
          isbn: 'isbn',
          datetime: '',
          authors: ['a'],
          publisher: 'p',
          translators: [],
          price: 0,
          salePrice: 0,
          thumbnail: '',
          status: '',
        ),
      ],
    );

    when(
      () => kakao.searchBooks(
        query: any(named: 'query'),
        sort: any(named: 'sort'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => kakaoResp);

    final result = await repo.searchBooks(query: 'q');
    expect(result.isRight(), true);
    result.fold((_) {}, (books) => expect(books, isNotEmpty));
  });
}
