## 프로젝트 개요

- **프로젝트명**: 리드톤 (readtone)
- **목표**: 독서 기록과 정리를 통한 효과적인 독서 관리 앱
- **플랫폼**: flutter, firebase
- **주요 기능**:
  - 책 등록, 기록, 관리
  - 독서 타이머 및 기록
  - 통계 확인

## 핵심 사용자 기능

1. **회원가입 / 로그인**
2. **홈 화면**
   - 오늘 목표 확인
   - 읽고 있는 책 목록
3. **책 등록**
   - 검색 또는 수동 입력
4. **책 상세 + 독서 타이머**
   - 타이머 시작/종료
   - 중간 책갈피 작성 가능
5. **기록/감상문 관리**
6. **마이페이지**
   - 독서 통계 확인
   - 목표 설정

## 아키텍처 요약 (Clean Architecture)

- **레이어 구성**

  - **presentation**: UI, 상태관리(`providers`), 라우팅, `widgets/`, `pages/`, `layouts/`
  - **application**: 유즈케이스 정의·조합, 앱 시나리오 구현, 에러 변환
  - **domain**: 비즈니스 규칙, `entities`, `repositories` 인터페이스
  - **data**: 외부 의존 접근, `datasources`/`services`, `models` 매핑, `repositories` 구현체

- **의존성 규칙**

  - 바깥 → 안쪽 단방향: presentation → application → domain
  - data ↦ domain만 의존. domain은 data를 모름(인터페이스로만 연결)

- **데이터 흐름**

  1. 화면(presentation)에서 유즈케이스(application) 실행
  2. 유즈케이스가 리포지토리(domain 인터페이스) 호출
  3. 리포지토리 구현(data)이 데이터소스/서비스 호출
  4. 응답을 `models` ↔ `entities` 매핑 후 상위로 반환

- **디렉터리 매핑**

  - `lib/presentation`: `pages/`, `widgets/`, `providers/`, `layouts/`, `router/`, `theme/`
  - `lib/application`: `usecases/`
  - `lib/domain`: `entities/`, `repositories/`
  - `lib/data`: `repositories/`, `datasources/`, `services/`, `models/`, `providers/`
  - `lib/core`: 공통 상수/에러/네트워크/유틸
  - 루트: `firebase_options.dart`, `main.dart` (부트스트랩)

- **테스트 가이드**

  - `test/application/usecases`: 유즈케이스 단위 테스트
  - `test/data/repositories`: 리포지토리 구현 테스트
  - `test/presentation`: 위젯/프로바이더 테스트
  - 엔티티/매퍼는 순수 함수로 유지하여 테스트 용이성 확보

- **확장 순서**
  - 새 기능은 다음 순서로 추가: domain(엔티티/인터페이스) → application(유즈케이스) → data(구현/모델/데이터소스) → presentation(UI/상태)

## 디렉터리 트리

