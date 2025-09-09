import 'package:dartz/dartz.dart';
import 'package:read_tone_app/core/error/failures.dart';
import 'package:read_tone_app/domain/repositories/book_repository.dart';

import '../../domain/entities/book.dart';

abstract class BookUseCases {
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, Book>> getBook(String id);
  Future<Either<Failure, Book>> addBook(Book book);
  Future<Either<Failure, void>> updateBook(Book book);
  Future<Either<Failure, void>> deleteBook(String id);
  Future<Either<Failure, void>> startReading(String id);
  Future<Either<Failure, void>> completeBook(String id);
  Future<Either<Failure, void>> planBook(String id);
  Future<Either<Failure, void>> updateReadingProgress(
      String id, int currentPage);
  Future<Either<Failure, void>> addReadingSession(
      String id, ReadingSession session);
  Future<Either<Failure, void>> updateBookActivity(String id);
  Future<Either<Failure, void>> toggleFavorite(String id);
  Future<Either<Failure, void>> updatePriority(String id, int priority);
  Future<Either<Failure, void>> addMemo(String id, String memo);
}

class BookUseCasesImpl implements BookUseCases {
  final BookRepository repository;

  BookUseCasesImpl(this.repository);

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    return await repository.getBooks();
  }

  @override
  Future<Either<Failure, Book>> getBook(String id) async {
    return await repository.getBook(id);
  }

  @override
  Future<Either<Failure, Book>> addBook(Book book) async {
    final now = DateTime.now();
    final newBook = book.copyWith(
      updatedAt: now,
    );
    return await repository.addBook(newBook);
  }

  @override
  Future<Either<Failure, void>> updateBook(Book book) async {
    final updatedBook = book.copyWith(updatedAt: DateTime.now());
    return await repository.updateBook(updatedBook);
  }

  @override
  Future<Either<Failure, void>> deleteBook(String id) async {
    return await repository.deleteBook(id);
  }

  @override
  Future<Either<Failure, void>> startReading(String id) async {
    try {
      return await repository.updateBookStatus(id, BookStatus.reading);
    } catch (e) {
      final bookResult = await repository.getBook(id);
      return bookResult.fold(
        (failure) => Left(failure),
        (book) async {
          final now = DateTime.now();
          final updatedBook = book.copyWith(
            status: BookStatus.reading,
            startedAt: now,
            lastReadAt: now,
            updatedAt: now,
          );
          return await repository.updateBook(updatedBook);
        },
      );
    }
  }

  @override
  Future<Either<Failure, void>> completeBook(String id) async {
    try {
      return await repository.updateBookStatus(id, BookStatus.completed);
    } catch (e) {
      final bookResult = await repository.getBook(id);
      return bookResult.fold(
        (failure) => Left(failure),
        (book) async {
          final now = DateTime.now();
          final updatedBook = book.copyWith(
            status: BookStatus.completed,
            currentPage: book.totalPages,
            completedAt: now,
            lastReadAt: now,
            updatedAt: now,
          );
          return await repository.updateBook(updatedBook);
        },
      );
    }
  }

  @override
  Future<Either<Failure, void>> planBook(String id) async {
    try {
      return await repository.updateBookStatus(id, BookStatus.planned);
    } catch (e) {
      final bookResult = await repository.getBook(id);
      return bookResult.fold(
        (failure) => Left(failure),
        (book) async {
          final updatedBook = book.copyWith(
            status: BookStatus.planned,
            startedAt: null,
            completedAt: null,
            updatedAt: DateTime.now(),
          );
          return await repository.updateBook(updatedBook);
        },
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateReadingProgress(
      String id, int currentPage) async {
    final bookResult = await repository.getBook(id);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) async {
        final now = DateTime.now();

        BookStatus newStatus = book.status;
        DateTime? newStartedAt = book.startedAt;
        DateTime? newCompletedAt = book.completedAt;

        if (book.status == BookStatus.planned && currentPage > 0) {
          newStatus = BookStatus.reading;
          newStartedAt = now;
        } else if (currentPage >= book.totalPages) {
          newStatus = BookStatus.completed;
          newCompletedAt = now;
        }

        final updatedBook = book.copyWith(
          currentPage: currentPage,
          status: newStatus,
          startedAt: newStartedAt,
          completedAt: newCompletedAt,
          lastReadAt: now,
          updatedAt: now,
        );

        return await repository.updateBook(updatedBook);
      },
    );
  }

  @override
  Future<Either<Failure, void>> addReadingSession(
      String id, ReadingSession session) async {
    final bookResult = await repository.getBook(id);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) async {
        final now = DateTime.now();

        final updatedBook = book.copyWith(
          currentPage: session.endPage,
          readingSessions: [...book.readingSessions, session],
          lastReadAt: session.endTime,
          updatedAt: now,
        );

        final updateResult = await repository.updateBook(updatedBook);

        if (updateResult.isRight()) {
          await repository.updateBookActivity(id);
        }

        return updateResult;
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateBookActivity(String id) async {
    return await repository.updateBookActivity(id);
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String id) async {
    return await repository.toggleBookFavorite(id);
  }

  @override
  Future<Either<Failure, void>> updatePriority(String id, int priority) async {
    final clampedPriority = priority.clamp(0, 10);
    return await repository.updateBookPriority(id, clampedPriority);
  }

  @override
  Future<Either<Failure, void>> addMemo(String id, String memo) async {
    final bookResult = await repository.getBook(id);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) async {
        final updatedBook = book.copyWith(
          memo: memo,
          updatedAt: DateTime.now(),
        );
        return await repository.updateBook(updatedBook);
      },
    );
  }

  Future<Either<Failure, void>> markAsRead(String id, {int? pagesRead}) async {
    final bookResult = await repository.getBook(id);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) async {
        final targetPage = pagesRead ?? book.totalPages;
        return await updateReadingProgress(id, targetPage);
      },
    );
  }

  Future<Either<Failure, Book>> createQuickBook({
    required String title,
    required String author,
    int totalPages = 0,
    String? coverImageUrl,
    bool isFavorite = false,
    int priority = 0,
  }) async {
    final now = DateTime.now();
    final book = Book(
      id: 'book_${now.millisecondsSinceEpoch}',
      title: title,
      author: author,
      coverImageUrl: coverImageUrl ?? '',
      totalPages: totalPages,
      currentPage: 0,
      status: BookStatus.planned,
      createdAt: now,
      updatedAt: now,
      readingSessions: [],
      isFavorite: isFavorite,
      priority: priority,
      notes: [],
    );

    return await repository.addBook(book);
  }

  Future<Either<Failure, double>> getReadingProgress(String id) async {
    final bookResult = await repository.getBook(id);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) => Right(book.readingProgress),
    );
  }

  Future<Either<Failure, Duration>> getTotalReadingTime(String id) async {
    final bookResult = await repository.getBook(id);
    return bookResult.fold(
      (failure) => Left(failure),
      (book) => Right(Duration(minutes: book.totalReadingTime)),
    );
  }
}
