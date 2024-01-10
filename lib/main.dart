import 'package:chatmessengerapp/firebase_options.dart'; // Импортируем конфигурации Firebase.
import 'package:chatmessengerapp/services/auth/auth_gate.dart'; // Импортируем AuthGate, который будет управлять потоком аутентификации.
import 'package:chatmessengerapp/services/auth/auth_service.dart'; // Импортируем AuthService для функционала аутентификации.
import 'package:firebase_core/firebase_core.dart'; // Импортируем основной пакет Firebase.
import 'package:flutter/material.dart'; // Импортируем Material Design пакет для Flutter.
import 'package:provider/provider.dart'; // Импортируем библиотеку Provider для управления состоянием.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Инициализация Flutter виджетов перед выполнением асинхронных операций.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Асинхронно инициализируем Firebase с авто-определенными опциями в зависимости от платформы.
  runApp(
    ChangeNotifierProvider(
    create: (context) =>  AuthService(), // Создаем экземпляр AuthService, который будет доступен для потомков в дереве виджетов.
    child: const MyApp(), // Запускаем основное приложение "MyApp".
    ),
  );
}
class MyApp extends StatelessWidget { // Определяем основной класс приложения, который является статичным и не изменяет своего состояния.
  const MyApp({super.key}); // Конструктор класса MyApp с ключом.

  @override
  Widget build(BuildContext context) { // Определяем метод построения UI.
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Убираем баннер режима отладки в углу экрана.
      home: AuthGate(), // Устанавливаем AuthGate в качестве домашнего экрана.
    );
    
  }
}