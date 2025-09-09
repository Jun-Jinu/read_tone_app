import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reading_record.dart';

final readingRecordsProvider =
    StateNotifierProvider<ReadingRecordsNotifier, List<ReadingRecord>>((ref) {
  return ReadingRecordsNotifier();
});

class ReadingRecordsNotifier extends StateNotifier<List<ReadingRecord>> {
  ReadingRecordsNotifier() : super([]);

  void addRecord(ReadingRecord record) {
    state = [...state, record];
  }

  void removeRecord(ReadingRecord record) {
    state = state.where((r) => r != record).toList();
  }

  void updateRecord(ReadingRecord oldRecord, ReadingRecord newRecord) {
    state = state
        .map((record) => record == oldRecord ? newRecord : record)
        .toList();
  }

  List<ReadingRecord> getRecordsByBookId(String bookId) {
    return state.where((record) => record.bookId == bookId).toList();
  }

  List<ReadingRecord> getRecordsByDate(DateTime date) {
    return state.where((record) {
      final recordDate = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return recordDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  Duration getTotalReadingTime() {
    return state.fold(
      Duration.zero,
      (total, record) => total + record.duration,
    );
  }

  Duration getReadingTimeByBookId(String bookId) {
    return getRecordsByBookId(bookId).fold(
      Duration.zero,
      (total, record) => total + record.duration,
    );
  }

  Duration getReadingTimeByDate(DateTime date) {
    return getRecordsByDate(date).fold(
      Duration.zero,
      (total, record) => total + record.duration,
    );
  }

  int getTotalPagesRead() {
    return state.fold(
      0,
      (total, record) => total + record.pagesRead,
    );
  }

  int getPagesReadByBookId(String bookId) {
    return getRecordsByBookId(bookId).fold(
      0,
      (total, record) => total + record.pagesRead,
    );
  }

  int getPagesReadByDate(DateTime date) {
    return getRecordsByDate(date).fold(
      0,
      (total, record) => total + record.pagesRead,
    );
  }
}
