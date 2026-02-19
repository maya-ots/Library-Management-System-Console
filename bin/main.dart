import 'dart:isolate';
import 'dart:async';
import 'dart:io';

// ======================================================
// ENUMS
// ======================================================
enum BookStatus { available, loaned, reserved }
enum MemberTier { standard, premium }
enum Genre { fiction, education, history, scifiction }

// ======================================================
// EXCEPTIONS
// ======================================================
class BookNotFoundException implements Exception {
  final String message;
  BookNotFoundException(this.message);
  @override
  String toString() => "BookNotFoundException: $message";
}

class UserNotFoundException implements Exception {
  @override
  String toString() => "UserNotFoundException: User does not exist!";
}

// ======================================================
// MIXINS
// ======================================================
mixin LoggerMixin {
  void log(String msg) => print("[LOG] $msg");
}

mixin TimeMixin {
  DateTime get now => DateTime.now();
}

// ======================================================
// ABSTRACT CLASS
// ======================================================
abstract class Database {
  Future<void> save();
  Future<void> load();
}

// ======================================================
// CLASSES
// ======================================================
class Book {
  final String id;
  String title;
  String author;
  String isbn;
  int pages;
  Genre genre;
  String? summary;
  BookStatus status;
  int borrowCount = 0;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.pages,
    required this.genre,
    this.summary,
    this.status = BookStatus.available,
  });

  String get safeSummary => summary ?? "No summary available.";

  String get statusText {
    switch (status) {
      case BookStatus.available:
        return "Available";
      case BookStatus.loaned:
        return "Borrowed";
      case BookStatus.reserved:
        return "Reserved";
    }
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "author": author,
        "isbn": isbn,
        "pages": pages,
        "genre": genre.name,
        "summary": safeSummary,
        "status": status.name,
      };
}

class User {
  final String username;
  final String password;
  final bool isAdmin;
  List<String> borrowedBooks = [];

  User(this.username, this.password, {this.isAdmin = false});
}

// ======================================================
// DATABASE MANAGER
// ======================================================
class LibraryManager extends Database with LoggerMixin, TimeMixin {
  final Map<String, Book> books = <String, Book>{};
  final List<User> users = <User>[];
  final Set<String> authors = <String>{};

  @override
  Future<void> load() async {
    await Future.delayed(Duration(milliseconds: 300));
    log("Database loaded");
  }

  @override
  Future<void> save() async {
    await Future.delayed(Duration(milliseconds: 300));
    log("Database saved");
  }

  Future<void> addBook(Book book) async {
    try {
      books[book.id] = book;
      authors.add(book.author);
      await save();
      log("Book added: ${book.title}");
    } catch (e) {
      print("Error adding book: $e");
    }
  }

  List<Book> searchByTitle(String keyword) =>
      books.values.where((b) => b.title.contains(keyword)).toList();

  List<String> allTitles() => books.values.map((b) => b.title).toList();

  int totalBorrowCount() => books.values.fold(0, (sum, b) => sum + b.borrowCount);

  Future<void> borrowBook(String username, String bookId) async {
    try {
      final book = books[bookId] ?? (throw BookNotFoundException(bookId));
      if (book.status != BookStatus.available) {
        print("Book is not available!");
        return;
      }
      book.status = BookStatus.loaned;
      book.borrowCount++;
      final u = users.firstWhere((u) => u.username == username);
      u.borrowedBooks.add(bookId);
      await save();
      log("$username borrowed ${book.title}");
    } catch (e) {
      print(e);
    }
  }

  User? login(String username, String password) {
    return users.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => throw UserNotFoundException());
  }

  void registerUser(String username, String password, bool isAdmin) {
    users.add(User(username, password, isAdmin: isAdmin));
  }
}

// ======================================================
// ISOLATE SEARCH WORKER
// ======================================================

void isolateSearch(SendPort sendPort) {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  port.listen((msg) {
    final List<Map<String, dynamic>> books = msg["books"];
    final String keyword = msg["keyword"];

    final results = books.where((b) => b["title"].contains(keyword)).toList();
    sendPort.send(results);
  });
}

// ======================================================
// HELPERS
// ======================================================

const bookEmoji = '\u{1F4DA}';

