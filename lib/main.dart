import 'package:human_like_typing_bot/constants/constants.dart';
import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:human_like_typing_bot/providers/chats_provider.dart';
import 'package:human_like_typing_bot/providers/models_provider.dart';
import 'package:human_like_typing_bot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModelsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: scaffoldBackgroundColor,
            appBarTheme: AppBarTheme(color: cardColor)),
        home: const ChatScreen(),
      ),
    );
  }
}