```
📦lib
 ┣ 📂application
 ┃ ┗ 📂usecases
 ┃ ┃ ┣ 📜book_usecases.dart
 ┃ ┃ ┣ 📜get_recent_books_usecase.dart
 ┃ ┃ ┣ 📜reading_session_usecase.dart
 ┃ ┃ ┣ 📜reading_stats_usecase.dart
 ┃ ┃ ┣ 📜search_history_usecases.dart
 ┃ ┃ ┗ 📜settings_usecases.dart
 ┣ 📂core
 ┃ ┣ 📂constants
 ┃ ┃ ┣ 📜app_constants.dart
 ┃ ┃ ┗ 📜reading_level_constants.dart
 ┃ ┣ 📂error
 ┃ ┃ ┗ 📜failures.dart
 ┃ ┣ 📂network
 ┃ ┃ ┗ 📜dio_client.dart
 ┃ ┣ 📂router
 ┃ ┃ ┗ 📜app_router.dart
 ┃ ┣ 📂theme
 ┃ ┃ ┣ 📜app_colors.dart
 ┃ ┃ ┣ 📜app_text_styles.dart
 ┃ ┃ ┗ 📜app_theme.dart
 ┃ ┣ 📂utils
 ┃ ┃ ┗ 📜database_service.dart
 ┃ ┗ 📜.DS_Store
 ┣ 📂data
 ┃ ┣ 📂datasources
 ┃ ┃ ┣ 📜aladin_book_api_service.dart
 ┃ ┃ ┣ 📜book_local_data_source.dart
 ┃ ┃ ┣ 📜book_local_data_source_impl.dart
 ┃ ┃ ┣ 📜book_remote_data_source.dart
 ┃ ┃ ┣ 📜book_remote_data_source_impl.dart
 ┃ ┃ ┣ 📜kakao_book_api_service.dart
 ┃ ┃ ┣ 📜user_local_data_source.dart
 ┃ ┃ ┗ 📜user_local_data_source_impl.dart
 ┃ ┣ 📂models
 ┃ ┃ ┣ 📜aladin_book_model.dart
 ┃ ┃ ┣ 📜book_model.dart
 ┃ ┃ ┣ 📜book_model.freezed.dart
 ┃ ┃ ┣ 📜book_model.g.dart
 ┃ ┃ ┣ 📜kakao_book_model.dart
 ┃ ┃ ┣ 📜user_model.dart
 ┃ ┃ ┣ 📜user_model.freezed.dart
 ┃ ┃ ┗ 📜user_model.g.dart
 ┃ ┣ 📂providers
 ┃ ┃ ┣ 📜book_provider.dart
 ┃ ┃ ┣ 📜database_providers.dart
 ┃ ┃ ┗ 📜repository_providers.dart
 ┃ ┣ 📂repositories
 ┃ ┃ ┣ 📜book_repository_impl.dart
 ┃ ┃ ┣ 📜book_search_repository_impl.dart
 ┃ ┃ ┗ 📜user_repository_impl.dart
 ┃ ┣ 📂services
 ┃ ┃ ┣ 📜firebase_auth_service.dart
 ┃ ┃ ┣ 📜firebase_firestore_service.dart
 ┃ ┃ ┗ 📜local_image_service.dart
 ┃ ┣ 📜.DS_Store
 ┃ ┗ 📜dummy_books.dart
 ┣ 📂domain
 ┃ ┣ 📂entities
 ┃ ┃ ┣ 📜book.dart
 ┃ ┃ ┣ 📜reading_note.dart
 ┃ ┃ ┣ 📜reading_record.dart
 ┃ ┃ ┣ 📜search_history.dart
 ┃ ┃ ┣ 📜settings.dart
 ┃ ┃ ┣ 📜user.dart
 ┃ ┃ ┗ 📜user.freezed.dart
 ┃ ┣ 📂repositories
 ┃ ┃ ┣ 📜auth_repository.dart
 ┃ ┃ ┣ 📜book_repository.dart
 ┃ ┃ ┣ 📜book_search_repository.dart
 ┃ ┃ ┣ 📜search_history_repository.dart
 ┃ ┃ ┣ 📜settings_repository.dart
 ┃ ┃ ┗ 📜user_repository.dart
 ┃ ┗ 📜.DS_Store
 ┣ 📂presentation
 ┃ ┣ 📂layouts
 ┃ ┃ ┣ 📜legal_layout.dart
 ┃ ┃ ┗ 📜main_layout.dart
 ┃ ┣ 📂pages
 ┃ ┃ ┣ 📂auth
 ┃ ┃ ┃ ┣ 📜login_screen.dart
 ┃ ┃ ┃ ┣ 📜signup_screen.dart
 ┃ ┃ ┃ ┗ 📜splash_screen.dart
 ┃ ┃ ┣ 📂book
 ┃ ┃ ┃ ┣ 📂widgets
 ┃ ┃ ┃ ┃ ┣ 📜additional_notes_section.dart
 ┃ ┃ ┃ ┃ ┣ 📜book_info_section.dart
 ┃ ┃ ┃ ┃ ┣ 📜reading_period_section.dart
 ┃ ┃ ┃ ┃ ┗ 📜review_section.dart
 ┃ ┃ ┃ ┣ 📜book_detail_input_screen.dart
 ┃ ┃ ┃ ┣ 📜book_detail_screen.dart
 ┃ ┃ ┃ ┣ 📜reading_note_screen.dart
 ┃ ┃ ┃ ┗ 📜reading_session_screen.dart
 ┃ ┃ ┣ 📂legal
 ┃ ┃ ┃ ┣ 📜privacy_policy_screen.dart
 ┃ ┃ ┃ ┗ 📜terms_of_service_screen.dart
 ┃ ┃ ┣ 📂library
 ┃ ┃ ┃ ┣ 📜library_all_books_screen.dart
 ┃ ┃ ┃ ┗ 📜library_screen.dart
 ┃ ┃ ┣ 📂main
 ┃ ┃ ┃ ┗ 📜home_screen.dart
 ┃ ┃ ┣ 📂my_page
 ┃ ┃ ┃ ┣ 📜login_benefits_screen.dart
 ┃ ┃ ┃ ┣ 📜my_page_screen.dart
 ┃ ┃ ┃ ┣ 📜notification_settings_screen.dart
 ┃ ┃ ┃ ┗ 📜user_profile_edit_screen.dart
 ┃ ┃ ┣ 📂search
 ┃ ┃ ┃ ┗ 📜search_screen.dart
 ┃ ┃ ┣ 📂settings
 ┃ ┃ ┃ ┣ 📜settings_screen.dart
 ┃ ┃ ┃ ┗ 📜theme_test_screen.dart
 ┃ ┃ ┗ 📂statistics
 ┃ ┃ ┃ ┣ 📂widgets
 ┃ ┃ ┃ ┃ ┣ 📜monthly_chart.dart
 ┃ ┃ ┃ ┃ ┣ 📜recent_books_section.dart
 ┃ ┃ ┃ ┃ ┗ 📜statistics_card.dart
 ┃ ┃ ┃ ┣ 📜share_statistics_screen.dart
 ┃ ┃ ┃ ┣ 📜statistics_screen.dart
 ┃ ┃ ┃ ┗ 📜statistics_share_screen.dart
 ┃ ┣ 📂providers
 ┃ ┃ ┣ 📜auth_provider.dart
 ┃ ┃ ┣ 📜book_provider.dart
 ┃ ┃ ┣ 📜book_search_provider.dart
 ┃ ┃ ┣ 📜firebase_providers.dart
 ┃ ┃ ┣ 📜image_provider.dart
 ┃ ┃ ┣ 📜reading_record_provider.dart
 ┃ ┃ ┗ 📜theme_provider.dart
 ┃ ┣ 📂widgets
 ┃ ┃ ┣ 📂common
 ┃ ┃ ┃ ┣ 📜custom_button.dart
 ┃ ┃ ┃ ┣ 📜custom_text_field.dart
 ┃ ┃ ┃ ┣ 📜feature_restriction_card.dart
 ┃ ┃ ┃ ┣ 📜index.dart
 ┃ ┃ ┃ ┣ 📜info_card.dart
 ┃ ┃ ┃ ┣ 📜section_header.dart
 ┃ ┃ ┃ ┗ 📜trendy_dialog.dart
 ┃ ┃ ┣ 📂reading_level
 ┃ ┃ ┃ ┗ 📜reading_level_card.dart
 ┃ ┃ ┣ 📜book_cover_image.dart
 ┃ ┃ ┣ 📜common_text_styles.dart
 ┃ ┃ ┣ 📜custom_dropdown.dart
 ┃ ┃ ┣ 📜custom_text_field.dart
 ┃ ┃ ┣ 📜settings_menu_item.dart
 ┃ ┃ ┗ 📜settings_section.dart
 ┃ ┗ 📜.DS_Store
 ┣ 📜.DS_Store
 ┣ 📜firebase_options.dart
 ┗ 📜main.dart
```

