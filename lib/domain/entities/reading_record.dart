class ReadingRecord {
  final String bookId;
  final DateTime startTime;
  final DateTime endTime;
  final int startPage;
  final int endPage;

  const ReadingRecord({
    required this.bookId,
    required this.startTime,
    required this.endTime,
    required this.startPage,
    required this.endPage,
  });

  Duration get duration => endTime.difference(startTime);
  int get pagesRead => endPage - startPage;
}
