import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class TestState {
  final String name;

  const TestState({this.name = ""});

  TestState copyWith({String name = "000"}) {
    return TestState(name: name);
  }
}

final testControllerProvider =
    StateNotifierProvider<TestProvider, TestState>((ref) {
  return TestProvider();
});

class TestProvider extends StateNotifier<TestState> {
  TestProvider() : super(const TestState());
  setTestProvider(String newValue) {
    state = state.copyWith(name: newValue);
  }

  reset() {
    state = const TestState();
  }
}