## 디렉터리 구조

| 디렉터리/파일                | 역할                  | 비고                            |
| ---------------------------- | --------------------- | ------------------------------- |
| `lib/presentation/pages`     | 화면(UI) 구성         | 기능별 페이지 모음              |
| `lib/presentation/widgets`   | 공용/재사용 위젯      | 디자인 시스템 요소 포함         |
| `lib/presentation/providers` | 화면 상태관리         | Riverpod 등 상태/액션 노출      |
| `lib/presentation/layouts`   | 레이아웃/스캐폴드     | 공통 레이아웃, 네비게이션 바    |
| `lib/core/router`            | 라우팅 설정           | GoRouter 등 경로 정의           |
| `lib/core/theme`             | 테마/컬러/타이포      | 라이트/다크 테마, 색상 토큰     |
| `lib/application/usecases`   | 유즈케이스            | 앱 시나리오/작업 단위 조합      |
| `lib/domain/entities`        | 도메인 엔티티         | 불변 값객체 중심                |
| `lib/domain/repositories`    | 리포지토리 인터페이스 | data 계층 구현의 계약           |
| `lib/data/datasources`       | 원천 데이터 접근      | REST/Firebase/Local/Cache       |
| `lib/data/services`          | 외부 서비스 래퍼      | Firebase Auth/Firestore 등      |
| `lib/data/models`            | DTO/모델              | `entities` ↔ 모델 변환          |
| `lib/data/repositories`      | 리포지토리 구현체     | 인터페이스 구현, 매핑 포함      |
| `lib/data/providers`         | DI/인스턴스 제공      | 프로바이더/팩토리               |
| `lib/core/constants`         | 상수/키/문자열        | 앱 전역 상수                    |
| `lib/core/error`             | 에러/예외 타입        | 공통 실패/에러 매핑             |
| `lib/core/network`           | 네트워크 공통         | 클라이언트/인터셉터 등          |
| `lib/core/utils`             | 유틸리티              | 공통 헬퍼 함수                  |
| `assets/fonts`               | 폰트 리소스           | Pretendard 등                   |
| `assets/images`              | 이미지 리소스         | 로고/아이콘                     |
| `test`                       | 테스트 코드           | 유즈케이스/리포지토리/UI 테스트 |
| `firebase_options.dart`      | Firebase 설정         | 환경 선택 로더와 함께 사용 권장 |
| `lib/main.dart`              | 앱 엔트리             | 초기화/DI/라우팅 부트스트랩     |
