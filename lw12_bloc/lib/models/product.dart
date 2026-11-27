import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String title;
  final double price;
  final IconData icon;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, title, price, icon];
}
