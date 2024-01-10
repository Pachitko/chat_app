// Подключаем библиотеку Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Подключаем библиотеку Firebase Authentication
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

// Импортируем файл с классом сообщения
import '../../model/message.dart';

// Создаём сервис для работы с чатом, наследуясь от класса ChangeNotifier, который позволяет уведомлять слушателей об изменениях
class ChatService extends ChangeNotifier {
  // Получаем экземпляры FirebaseAuth и FirebaseFirestore для работы с аутентификацией и базой данных соответственно
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Функция для отправки сообщения
  Future<void> sendMessage(String receiverId, String messageTxt) async {
    // Получаем информацию о текущем аутентифицированном пользователе
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    // Получаем текущую метку времени
    final Timestamp timestamp = Timestamp.now();

    // Создаём экземпляр нового сообщения
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: messageTxt,
        timestamp: timestamp, 
        reactions: ["\u{1F604}", "\u{1F601}", "\u{1F602}", "\u{1F607}"]);

    // Формируем уникальный ID для чат-комнаты, используя ID текущего и получающего пользователя
    List<String> ids = [currentUserId, receiverId];
    // Важно отсортировать ID для обеспечения уникальности
    ids.sort(); 
    // Объединяем ID в строку для создания идентификатора чат-комнаты
    String chatRoomId = ids.join("_");

    // Добавляем новое сообщение в базу данных
    await _firestore
        .collection('chat_rooms') // Обращаемся к коллекции чат-комнат
        .doc(chatRoomId) // Документ для конкретной чат-комнаты
        .collection('messages') // Подколлекция сообщений
        .add(newMessage.toMap()); // Конвертируем сообщение в Map и добавляем в базу
  }

  // Функция получения потока сообщений
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Создаём идентификатор чат-комнаты из ID пользователей
    List<String> ids = [userId, otherUserId];
    ids.sort(); // Сортируем для обеспечения уникальности
    String chatRoomId = ids.join("_"); // Формируем ID комнаты

    // Возвращаем поток сообщений упорядоченных по временной метке
    return _firestore
        .collection('chat_rooms') // Обращаемся к коллекции чат-комнат
        .doc(chatRoomId) // Документ конкретной чат-комнаты
        .collection('messages') // Подколлекция сообщений
        // Упорядочиваем сообщения по временной метке в порядке возрастания
        .orderBy('timestamp', descending: false)
        .snapshots(); // Получаем поток данных для обновления сообщений
  }

  // Функция для добавления реакции на сообщение (пока не реализована)
  void addReaction(param0, String reaction) {}
}