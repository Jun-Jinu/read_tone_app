import '../../domain/entities/book.dart';

abstract class BookLocalDataSource {
  Future<List<Book>> getLastBooks();
  Future<void> cacheBooks(List<Book> books);
  Future<void> cacheBook(Book book);
  Future<void> deleteBook(String id);
}
