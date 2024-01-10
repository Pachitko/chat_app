// Выключаем правило lint, требующее использовать const конструкторы, где это возможно
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

// Определяем класс MyTextField, который наследуется от StatelessWidget, это образец виджета без состояния
class MyTextField extends StatelessWidget {
  final TextEditingController controller; // Определяем контроллер для управления текстом внутри поля
  final String hintText; // Определяем текст подсказки, который будет показываться в текстовом поле
  final bool obscureText; // Флаг, указывающий, надо ли скрывать текст (например, для ввода пароля)

   // Конструктор, принимающий ключ для виджета, контроллер, текст подсказки и флаг скрытия текста
   // Ключ помечен как super, что означает передачу его конструктору базового класса
   MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});

  // Переопределяем метод build для построения виджета
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Присваиваем контроллер виджету TextField
      obscureText: obscureText, // Устанавливаем значение скрытия текста
      decoration:  InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade200  // Цвет границы поля ввода в обычном состоянии (не фокус)
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200) // Цвет границы в состоянии фокуса
        ),
        fillColor: Colors.grey[200], // Цвет фона поля ввода
        filled: true, // Указываем, что поле ввода должно быть заполнено цветом фона
        hintText: hintText, // Устанавливаем текст подсказки
        // Определяем стиль текста подсказки - серый цвет
        hintStyle: TextStyle(color: Colors.grey,
        )
      ),

    );
  }
}