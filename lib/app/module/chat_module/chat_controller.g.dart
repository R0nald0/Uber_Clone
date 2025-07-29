// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatController on ChatControllerBase, Store {
  late final _$_loadingAtom =
      Atom(name: 'ChatControllerBase._loading', context: context);

  bool? get loading {
    _$_loadingAtom.reportRead();
    return super._loading;
  }

  @override
  bool? get _loading => loading;

  @override
  set _loading(bool? value) {
    _$_loadingAtom.reportWrite(value, super._loading, () {
      super._loading = value;
    });
  }

  late final _$_messagesAtom =
      Atom(name: 'ChatControllerBase._messages', context: context);

  List<MessageView> get messages {
    _$_messagesAtom.reportRead();
    return super._messages;
  }

  @override
  List<MessageView> get _messages => messages;

  @override
  set _messages(List<MessageView> value) {
    _$_messagesAtom.reportWrite(value, super._messages, () {
      super._messages = value;
    });
  }

  late final _$addMessageAsyncAction =
      AsyncAction('ChatControllerBase.addMessage', context: context);

  @override
  Future<void> addMessage(Messages message) {
    return _$addMessageAsyncAction.run(() => super.addMessage(message));
  }

  late final _$sendMensageAsyncAction =
      AsyncAction('ChatControllerBase.sendMensage', context: context);

  @override
  Future<void> sendMensage(String message) {
    return _$sendMensageAsyncAction.run(() => super.sendMensage(message));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
