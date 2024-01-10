import 'package:cloud_firestore/cloud_firestore.dart'; // Импорт библиотеки Firebase Cloud Firestore

class Message { // Объявление класса Message для модели сообщения
  final String receiverId; // ID получателя
  final String senderId; // ID отправителя
  final String senderEmail; // Электронная почта отправителя
  final String message; // Текст сообщения
  final Timestamp timestamp; // Временная метка отправки сообщения
  List<String> reactions; // Список реакций на сообщение (например, эмодзи)
  final String? audioUrl; // URL аудиосообщения (может быть null)
  
  // Конструктор класса для инициализации объекта Message
  Message({
    required this.senderId, // Требуется ID отправителя
    required this.senderEmail, // Требуется электронная почта отправителя
    required this.receiverId, // Требуется ID получателя
    required this.message, // Требуется текст сообщения
    required this.timestamp, // Требуется временная метка
    this.audioUrl, // URL аудиосообщения, необязательный параметр
    List<String>? reactions, // Список реакций, необязательный параметр
  }) : reactions = reactions ?? ["\u{1F604}", "\u{1F601}"]; // Инициализация списка реакций значениями по умолчанию, если не указаны

  // Конвертация объекта в map для последующего использования с Firestore
  // ignore: empty_constructor_bodies
  Map<String, dynamic> toMap() { // Метод toMap конвертирует данные сообщения в map
    return {
      'senderId': senderId, // Поле senderId добавляется в map
      'senderEmail': senderEmail, // Поле senderEmail добавляется в map
      'receiverId': receiverId, // Поле receiverId добавляется в map
      'message': message, // Поле message добавляется в map
      'timestamp': timestamp, // Поле timestamp добавляется в map
      'reactions': reactions, // Поле reactions добавляется в map
      // Если поле audioUrl определено (не null), оно также будет добавлено в map
      if (audioUrl != null) 'audioUrl': audioUrl, 
    };
  }
}

// Обратите внимание, что я добавил строку для поля `audioUrl` в методе `toMap`, чтобы включить это поле в выходной map, если оно не равно null. Это используется в Dart для условного добавления элементов в коллекцию: если у `audioUrl` есть значение, оно добавляется в map, если нет – игнорируется.