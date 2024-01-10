import 'package:flutter/material.dart';

// Объявляем класс MyButton, наследуемый от StatelessWidget — базовый виджет для создания кнопки
class MyButton extends StatelessWidget {
  final void  Function()? onTap; // Объявляем колбэк-функцию для обработки нажатия
  final String text; // Переменная для текста кнопки

  // Конструктор класса MyButton
  const MyButton({
    super.key, // Ключ для контроля состояния виджета
    required this.onTap, // Обязательный параметр для колбэка нажатия
    required this.text, // Обязательный параметр для текста кнопки
  });

  @override
  Widget build(BuildContext context) { // Переопределенный метод строит элемент интерфейса
    return GestureDetector( // Виджет для обработки жестов
      onTap: onTap, // Передача колбэка onTap
      child: Container( // Контейнер для стилизации элемента
        padding: EdgeInsets.all(25), // Внутренний отступ со всех сторон 
        // ignore: prefer_const_constructors
        decoration: BoxDecoration( // Оформление контейнера
          color: Colors.black, // Задний фон - черный цвет
          borderRadius: BorderRadius.circular(9) // Скругление углов
        ),
        child: Center( // Центрированный виджет
          child: Text( // Текстовый виджет для отображения текста кнопки
            text, // Текст кнопки
            style: TextStyle( // Стиль текста
              color: Colors.white, // Цвет текста - белый
              fontWeight: FontWeight.bold, // Выделение текста жирным шрифтом
              fontSize: 16 // Размер шрифта
            ),
          ),
        ),
      ),
    );
  }
}