import 'package:chatmessengerapp/components/chat_bubble.dart'; // Подключение виджета пузыря чата
import 'package:chatmessengerapp/services/chat/chat_service.dart'; // Подключение сервиса чата
import 'package:cloud_firestore/cloud_firestore.dart'; // Подключение Firestore для работы с базой данных в режиме реального времени
import 'package:firebase_auth/firebase_auth.dart'; // Подключение Firebase Auth для аутентификации пользователей
import 'package:flutter/material.dart'; 

import '../components/my_text_field.dart'; // Подключение кастомного текстового поля

// Объявление класса ChatPage, который наследуется от StatefulWidget, чтобы он мог иметь изменяемое состояние
class ChatPage extends StatefulWidget {
  final String receiveuserEmail; // Электронная почта получателя
  final String reciveUserID; // ID получателя

  // Конструктор для класса ChatPage, принимает ключ для виджета и обязательные параметры для email и ID получателя
  const ChatPage(
      {super.key, required this.receiveuserEmail, required this.reciveUserID}); 

  @override // Переопределение метода создания состояния виджета
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> { // Класс состояния для ChatPage
  final TextEditingController _messageController = TextEditingController(); // Контроллер для управления текстовым полем
  final ChatService _chatService = ChatService(); // Экземпляр сервиса чата для отправки и получения сообщений
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Экземпляр для работы с аутентификацией Firebase

  bool _isRecordingAudio = false; // Флаг для проверки, идет ли запись аудио
  bool _isSendingVideo = false; // Флаг для проверки, отправляется ли видео

  Map<String, dynamic>? _selectedMessageData; // Переменная для хранения данных выбранного сообщения
  bool _showReactionsMenu = false; // Переменная для контроля отображения меню с реакциями
  final Map<String, String?> _selectedEmojis = {}; // Словарь выбранных эмоджи для сообщений


  void sendMessage() async { // Метод для отправки сообщения
    if (_messageController.text.isNotEmpty) { // Проверка, не пусто ли текстовое поле
      await _chatService.sendMessage(
          widget.reciveUserID, _messageController.text); // Отправка сообщения через chatService
      _messageController.clear(); // Очистка текстового поля после отправки сообщения
    }
  }
 

    @override // Переопределение метода построения UI
  Widget build(BuildContext context) {
    return Scaffold( // Разметка основного экрана приложения
      appBar: AppBar( // Шапка приложения
        title: Text(widget.receiveuserEmail), // Отображение email получателя в шапке
        backgroundColor: Colors.grey[400], // Цвет фона шапки
      ),
      body: Column(children: [ // Основное тело страницы, разделенное на колонки
        Expanded( // Виджет для списка сообщений, занимает все доступное пространство
          child: _buildMessageList(), // Построение списка сообщений
        ),
        _buildMessageInput(), // Метод для построения строки ввода сообщения
      ]),
    );
  }

  // Функция для создания виджета, отображающего список сообщений
  Widget _buildMessageList() {
    return StreamBuilder( // Создание StreamBuilder для работы с потоковыми данными
      stream: _chatService.getMessages(
          widget.reciveUserID, _firebaseAuth.currentUser!.uid), // Инициализация потока сообщений от сервиса чата
      builder: (context, snapshot) { // Функция-строитель, создающая UI на основе текущего состояния snapshot
        if (snapshot.hasError) { // Проверка на наличие ошибки в потоке данных
          return Text('Error${snapshot.error}'); // Отображение сообщения об ошибке
        }

        if (snapshot.connectionState == ConnectionState.waiting) { // Проверка состояния соединения, ждем ли данные
          return const Text('loadin...'); // Отображение текста, указывающего на процесс загрузки
        }
        // Создание прокручиваемого списка сообщений, если данные успешно получены
        return ListView( // Использование ListView для вывода списка элементов
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document)) // Преобразование каждого документа в отдельное сообщение с помощью функции '_buildMessageItem'
              .toList(), // Преобразование итоговой последовательности в список
        );
      },
    );
  }


