import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_tone_app/data/datasources/book_local_data_source.dart';
import 'package:read_tone_app/data/datasources/book_local_data_source_impl.dart';

// 로컬 데이터소스 프로바이더
final bookLocalDataSourceProvider = Provider<BookLocalDataSource>((ref) {
  return BookLocalDataSourceImpl();
});

// final reviewLocalDataSourceProvider = Provider<ReviewLocalDataSource>((ref) {
//   return ReviewLocalDataSourceImpl();
// });

// final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
//   return AuthLocalDataSourceImpl();
// });
