import '../../domain/entities/book.dart';

abstract class BookRemoteDataSource {
  Future<List<Book>> getBooks();
  Future<Book> getBook(String id);
  Future<Book> addBook(Book book);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(String id);
  Future<List<Book>> searchBooks(String query);
}
