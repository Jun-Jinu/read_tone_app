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
