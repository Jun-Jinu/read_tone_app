import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_tone_app/domain/entities/book.dart';

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>((ref) {
  return BooksNotifier();
});

class BooksNotifier extends StateNotifier<List<Book>> {
  BooksNotifier() : super([]);

  void addBook(Book book) {
    state = [...state, book];
  }

  void updateBook(Book book) {
    state = state.map((b) => b.id == book.id ? book : b).toList();
  }

  void deleteBook(String id) {
    state = state.where((book) => book.id != id).toList();
  }

  void startReading(String id) {
    state = state.map((book) {
      if (book.id == id) {
        return book.copyWith(
          status: BookStatus.reading,
          startedAt: DateTime.now(),
        );
      }
      return book;
    }).toList();
  }

  void completeBook(String id) {
    state = state.map((book) {
      if (book.id == id) {
        return book.copyWith(
          status: BookStatus.completed,
          completedAt: DateTime.now(),
        );
      }
      return book;
    }).toList();
  }

  void updateReadingProgress(String id, int currentPage) {
    state = state.map((book) {
      if (book.id == id) {
        return book.copyWith(currentPage: currentPage);
      }
      return book;
    }).toList();
  }

  void addReadingSession(String id, ReadingSession session) {
    state = state.map((book) {
      if (book.id == id) {
        return book.copyWith(
          readingSessions: [...book.readingSessions, session],
        );
      }
      return book;
    }).toList();
  }
}
