import 'package:flutter/material.dart'; // Импорт библиотеки Flutter для работы с элементами интерфейса
import '../../pages/login_page.dart'; // Импорт файла login_page.dart из директории pages
import '../../pages/register_page.dart'; // Импорт файла register_page.dart из директории pages

// Определение виджета LoginOrRegister, который унаследован от StatefulWidget, что позволяет ему хранить состояние
class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key}); // Конструктор, ключ super используется для инициализации ключа базового виджета

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState(); // Создает состояние виджета
}

// Определение состояния для виджета LoginOrRegister
class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Переменная для отслеживания, какую страницу показать: вход или регистрацию. Изначально показывается страница входа.
  bool showLoginPage = true;

  // Функция для переключения между страницей входа и регистрации
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage; // Меняет значение на противоположное, что вызывает перерисовку виджета
    });
  }

  @override
  Widget build(BuildContext context) {
    // Переопределение метода отрисовки виджета
    if (showLoginPage) {
      return LoginPage(onTap: togglePages); // Если переменная showLoginPage true, возвращаем виджет LoginPage
    } else {
      return RegisterPage(onTap: togglePages); // В противном случае, возвращаем виджет RegisterPage
    }
  }
}
