import 'package:flutter_test/flutter_test.dart';
import 'package:read_tone_app/data/models/aladin_book_model.dart';
import 'package:read_tone_app/data/models/kakao_book_model.dart';

void main() {
  test('AladinItem.fromJson은 다양한 위치의 pageCount/description을 파싱한다', () {
    final json = {
      'title': '책',
      'author': '저자',
      'publisher': '출판사',
      'isbn13': '123',
      'cover': 'u',
      'itemPage': '총 320쪽',
      'subInfo': {'itemPage': '300', 'fullDescription': '설명'},
    };

    final item = AladinItem.fromJson(json);
    expect(item.pageCount, 300); // subInfo 우선
    expect(item.description, '설명');
  });

  test('KakaoBookModel.fromJson → toBookEntity는 기본 필드를 채운다', () {
    final json = {
      'title': '책',
      'contents': '요약',
      'url': 'u',
      'isbn': 'i',
      'datetime': '',
      'authors': ['a'],
      'publisher': 'p',
      'translators': [],
      'price': 1000,
      'sale_price': 900,
      'thumbnail': 't',
      'status': '정상',
    };
    final model = KakaoBookModel.fromJson(json);
    final book = model.toBookEntity();
    expect(book.id, isNotEmpty);
    expect(book.title, '책');
    expect(book.author, 'a');
    expect(book.totalPages, greaterThan(0));
  });
}
