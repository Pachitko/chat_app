import 'package:cloud_firestore/cloud_firestore.dart'; // Подключение библиотеки Firebase Firestore.
import 'package:firebase_auth/firebase_auth.dart'; // Подключение библиотеки Firebase Auth.
import 'package:flutter/foundation.dart'; // Подключение библиотеки Flutter, содержащей основные функции.

// Класс AuthService для работы с аутентификацией.
class AuthService extends ChangeNotifier {
  // Создается экземпляр FirebaseAuth для работы с аутентификацией.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Создается экземпляр FirebaseFirestore для работы с базой данных Firestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Функция для входа пользователя через email и пароль.
  Future<UserCredential> signInWithEmailandPassword(String email, String password) async {
    try {
      // Аутентификация пользователя с использованием email и пароля.
      UserCredential userCredential = 
        await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      
      // Если пользователь вошел в систему, то в коллекции 'users' в Firestore создается документ для пользователя,
      // если документ не существует. Данные объединяются с существующими (если таковые есть).
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      // Возвращается объект с данными о пользовательской учетной записи.
      return userCredential; 
    } 
    // Обработка ошибок аутентификации Firebase.
    on FirebaseAuthException catch (e) {
      throw Exception(e.code); // Выбрасывание исключения с кодом ошибки.
    }
  }

  // Функция для регистрации пользователя через email и пароль.
  Future<UserCredential> signUpWithEmailandPassword(String email, String password) async {
    try {
      // Создание новой учетной записи пользователя с использованием email и пароля.
      UserCredential userCredential = 
        await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      
      // После создания пользователя в коллекции 'users' в Firestore создается документ для пользователя.
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      // Возвращается объект с данными о пользовательской учетной записи.
      return userCredential;
    }
    // Обработка ошибок аутентификации Firebase.
    on FirebaseAuthException catch(e) {
      throw Exception(e.code); // Выбрасывание исключения с кодом ошибки.
    }
  }

  // Функция для выхода пользователя из системы.
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut(); // Выход пользователя из учетной записи.
  }
}