import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';
import 'package:read_tone_app/domain/repositories/search_history_repository.dart';
import 'package:read_tone_app/domain/repositories/settings_repository.dart';
import 'package:read_tone_app/domain/repositories/user_repository.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/data/datasources/book_remote_data_source.dart';
import 'package:read_tone_app/data/datasources/book_local_data_source.dart';

class MockBookRepository extends Mock implements BookRepository {}

class MockSearchHistoryRepository extends Mock
    implements SearchHistoryRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeBook extends Fake implements Book {}

class MockBookRemoteDataSource extends Mock implements BookRemoteDataSource {}

class MockBookLocalDataSource extends Mock implements BookLocalDataSource {}
