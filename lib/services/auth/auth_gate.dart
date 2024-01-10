import 'package:chatmessengerapp/services/auth/login_or_register.dart'; // Импорт файла login_or_register.dart из директории сервисов аутентификации
import 'package:firebase_auth/firebase_auth.dart'; // Импорт Firebase Auth для аутентификационных функций
import 'package:flutter/material.dart';

import '../../pages/home_page.dart'; // Импорт файла home_page.dart из папки pages

// Виджет `AuthGate`, использует `StreamBuilder` для прослушивания изменений состояния 
//аутентификации в Firebase. В зависимости от того, авторизован пользователь или 
// нет, виджет динамически отображает либо домашнюю страницу, либо страницу входа/регистрации.

class AuthGate extends StatelessWidget { // Создание класса AuthGate, который не изменяется во времени и расширяет StatelessWidget
  const AuthGate({super.key}); // Конструктор принимает ключ, используемый для управления виджетами

  @override
  Widget build(BuildContext context) { // Переопределение метода build для построения UI
    return Scaffold( // Создание бланка приложения с базовым дизайном
      body: StreamBuilder( // Создание StreamBuilder для работы с потоком данных
        stream: FirebaseAuth.instance.authStateChanges(), // Определение потока изменений состояния аутентификации
        builder: (context, snapshot){ // Функция строительство интерфейса на основе снимка состояния потока
          // если пользователь вошёл в систему
          if (snapshot.hasData){ // Проверка наличия данных в снимке (пользователь вошел)
            return const HomePage(); // Возвращает домашнюю страницу, если пользователь авторизован
          }

          // если пользователь НЕ вошёл в систему
          else{ // Если данных нет (пользователь не авторизован)
            return const LoginOrRegister(); // Возвращает страницу входа или регистрации
          }
        },
      ),
    );
  }
}