# Dart Console Library Management System

## Project Description

This project is a console-based Library Management System built in Dart.
It allows a librarian and users to manage books, users, and borrowing operations through a terminal interface.
The goal of this project is to practice core Dart programming concepts such as OOP, async programming, isolates, streams, and data structures.

## Features Implemented
 ### 1) User System

 - Register users
 - Login system
 - Role selection (Admin / Student)
 - Borrowing history for each user

### 2) Book Catalog

 1) Add books (Admin only)

 2) Book attributes:

 - Title
 - Author
 - ISBN
 - Pages
 - Genre
 - Summary
 - Status (Available / Loaned / Reserved)

### 3) Advanced Search

 - Search books by title (keyword search)
 - Full-text search executed in a Dart Isolate

## Data Structures

 - Books stored in a Map<String, Book>
 - Authors stored in a Set<String>
 - Borrow history stored in a List<String>

## Async Database Simulation

 - All database operations use Future and async/await
 - Simulated load/save operations

## Activity Logging

 - Broadcast StreamController logs system events in real-time

## Object-Oriented Programming

 - Abstract database class
 - Inheritance and method overriding
 - Interfaces and Mixins
 - Enums for book status and user tier

## Error Handling

 - Custom exceptions for missing books and users
 - try/catch/finally for safe execution

## Demo Data

 - Books and users are seeded on startup for testing

## Technologies Used

 - Dart (Console Application)
 - Dart Isolates
 - Futures & async/await
 - Streams
 - Object-Oriented Programming

## How to Run

1️) Install Dart
  - Download Dart SDK from: https://dart.dev/get-dart

2️) Clone or Download the Project

`git clone <repo-link>`

`cd MY_PROJECT`

3️) Run the Application

`dart run bin/main.dart`

## Menu Options

Example main menu:

1) Show Books
2) Search Books
3) Borrow Book
4) Exit


 - Admins can also add books to the catalog.

## Concepts Demonstrated

This project demonstrates the following Dart concepts (as required by the assignment):

 - Variables and null safety (var, final, const, nullable types, ??)
 - Lists, Sets, and Maps with .map(), .where(), .fold()
 - Named and optional function parameters
 - Arrow functions and higher-order functions
 - Abstract classes and inheritance
 - Interfaces and Mixins
 - Enums
 - Futures and async/await
 - Broadcast Streams
 - Isolates with SendPort/ReceivePort
 - Custom Exceptions
 - Unicode runes in console output
 - Seeded demo data

## Future Improvements

 - Persistent file database (JSON / SQLite)
 - GUI version using Flutter
 - Client-server version with sockets
 - QR code book borrowing system
 - Analytics dashboard
 - Export reports to CSV/PDF

## Author

[Maya Otsmane]

Flutter bootcamp challenge 01 - Micro Club

Library Management System Project – Dart Console Application
