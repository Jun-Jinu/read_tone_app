import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_note.dart';
import '../../application/usecases/book_usecases.dart';
import '../../data/providers/repository_providers.dart';
import '../../data/dummy_books.dart';

// Books Provider
final booksProvider =
    StateNotifierProvider<BooksNotifier, AsyncValue<List<Book>>>((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  return BooksNotifier(bookUseCases);
});

// 개별 UseCase Provider들 (편의성을 위해)
final completeBookProvider = Provider<Future<void> Function(String)>((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  final booksNotifier = ref.read(booksProvider.notifier);

  return (String bookId) async {
    final result = await bookUseCases.completeBook(bookId);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => booksNotifier.refreshBooks(),
    );
  };
});

final startReadingProvider = Provider<Future<void> Function(String)>((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  final booksNotifier = ref.read(booksProvider.notifier);

  return (String bookId) async {
    final result = await bookUseCases.startReading(bookId);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => booksNotifier.refreshBooks(),
    );
  };
});

final addBookProvider = Provider<Future<void> Function(Book)>((ref) {
  final bookUseCases = ref.watch(bookUseCasesProvider);
  final booksNotifier = ref.read(booksProvider.notifier);

  return (Book book) async {
    final result = await bookUseCases.addBook(book);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => booksNotifier.refreshBooks(),
    );
  };
});

final updateBookProvider = Provider<Future<void> Function(Book)>((ref) {
  final booksNotifier = ref.read(booksProvider.notifier);

  return (Book book) async {
    await booksNotifier.updateBook(book);
  };
});

final addReadingNoteProvider =
    Provider<Future<void> Function(String, ReadingNote)>((ref) {
  final booksNotifier = ref.read(booksProvider.notifier);

  return (String bookId, ReadingNote note) async {
    await booksNotifier.addReadingNote(bookId, note);
  };
});

final updateReadingNoteProvider =
    Provider<Future<void> Function(String, ReadingNote)>((ref) {
  final booksNotifier = ref.read(booksProvider.notifier);

  return (String bookId, ReadingNote note) async {
    await booksNotifier.updateReadingNote(bookId, note);
  };
});

final deleteReadingNoteProvider =
    Provider<Future<void> Function(String, String)>((ref) {
  final booksNotifier = ref.read(booksProvider.notifier);

  return (String bookId, String noteId) async {
    await booksNotifier.deleteReadingNote(bookId, noteId);
  };
});

class BooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final BookUseCases _bookUseCases;

  BooksNotifier(this._bookUseCases) : super(const AsyncValue.loading()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    state = const AsyncValue.loading();

    try {
      final result = await _bookUseCases.getBooks();
      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (books) {
          // 임시로 더미 데이터도 포함 (실제 데이터와 혼합)
          final allBooks = [...dummyBooks, ...books];
          // ID 중복 제거
          final uniqueBooks = <String, Book>{};
          for (final book in allBooks) {
            uniqueBooks[book.id] = book;
          }
          state = AsyncValue.data(uniqueBooks.values.toList());
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshBooks() async {
    await loadBooks();
  }

  Future<void> completeBook(String bookId) async {
    try {
      // 더미 데이터인지 확인
      final isDummyBook = dummyBooks.any((book) => book.id == bookId);

      if (isDummyBook) {
        // 더미 데이터인 경우 상태만 업데이트
        state.whenData((books) {
          final updatedBooks = books.map((book) {
            if (book.id == bookId) {
              return book.copyWith(
                status: BookStatus.completed,
                currentPage: book.totalPages,
                completedAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }
            return book;
          }).toList();
          state = AsyncValue.data(updatedBooks);
        });
      } else {
        // 실제 데이터인 경우 데이터베이스에서 완독 처리
        final result = await _bookUseCases.completeBook(bookId);

        await result.fold(
          (failure) async {
            throw Exception(failure.message);
          },
          (_) async {
            // 성공 시 상태 업데이트
            state.whenData((books) {
              final updatedBooks = books.map((book) {
                if (book.id == bookId) {
                  return book.copyWith(
                    status: BookStatus.completed,
                    currentPage: book.totalPages,
                    completedAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                }
                return book;
              }).toList();
              state = AsyncValue.data(updatedBooks);
            });
          },
        );
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> startReading(String bookId) async {
    try {
      final result = await _bookUseCases.startReading(bookId);
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => refreshBooks(),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addBook(Book book) async {
    try {
      final result = await _bookUseCases.addBook(book);
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => refreshBooks(),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      // 더미 데이터인지 확인
      final isDummyBook =
          dummyBooks.any((dummyBook) => dummyBook.id == book.id);

      if (isDummyBook) {
        // 더미 데이터인 경우 로컬 상태만 업데이트
        state.whenData((books) {
          final updatedBooks = books.map((existingBook) {
            if (existingBook.id == book.id) {
              return book;
            }
            return existingBook;
          }).toList();
          state = AsyncValue.data(updatedBooks);
        });
      } else {
        // 실제 데이터인 경우 데이터베이스에서 업데이트
        final result = await _bookUseCases.updateBook(book);
        result.fold(
          (failure) => throw Exception(failure.message),
          (_) => refreshBooks(),
        );
      }
    } catch (error) {
      rethrow;
    }
  }

  List<Book> getReadingBooks() {
    return state.maybeWhen(
      data: (books) =>
          books.where((book) => book.status == BookStatus.reading).toList(),
      orElse: () => [],
    );
  }

  List<Book> getCompletedBooks() {
    return state.maybeWhen(
      data: (books) =>
          books.where((book) => book.status == BookStatus.completed).toList(),
      orElse: () => [],
    );
  }

  List<Book> getPlannedBooks() {
    return state.maybeWhen(
      data: (books) =>
          books.where((book) => book.status == BookStatus.planned).toList(),
      orElse: () => [],
    );
  }

  Book? getBookById(String id) {
    return state.maybeWhen(
      data: (books) {
        try {
          return books.firstWhere((book) => book.id == id);
        } catch (e) {
          return null;
        }
      },
      orElse: () => null,
    );
  }

  Future<void> addReadingNote(String bookId, ReadingNote note) async {
    try {
      state.whenData((books) {
        final updatedBooks = books.map((book) {
          if (book.id == bookId) {
            final updatedNotes = [...book.notes, note];
            return book.copyWith(
              notes: updatedNotes,
              updatedAt: DateTime.now(),
            );
          }
          return book;
        }).toList();
        state = AsyncValue.data(updatedBooks);
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateReadingNote(String bookId, ReadingNote note) async {
    try {
      state.whenData((books) {
        final updatedBooks = books.map((book) {
          if (book.id == bookId) {
            final updatedNotes = book.notes.map((existingNote) {
              return existingNote.id == note.id ? note : existingNote;
            }).toList();
            return book.copyWith(
              notes: updatedNotes,
              updatedAt: DateTime.now(),
            );
          }
          return book;
        }).toList();
        state = AsyncValue.data(updatedBooks);
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteReadingNote(String bookId, String noteId) async {
    try {
      state.whenData((books) {
        final updatedBooks = books.map((book) {
          if (book.id == bookId) {
            final updatedNotes =
                book.notes.where((note) => note.id != noteId).toList();
            return book.copyWith(
              notes: updatedNotes,
              updatedAt: DateTime.now(),
            );
          }
          return book;
        }).toList();
        state = AsyncValue.data(updatedBooks);
      });
    } catch (error) {
      rethrow;
    }
  }
}
