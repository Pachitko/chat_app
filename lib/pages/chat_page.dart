import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/components/chat_bubble.dart'; // Подключение виджета пузыря чата
import 'package:messenger/services/chat/chat_service.dart'; // Подключение сервиса чата
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

class _ChatPageState extends State<ChatPage>
{
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<String> imageUrls = [];

  Map<String, dynamic>? _selectedMessageData;
  bool _showReactionsMenu = false;

  bool _isImagesLoaded = false;
  final Map<String, String?> _selectedEmojis = {};

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void sendMessage() async {
    // Метод для отправки сообщения
    if (_messageController.text.isNotEmpty) {
      // Проверка, не пусто ли текстовое поле
      await _chatService.sendMessage(widget.reciveUserID,
          _messageController.text); // Отправка сообщения через chatService
      _messageController
          .clear(); // Очистка текстового поля после отправки сообщения
    }
  }

  @override // Переопределение метода построения UI
  Widget build(BuildContext context) {
    return Scaffold(
      // Разметка основного экрана приложения
      appBar: AppBar(
        // Шапка приложения
        title: Text(widget.receiveuserEmail),
        // Отображение email получателя в шапке
        backgroundColor: Colors.grey[400], // Цвет фона шапки
      ),
      body: Column(children: [
        // Основное тело страницы, разделенное на колонки
        Expanded(
          // Виджет для списка сообщений, занимает все доступное пространство
          child: _buildMessageList(), // Построение списка сообщений
        ),
        _buildMessageInput(), // Метод для построения строки ввода сообщения
      ]),
    );
  }

  // Функция для создания виджета, отображающего список сообщений
  Widget _buildMessageList() {
    return StreamBuilder(
      // Создание StreamBuilder для работы с потоковыми данными
      stream: _chatService.getMessages(
          widget.reciveUserID, _firebaseAuth.currentUser!.uid),
      // Инициализация потока сообщений от сервиса чата
      builder: (context, snapshot) {
        // Функция-строитель, создающая UI на основе текущего состояния snapshot
        if (snapshot.hasError) {
          // Проверка на наличие ошибки в потоке данных
          return Text(
              'Error${snapshot.error}'); // Отображение сообщения об ошибке
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isImagesLoaded) {
          // Проверка состояния соединения, ждем ли данные
          return const Text(
              'loading...'); // Отображение текста, указывающего на процесс загрузки
        }
        // Создание прокручиваемого списка сообщений, если данные успешно получены
        return ListView(
          // Использование ListView для вывода списка элементов
          children: _buildMessagesAndImages(snapshot.data!.docs,
              imageUrls), // Преобразование итоговой последовательности в список
        );
      },
    );
  }

  List<Widget> _buildMessagesAndImages<T>(
      List<QueryDocumentSnapshot<T>> docs, List<String> imageUrls) {
    List<Widget> widgets = [];

    widgets
        .addAll(docs.map((document) => _buildMessageItem(document)).toList());

    widgets.addAll(
        imageUrls.map((imageUrl) => _buildImageItem(imageUrl)).toList());

    return widgets;
  }

  Widget _buildImageItem(String imageUrl) {
    // Возвращаем GestureDetector, чтобы иметь возможность обработать нажатие
    return GestureDetector(
      onTap: () {
        // При тапе переключаем видимость меню с реакциями
        _viewImage(imageUrl);
      },
      // Виджет Padding для отступов внутри элемента, содержащего сообщение
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // Используем Column для вертикального выравнивания содержимого
        child: Column(
          // Выравниваем содержимое справа или слева,
          // в зависимости от того, отправитель это текущий пользователь или нет
          crossAxisAlignment: CrossAxisAlignment.end,
          // Так же для размещения в начале или в конце колонки
          mainAxisAlignment: MainAxisAlignment.end,
          // Список виджетов, отображаемых в Column
          children: [
            // Отображаем email отправителя
            Text(FirebaseAuth.instance.currentUser!.email!),
            // Вставляем небольшой отступ между элементами
            const SizedBox(
              height: 5,
            ),
            // Создаем пузырек для сообщенияx
            Image.network(imageUrl, height: 100, width: 100),
            // Еще один отступ
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
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
          crossAxisAlignment:
          (data['senderId'] == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          // Так же для размещения в начале или в конце колонки
          mainAxisAlignment:
          (data['senderId'] == _firebaseAuth.currentUser!.uid)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          // Список виджетов, отображаемых в Column
          children: [
            // Отображаем email отправителя
            Text(data['senderEmail']),
            // Вставляем небольшой отступ между элементами
            const SizedBox(
              height: 5,
            ),
            // Создаем пузырек для сообщенияx
            ChatBubble(message: data['message']),
            // Еще один отступ
            const SizedBox(
              height: 5,
            ),
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
    return Row(children: [
      // Все элементы упорядочены в строку
      // Поле для ввода текста
      Expanded(
        flex: 5, // Это поле занимает 5 частей пространства в Row
        child: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10, right: 0),
          // Отступы вокруг поля
          child: MyTextField(
            // Мой собственный класс текстового поля, который, вероятно, расширяет функциональность базового TextField
            controller: _messageController,
            // Контроллер для управления текстом в поле ввода
            hintText: "Введите сообщение",
            // Текст-подсказка в текстовом поле
            obscureText:
            false, // Текст не скрыт, для паролей значение должно быть true
          ),
        ),
      ),
      // Кнопка для переключения между аудио и видеорежимами
      Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 5),
        // Отступы для кнопки
        child: IconButton(
            onPressed: () {
              _pickAndUploadImage();
            },
            icon: const Icon(
              Icons.attach_file_outlined,
              // Если идет запись аудио, показываем иконку видеокамеры
              size: 35, // Размер иконки
              color: Colors.grey, // Цвет иконки
            )),
      ),

      // Кнопка отправки сообщения
      Expanded(
        // Расширяем виджет, чтобы он занял доступное пространство.

        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 5),
          // Отступы для кнопки
          child: IconButton(
              onPressed: sendMessage,
              // Функция отправки сообщения при нажатии
              icon: const Icon(
                Icons.arrow_forward_outlined, // Иконка "Стрелка вперед"
                size: 40, // Размер иконки
                color: Colors.grey, // Цвет иконки
              )),
        ),
      )
    ]);
  }

  Future<void> _loadImages() async {
    _isImagesLoaded = false;
    ListResult result = await storage.ref('images/').listAll();
    List<String> urls = []; // Список для URL изображений
    for (var ref in result.items) {
      String downloadURL = await ref.getDownloadURL();
      urls.add(downloadURL);
    }
    setState(() {
      imageUrls = urls;
      _isImagesLoaded = true;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null)
    {
      return;
    }
    File file = File(image.path);
    String fileName =
        'images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);
    await ref.putFile(file);
    await _loadImages();
  }

  // Функция для просмотра изображения в полноэкранном режиме
  void _viewImage(String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Image Viewer'), // Заголовок
        ),
// Тело с изображением
        body: Center(
          child: Image.network(imageUrl),
        ),
      );
    }));
  }
}
