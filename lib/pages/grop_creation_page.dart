import 'package:firebase_auth/firebase_auth.dart'; // Импорт библиотеки FirebaseAuth для аутентификации через Firebase
import 'package:flutter/material.dart'; // Импорт основной библиотеки дизайна Flutter

// Создание новой страницы или диалога для создания группы
class GroupCreationPage extends StatefulWidget {
  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  List<User> users = []; // Список пользователей, загружаемых из Firebase
  List<String> selectedUserIds = []; // Список идентификаторов выбранных пользователей
  String groupName = ""; // Название группы
  String category = ""; // Категория группы

  @override
  Widget build(BuildContext context) {
    // Построение интерфейса страницы
    return Scaffold(
      appBar: AppBar(
        // Панель приложения
        title: Text('Create Group'), // Заголовок
        actions: [
          // Действия в панели приложения
          IconButton(
            // Кнопка с иконкой
            icon: Icon(Icons.check), // Иконка галочки
            onPressed: () {
              // Событие при нажатии
              createGroup(); // Вызов функции для создания группы
            },
          ),
        ],
      ),
      body: Column(
        // Основной столбец с элементами страницы
        children: [
          // Виджет списка пользователей
          _buildUserList(),

          // Поля ввода для названия группы и категории
          TextField(
            // Текстовое поле для ввода
            onChanged: (value) {
              // Событие при изменении текста
              groupName = value; // Обновление названия группы
            },
            decoration: InputDecoration(labelText: 'Group Name'), // Декорации поля с надписью
          ),
          TextField(
            // Еще одно текстовое поле для ввода
            onChanged: (value) {
              // Событие при изменении текста
              category = value; // Обновление категории
            },
            decoration: InputDecoration(labelText: 'Category'), // Декорации поля с надписью
          ),
        ],
      ),
    );
  }

  // Функция построения списка пользователей
  Widget _buildUserList() {
    return ListView.builder(
      // Создание scrollable списка
      itemCount: users.length, // Количество элементов в списке равно количеству пользователей
      itemBuilder: (context, index) {
        // Построитель для каждого элемента списка
        final user = users[index]; // Получение пользователя по индексу
        final isSelected = selectedUserIds.contains(user.uid); // Проверка выбран ли пользователь

        return ListTile(
          // Виджет списка
          title: Text(user.uid), // Отображение UID пользователя
          leading: Checkbox(
            // Флажок выбора
            value: isSelected, // Активен если пользователь выбран
            onChanged: (bool? selected) {
              // Событие при изменении состояния флажка
              setState(() {
                // Обновление состояния виджета
                if (selected != null) {
                  // Проверка на null
                  if (selected) {
                    // Если флажок установлен
                    selectedUserIds.add(user.uid); // Добавление UID в список выбранных
                  } else {
                    // Если флажок снят
                    selectedUserIds.remove(user.uid); // Удаление UID из списка выбранных
                  }
                }
              });
            },
          ),
        );
      },
    );
  }

  // Функция создания группы
  void createGroup() {
    if (selectedUserIds.length >= 2) {
      // Проверка на минимальное количество участников
      // Создание группы в базе данных с selectedUserIds, groupName и category
      // После создания группы можно перейти к ней или выполнить другие действия
    } else {
      // Вывод сообщения об ошибке, если выбрано менее 2 пользователей
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select at least 2 users to create a group.'),
          // Содержимое снэкбара с текстом
        ),
      );
    }
  }
}