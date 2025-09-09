class AppConstants {
  static const String appName = '독서 기록';
  static const String appVersion = '1.0.0';

  // 라우트 상수
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String libraryRoute = '/library';
  static const String libraryAllRoute = '/library/all';
  static const String readingModeRoute = '/reading-mode';
  static const String readingSessionRoute = '/reading-session';
  static const String bookDetailRoute = '/book';
  static const String addBookRoute = '/add-book';
  static const String bookDetailInputRoute = '/book-detail-input';
  static const String statisticsRoute = '/statistics';
  static const String statisticsShareRoute = '/share';
  static const String myPageRoute = '/my-page';
  static const String privacyPolicyRoute = '/privacy-policy';
  static const String termsOfServiceRoute = '/terms-of-service';
  static const String themeTestRoute = '/theme-test';
  static const String searchRoute = '/search';

  // 공유 상수
  static const String shareTitle = '나의 독서 통계';
  static const String shareMessage =
      '지금까지 읽은 책: {totalBooks}권\n총 페이지 수: {totalPages}페이지';

  // 에러 메시지
  static const String errorLoadingBooks = '책 목록을 불러오는데 실패했습니다.';
  static const String errorSavingBook = '책 정보를 저장하는데 실패했습니다.';
  static const String errorDeletingBook = '책을 삭제하는데 실패했습니다.';
  static const String errorBookNotFound = '책을 찾을 수 없습니다.';
}
