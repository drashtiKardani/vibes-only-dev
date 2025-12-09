import 'package:flutter/material.dart';

class FastFutureBuilder<T> extends FutureBuilder<T> {
  FastFutureBuilder({super.key, required super.future, required Widget Function(T) successBuilder})
      : super(builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text(snapshot.error.toString()));
    }
    if (snapshot.hasData) {
      return successBuilder(snapshot.data as T);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  });
}