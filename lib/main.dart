import 'package:bharat_nxt_task/screens/home/home_screen.dart';
import 'package:bharat_nxt_task/screens/home/home_view_model.dart';
import 'package:bharat_nxt_task/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProxyProvider<ApiService, HomeViewModel>(
          create: (_) => HomeViewModel(ApiService()),
          update: (_, api, __) => HomeViewModel(api),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Articles',
        theme: ThemeData(useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
