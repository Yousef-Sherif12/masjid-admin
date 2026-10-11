import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masjid_admin/core/theme/admin_theme.dart';
import 'package:masjid_admin/features/auth/data/auth_repository.dart';
import 'package:masjid_admin/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:masjid_admin/features/collections/presentation/cubit/collections_cubit.dart';
import 'package:masjid_admin/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:masjid_admin/features/iqama/data/repositories/iqama_repository_impl.dart';
import 'package:masjid_admin/features/iqama/presentation/cubit/iqama_cubit.dart';
import 'package:masjid_admin/features/ticker/data/repositories/admin_ticker_repository_impl.dart';
import 'package:masjid_admin/features/ticker/presentation/cubit/admin_ticker_cubit.dart';
import 'package:masjid_admin/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthRepository().signInAnonymously();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CollectionsCubit(CollectionsRepositoryImpl())..loadCollections(),
        ),
        BlocProvider(
          create: (_) => IqamaCubit(IqamaRepositoryImpl())..loadIqamaTimes(),
        ),
        BlocProvider(
          create: (_) =>
              AdminTickerCubit(AdminTickerRepositoryImpl())..init(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'لوحة تحكم المسجد',
        theme: AdminTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const DashboardScreen(),
      ),
    );
  }
}