// Строим элемент сообщения
Widget _buildMessageItem(DocumentSnapshot document) {
  // Преобразуем данные документа в мапу (словарь)
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  // Уникальный идентификатор сообщения
  String messageId = document.id;

  // Проверяем, ассоциирована ли с этим сообщением реакция в виде эмодзи
  String? selectedEmoji = _selectedEmojis[messageId];

  // Возвращаем GestureDetector, чтобы иметь возможность обработать нажатие
  return GestureDetector(
    onTap: () {
      // При тапе переключаем видимость меню с реакциями
      setState(() {
        // Сохраняем данные выбранного сообщения
        _selectedMessageData = data;
        // Переключаем переменную, определяющую, показывать ли меню реакций
        _showReactionsMenu = !_showReactionsMenu;
      });
    },
    // Виджет Padding для отступов внутри элемента, содержащего сообщение
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      // Используем Column для вертикального выравнивания содержимого
      child: Column(
        // Выравниваем содержимое справа или слева,
        // в зависимости от того, отправитель это текущий пользователь или нет
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        // Так же для размещения в начале или в конце колонки
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        // Список виджетов, отображаемых в Column
        children: [
          // Отображаем email отправителя
          Text(data['senderEmail']),
          // Вставляем небольшой отступ между элементами
          const SizedBox(height: 5,),
          // Создаем пузырек для сообщения
          ChatBubble(message: data['message']),
          // Еще один отступ
          const SizedBox(height: 5,),
          // Если выбрано эмодзи, отображаем его
          if (selectedEmoji != null)
            Text(selectedEmoji, style: const TextStyle(fontSize: 24)),
          // Показываем реакции в виде эмодзи, если меню реакций активно
          // и если есть реакции на сообщение
          if (_showReactionsMenu &&
              data['reactions'] != null &&
              data['reactions'].isNotEmpty)
            // Используем Wrap для размещения реакций, он переносит виджеты на новую строку при необходимости
            Wrap(
              spacing: 8, // Регулируем расстояние между элементами
              children: data['reactions'].map<Widget>((reaction) {
                return GestureDetector(
                  onTap: () {
                    // Обработка нажатия на реакцию
                    setState(() {
                      // Ассоциируем выбранное эмодзи с этим сообщением
                      _selectedEmojis[messageId] = reaction;
                    });
                  },
                  // Отображаем каждую реакцию
                  child: Text(reaction, style: const TextStyle(fontSize: 24)),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}


  // Функция создания виджета для поля ввода сообщений
  Widget _buildMessageInput() {
   
    return Row(children: [ // Все элементы упорядочены в строку
      // Поле для ввода текста
      Expanded(
        flex: 5, // Это поле занимает 5 частей пространства в Row 
        child: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10, right: 0), // Отступы вокруг поля
          child: MyTextField( // Мой собственный класс текстового поля, который, вероятно, расширяет функциональность базового TextField
            controller: _messageController, // Контроллер для управления текстом в поле ввода
            hintText: "Введите сообщение", // Текст-подсказка в текстовом поле
            obscureText: false, // Текст не скрыт, для паролей значение должно быть true
          ),
        ),
      ),
       // Кнопка для переключения между аудио и видеорежимами
        Padding(
          padding: const EdgeInsets.only(bottom: 13, left: 5), // Отступы для кнопки
          child: IconButton(
            onPressed: () {
              setState(() {
                // Переключаем режими: если записываем аудио, то переключаемся на видео и наоборот
                if (_isRecordingAudio) {
                  _isRecordingAudio = false;
                  _isSendingVideo = true;
                } else {
                  _isRecordingAudio = true;
                  _isSendingVideo = false;
                }
              });
            },
            icon: _isRecordingAudio
                ? Icon(
                    Icons.videocam_outlined, // Если идет запись аудио, показываем иконку видеокамеры
                    size: 35, // Размер иконки
                    color: Colors.grey, // Цвет иконки
                  )
                : Icon(
                    Icons.mic_outlined, // В противном случае показываем иконку микрофона
                    size: 35, // Размер иконки
                    color: Colors.grey, // Цвет иконки
                  ),
          ),
        ),

      // Кнопка отправки сообщения
      Expanded( // Расширяем виджет, чтобы он занял доступное пространство.
        
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 5), // Отступы для кнопки
          child: IconButton(
              onPressed: sendMessage, // Функция отправки сообщения при нажатии
              icon: const Icon(
                Icons.arrow_forward_outlined, // Иконка "Стрелка вперед"
                size: 40, // Размер иконки
                color: Colors.grey, // Цвет иконки
              )),
        ),
      )
    ]);
  }
  
}