void seedDemoData(LibraryManager manager) {
  manager.addBook(Book(
    id: "1",
    title: "1984",
    author: "George Orwell",
    isbn: "9780451524935",
    pages: 328,
    genre: Genre.fiction,
    summary: "A dystopian novel about surveillance and totalitarianism.",
  ));

  manager.addBook(Book(
    id: "2",
    title: "Atomic Habits",
    author: "James Clear",
    isbn: "9780735211292",
    pages: 320,
    genre: Genre.education,
    summary: "A practical guide to building good habits.",
  ));

  manager.registerUser("admin", "admin123", true);
  manager.registerUser("student", "1234", false);
}

Future<void> addBookMenu(LibraryManager manager) async {
  print("Title:");
  final title = stdin.readLineSync()!;
  print("Author:");
  final author = stdin.readLineSync()!;
  print("ISBN:");
  final isbn = stdin.readLineSync()!;
  print("Pages:");
  final pages = int.parse(stdin.readLineSync()!);
  print("Genre (fiction, education, history, scifiction):");
  final genre = Genre.values.firstWhere(
      (g) => g.name.toLowerCase() == stdin.readLineSync()!.toLowerCase());

  final id = DateTime.now().millisecondsSinceEpoch.toString();

  await manager.addBook(Book(
      id: id, title: title, author: author, isbn: isbn, pages: pages, genre: genre));

  print("Book added!");
}

// ======================================================
// STREAM LOGGER
// ======================================================

final activityStream = StreamController<String>.broadcast();


// ======================================================
// MAIN FUNCTION
// ======================================================


Future<void> main() async {
  print("$bookEmoji Library System Started");

  final manager = LibraryManager();
  await manager.load();
  seedDemoData(manager);

  // Stream listener

  final sub = activityStream.stream.listen((event) {
    print("LIVE LOG: $event");
  });

  // Isolate setup

  final receivePort = ReceivePort();
  await Isolate.spawn(isolateSearch, receivePort.sendPort);
  final isolatePort = await receivePort.first as SendPort;
  


  // LOGIN / REGISTER

  User? currentUser;

  while (currentUser == null) {
    print("""
1) Login
2) Register
Choose:
""");

    final choice = stdin.readLineSync();

    if (choice == "1") {
      print("Username:");
      final u = stdin.readLineSync()!;
      print("Password:");
      final p = stdin.readLineSync()!;
      try {
        currentUser = manager.login(u, p);
        print("Logged in as ${currentUser!.username}");
      } catch (_) {
        print("Invalid credentials");
      }
    } else if (choice == "2") {
      print("Username:");
      final u = stdin.readLineSync()!;
      print("Password:");
      final p = stdin.readLineSync()!;
      print("Role (admin/student):");
      final role = stdin.readLineSync()!;
      manager.registerUser(u, p, role.toLowerCase() == "admin");
      print("Registered!");
    }
  }

  // MAIN MENU LOOP
  
  while (true) {
    print("""
==============================
 LIBRARY MANAGEMENT SYSTEM
Logged in as: ${currentUser.username} (${currentUser.isAdmin ? "Librarian" : "Student"})
==============================
1) Show Books
2) Search Books
3) Borrow Book
${currentUser.isAdmin ? "4) Add Book (Admin)\n" : ""}5) Exit
Choose option:
""");

    final choice = stdin.readLineSync();

    try {
      if (choice == "1") {
        print("\n===== BOOK CATALOG =====");
        for (var b in manager.books.values) {
          print("${b.id}. ${b.title} by ${b.author}");
          print("   ISBN: ${b.isbn}");
          print("   Pages: ${b.pages}");
          print("   Genre: ${b.genre.name}");
          print("   Status: ${b.statusText}");
          print("   Summary: ${b.safeSummary}\n");
        }
      } else if (choice == "2") {
        print("Keyword:");
        final kw = stdin.readLineSync()!;
        isolatePort.send({
          "books": manager.books.values.map((b) => b.toMap()).toList(),
          "keyword": kw
        });
        final result = await receivePort.first;
        print("\n--- Search Results ---");
        for (var b in result) {
          print("${b["title"]} by ${b["author"]}");
        }
      } else if (choice == "3") {
        print("Book ID to borrow:");
        final id = stdin.readLineSync()!;
        await manager.borrowBook(currentUser.username, id);
        activityStream.add("${currentUser.username} borrowed $id");
      } else if (choice == "4" && currentUser.isAdmin) {
        await addBookMenu(manager);
      } else if (choice == "5" || (choice == "4" && !currentUser.isAdmin)) {
        await manager.save();
        await sub.cancel();
        await activityStream.close();
        print("Goodbye!");
        break;
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }
}


