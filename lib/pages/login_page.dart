// ignore_for_file: prefer_const_constructors

// Импортируем необходимые пакеты
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger/components/my_button.dart'; // Пользовательский виджет кнопки
import 'package:messenger/components/my_text_field.dart'; // Пользовательский виджет текстового поля
import 'package:flutter/material.dart'; // Основной пакет виджетов и стилей Flutter
import 'package:provider/provider.dart'; // Пакет для управления состоянием приложения через Provider

import '../services/auth/auth_service.dart';
import '../services/geoposition_service.dart'; // Сервис аутентификации пользователя

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
  final _geoPositionService = new GeopositionService();

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _geoPositionService.saveCurrentGeoPosition();
    });
  }

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
    return Scaffold(
      // Создает осноную структуру визуального макета приложения
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Icon(
                        Icons.message,
                        size: 100,
                        color: Colors.grey[700],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Welcome Back! We missed you!",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      MyTextField(
                          controller: emailController,
                          hintText: 'Email',
                          obscureText: false),
                      SizedBox(height: 10),
                      MyTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: true),
                      SizedBox(height: 25),
                      MyButton(onTap: signIn, text: "Sign In"),
                      SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Not a member?'),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              'Register Now',
                              style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: signInWithGoogle,
                            child: Text(
                              'Sign in with google',
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

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
