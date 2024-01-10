// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:chatmessengerapp/services/auth/auth_service.dart'; // Подключение библиотеки сервиса аутентификации
import 'package:flutter/material.dart'; // Подключение основной библиотеки Flutter для разработки интерфейса
import 'package:provider/provider.dart'; // Подключение библиотеки Provider для управления состоянием приложения

import '../components/my_button.dart'; // Подключение пользовательского виджета кнопки
import '../components/my_text_field.dart'; // Подключение пользовательского виджета текстового поля
// Подключение сервиса аутентификации (повторный импорт, возможно, ошибка)

// Объявление класса RegisterPage, который наследуется от StatefulWidget, 
// что позволяет ему иметь изменяемое состояние
class RegisterPage extends StatefulWidget {
  final void Function()? onTap; // Объявление опционального callback-события onTap
  const RegisterPage({super.key, required this.onTap}); // Конструктор с ключом и событием onTap

  @override
  State<RegisterPage> createState() => _RegisterPageState(); // Создание состояния для RegisterPage
}

// Класс состояния для RegisterPage
class _RegisterPageState extends State<RegisterPage> {
  // Контроллеры текстовых полей для управления их содержимым
  final emailController = TextEditingController(); // Для поля ввода email
  final passwordController = TextEditingController(); // Для поля ввода пароля
  final confirmPasswordController = TextEditingController(); // Для поля ввода подтверждения пароля

  // Метод для регистрации пользователя
  void signup() async {
    // Проверка на совпадение пароля и его подтверждения
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match'))); // Отображение уведомления, если пароли не совпадают
          return; // Прерывание выполнения метода, если пароли не совпают
    }

    // Получение экземпляра сервиса аутентификации
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      // Попытка регистрации пользователя с помощью электронной почты и пароля
      await authService.signUpWithEmailandPassword(emailController.text, passwordController.text);
    } catch(e) {
      // Отображение ошибки в Snackbar в случае неудачи при регистрации
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  
  }

  @override
  Widget build(BuildContext context) {
    // Создаем виджет-структуру страницы.
    return Scaffold(
        // Цвет фона устанавливаем в светло-серый.
        backgroundColor: Colors.grey[300],
        // Создаем безопасную зону (избегаем "вырезов" и других препятствий).
        body: SafeArea(
          // ScrollView позволяет прокручивать содержимое, если оно не помещается на экране.
          child: SingleChildScrollView(
            // Expanded позволяет растянуть дочерний виджет на все доступное пространство.
            child: Expanded(
              // Позиционируем содержимое в центре экрана.
              child: Center(
                // Добавляем отступы со всех сторон для внутреннего содержимого.
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 50.0),
                  // Column размещает своих детей по вертикали.
                  child: Column(
                    // Выравнивание детей Column по центру.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Добавляет прозрачное пространство высотой 50 пикселей.
                      SizedBox(
                        height: 50,
                      ),
                      // Иконка сообщения, являющаяся логотипом.
                      Icon(
                        Icons.message,
                        size: 100,
                        color: Colors.grey[700],
                      ),
                      // Еще прозрачного пространства.
                      SizedBox(
                        height: 50,
                      ),
                      // Текстовый виджет для вывода сообщения о создании аккаунта.
                      Text(
                        "Let's create an account for you!",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      // Отступ между текстом и полем ввода.
                      SizedBox(
                        height: 25,
                      ),
                      // Поле для ввода email.
                      MyTextField(
                          controller: emailController,
                          hintText: 'Email',
                          obscureText: false),
                      // Расстояние между полями ввода.
                      SizedBox(height: 10),
                      // Поле для ввода пароля.
                      MyTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: true),
                      // Отступ между полями ввода пароля и подтверждения пароля.
                      SizedBox(height: 10),
                      // Поле для подтверждения введенного пароля.
                      MyTextField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: true),
                      // Отступ между полями ввода и кнопкой регистрации.
                      SizedBox(height: 25),
                      // Кнопка создания аккаунта.
                      MyButton(onTap: signup, text: "Create Account"),
                      // Отступ между кнопкой регистрации и текстом входа.
                      SizedBox(height: 50),
                      // Строка с вариантом перейти на страницу входа.
                      Row(
                        // Располагаем элементы по центру строки.
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Текст 'Уже зарегистрированы?'.
                          Text('Already a member?'),
                          // Отступ между текстовыми виджетами.
                          SizedBox(width: 4),
                          // Кликабельный текст для перехода на страницу входа в аккаунт.
                          GestureDetector(
                            onTap: widget.onTap,
                            // Текст с акцентом, предлагающий войти.
                            child: Text(
                              'Login Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
