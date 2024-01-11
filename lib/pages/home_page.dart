import 'package:cloud_firestore/cloud_firestore.dart'; // Импорт Firestore для работы с базой данных Firebase.
import 'package:firebase_auth/firebase_auth.dart'; // Импорт FirebaseAuth для аутентификации пользователей.
import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart'; // Импорт Provider для управления состоянием приложения.

import '../services/auth/auth_service.dart'; // Импорт сервиса аутентификации.
import 'chat_page.dart'; // Импорт страницы чата.

class HomePage extends StatefulWidget { // Определение StatefulWidget для домашней страницы.
  const HomePage({super.key}); // Конструктор с ключом для виджета.

  @override
  State<HomePage> createState() => _HomePageState(); // Создание состояния для HomePage.
}

class _HomePageState extends State<HomePage> { // Состояние для HomePage.
  
  final FirebaseAuth _auth = FirebaseAuth.instance; // Экземпляр FirebaseAuth для текущего пользователя.

  // Функция для выхода пользователя.
  void signOut() {
    // Получение сервиса аутентификации.
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut(); // Вызов функции выхода через сервис аутентификации.
  }

  @override
  Widget build(BuildContext context) {
    // Функция построения интерфейса.
    return  Scaffold(
      // Создание каркаса приложения.
      appBar: AppBar(
        title: const Text('Home Page'), // Заголовок для AppBar.
        backgroundColor: Colors.grey[400], // Цвет фона AppBar.
        actions: [
          // Кнопка для создания новой группы.
          IconButton(
            onPressed: _buildUserList, // Обработка нажатия кнопки (переход к списку пользователей).
            icon: const Icon(Icons.group), // Иконка группы.
          ),
          // Кнопка для выхода из учетной записи.
          IconButton(
            onPressed: signOut, // Обработка нажатия кнопки (выход из учетной записи).
            icon: const Icon(Icons.logout) // Иконка выхода.
          ),
        ],
      ),
      body: _buildUserList() // Вывод списка пользователей в теле приложения.
    );
  }

  // Функция построения списка пользователей, кроме текущего авторизованного пользователя.
  Widget _buildUserList(){
    // Виджет StreamBuilder для асинхронной работы с потоками данных.
    return StreamBuilder<QuerySnapshot>(
      // Поток данных пользователей из Firestore.
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot){
        // Отображение ошибок.
        if (snapshot.hasError){
          return const Text('Ошибка');
        }
        // Индикатор загрузки, если подключение находится в ожидании.
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Загрузка...');
        }
        // Виджет списка ListView для отображения пользователей.
        return ListView(
          // Преобразование документов в виджеты для их отображения.
          children: snapshot.data!.docs
            .map<Widget>((doc) => _buildUserListItem(doc))
            .toList(),
        );
      },
    );
  }
  // Функция построения элементов списка пользователей.
  Widget _buildUserListItem(DocumentSnapshot document){
    // Преобразование данных пользователя из документа Firestore.
    Map <String ,dynamic> data =document.data() ! as Map <String , dynamic>;
    // Отображение всех пользователей, кроме текущего.
  if (_auth.currentUser!.email != data['email']){
    return ListTile(
      // Показываем адрес электронной почты пользователя.
      title: Text( data['email']),
      onTap: (){ // Обработка нажатия на элемент списка.
        // При нажатии пользователя отправляют на страницу чата 
        // с передачей данных выбранного пользователя.
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChatPage(
            receiveuserEmail: data['email'],
            reciveUserID: data['uid'],
            ),
             )
             );
      },
    );

  }
  else{ // Если текущий пользователь, возвращаем пустой контейнер.
    return Container( 

    );
  }
  }
}
