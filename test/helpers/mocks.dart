import 'package:mocktail/mocktail.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';
import 'package:read_tone_app/domain/repositories/search_history_repository.dart';
import 'package:read_tone_app/domain/repositories/settings_repository.dart';
import 'package:read_tone_app/domain/repositories/user_repository.dart';
import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/data/datasources/book_remote_data_source.dart';
import 'package:read_tone_app/data/datasources/book_local_data_source.dart';
import 'package:read_tone_app/data/datasources/kakao_book_api_service.dart';
import 'package:read_tone_app/data/datasources/aladin_book_api_service.dart';
import 'package:read_tone_app/data/datasources/user_local_data_source.dart';
import 'package:read_tone_app/data/services/firebase_auth_service.dart';
import 'package:read_tone_app/application/usecases/book_usecases.dart';

class MockBookRepository extends Mock implements BookRepository {}

class MockSearchHistoryRepository extends Mock
    implements SearchHistoryRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeBook extends Fake implements Book {}

class MockBookRemoteDataSource extends Mock implements BookRemoteDataSource {}

class MockBookLocalDataSource extends Mock implements BookLocalDataSource {}

class MockKakaoBookApiService extends Mock implements KakaoBookApiService {}

class MockAladinBookApiService extends Mock implements AladinBookApiService {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockBookUseCases extends Mock implements BookUseCases {}
