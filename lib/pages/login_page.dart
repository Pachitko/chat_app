// ignore_for_file: prefer_const_constructors

// Импортируем необходимые пакеты
import 'package:chatmessengerapp/components/my_button.dart'; // Пользовательский виджет кнопки
import 'package:chatmessengerapp/components/my_text_field.dart'; // Пользовательский виджет текстового поля
import 'package:flutter/material.dart'; // Основной пакет виджетов и стилей Flutter
import 'package:provider/provider.dart'; // Пакет для управления состоянием приложения через Provider

import '../services/auth/auth_service.dart'; // Сервис аутентификации пользователя

// Создание класса LoginPage, который будет состоянием StatefulWidget
class LoginPage extends StatefulWidget {
  final void Function()? onTap; // Переменная для функции обратного вызова при нажатии
  const LoginPage({super.key, required this.onTap}); // Конструктор класса с ключом и функцией onTap

  @override // Переопределение метода createState для создания состояния
  State<LoginPage> createState() => _LoginPageState(); // Создание состояния _LoginPageState для LoginPage
}

// Класс состояния _LoginPageState для нашего StatefulWidget LoginPage
class _LoginPageState extends State<LoginPage> {
  // Контроллеры текста для управления вводом пользователя
  final emailController = TextEditingController(); // Контроллер для электронной почты
  final passwordController = TextEditingController(); // Контроллер для пароля

  // Метод для входа пользователя в систему
  void signIn() async {
    // Получаем экземпляр authService для работы с аутентификацией
    final authService = Provider.of<AuthService>(context,listen: false);
    try {
      // Пытаемся войти по электронной почте и паролю
      await authService.signInWithEmailandPassword(
        emailController.text, passwordController.text);

    }catch (e){ // Обрабатываем возможные ошибки
      // Показываем сообщение об ошибке на экране
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          e.toString() // Преобразуем ошибку в строку и отображаем
        ))
      );
    }
  }

@override
Widget build(BuildContext context) { 
  return Scaffold( // Создает основную структуру визуального макета приложения
    backgroundColor: Colors.grey[300], // Устанавливает фоновый цвет Scaffold
    body: SafeArea( // Виджет, создающий область в интерфейсе, которая не перекрывается, например, нотчем или системными индикаторами
      child: SingleChildScrollView( // Этот виджет позволяет прокручивать его содержимое, если оно переполняет видимую область
        child: Expanded( // Виджет, который расширяет дочерний элемент, чтобы заполнить все доступное пространство
          child: Center( // Центрирует его дочерний элемент
            child: Padding( // Применяет отступы ко всем граням дочернего элемента
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0), // Устанавливает горизонтальные и вертикальные отступы
              child: Column( // Виджет, который отображает своих детей в вертикальной последовательности
                mainAxisAlignment: MainAxisAlignment.center, // Центрует детей в основной оси (вертикальной)
                children: [ // Массив дочерних виджетов
                  SizedBox(height: 50,), // Оставляет пустое пространство с фиксированной высотой
                  // значок сообщения
                  Icon( // Виджет иконки
                    Icons.message, // Значок иконки
                    size: 100, // Размер значка
                    color: Colors.grey[700], // Цвет значка
                  ),
                  SizedBox(height: 50,), // Оставляет пустое пространство с фиксированной высотой
                  // приветственное сообщение
                  Text( // Виджет текста
                    "Welcome Back! We missed you!", // Текст, который будет отображаться
                    style: TextStyle( // Стиль текста
                      fontSize: 20, // Размер шрифта текста
                    ),
                  ),
                  SizedBox(height: 25,), // Оставляет пустое пространство с фиксированной высотой
                  // поле для электронной почты
                  MyTextField( // Пользовательский виджет текстового поля (не встроенный, должен быть определен в другом месте кода)
                      controller: emailController, // Контроллер для управления содержимым текстового поля
                      hintText: 'Email', // Текст-подсказка, отображаемый в текстовом поле, когда оно пустое
                      obscureText: false), // Скрывает текст, если true (используется для паролей). Здесь set to false
                  SizedBox(height: 10), // Оставляет пустое пространство с фиксированной высотой
                  // поле для пароля 
                  MyTextField( // Пользовательский виджет текстового поля
                      controller: passwordController, // Контроллер для управления содержимым текстового поля
                      hintText: 'Password', // Текст-подсказка
                      obscureText: true), // Текст становится невидимым при вводе, обычно для паролей
                  SizedBox(height: 25), // Оставляет пустое пространство с фиксированной высотой
                  // кнопка входа
                  MyButton(onTap: signIn, text: "Sign In"), // Пользовательский виджет кнопки (не встроенный)

                  SizedBox(height: 50), // Оставляет пустое пространство с фиксированной высотой
                  // зарегистрироваться
                  Row( // Виджет, располагающий своих детей в горизонтальной последовательности
                    mainAxisAlignment: MainAxisAlignment.center, // Центрирует детей в основной оси (горизонтальной)
                    children: [ 
                    Text('Not a member?'), // Виджет текста, отображает эту строку
                    SizedBox(width: 4), // Горизонтальный отступ
                    GestureDetector( // Виджет для обработки касаний
                      onTap: widget.onTap, // Функция, которая вызывается при касании
                      child: Text('Register Now', // Виджет текста с предложением зарегистрироваться
                      style: TextStyle( // Стиль текста
                        fontWeight: FontWeight.bold // Жирное начертание
                      ),),
                    ),
                  ],)
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
