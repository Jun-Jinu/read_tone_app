import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_tone_app/presentation/providers/auth_provider.dart';
import 'package:read_tone_app/domain/entities/user.dart' as domain;
import '../../helpers/mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late StreamController<domain.User?> userStreamController;

  setUp(() {
    mockUserRepository = MockUserRepository();
    userStreamController = StreamController<domain.User?>.broadcast();

    when(
      () => mockUserRepository.currentUserStream,
    ).thenAnswer((_) => userStreamController.stream);

    // 기타 메서드는 기본 no-op
    when(() => mockUserRepository.signOut()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await userStreamController.close();
  });

  test('AuthNotifier는 사용자 스트림에 따라 상태를 갱신한다', () async {
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(mockUserRepository)],
    );

    addTearDown(container.dispose);

    // 초기 상태
    final initial = container.read(authProvider);
    expect(initial.isLoggedIn, false);

    // 사용자 로그인 이벤트 발행
    final user = domain.User(
      uid: 'u1',
      email: 'test@test.com',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    userStreamController.add(user);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final loggedIn = container.read(authProvider);
    expect(loggedIn.isLoggedIn, true);
    expect(loggedIn.user?.email, 'test@test.com');

    // 로그아웃 이벤트
    userStreamController.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final loggedOut = container.read(authProvider);
    expect(loggedOut.isLoggedIn, false);
  });
}
