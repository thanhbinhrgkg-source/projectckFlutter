import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projectck/cart_page.dart';
import 'package:projectck/category_page.dart';
import 'package:projectck/change_password_page.dart';
import 'package:projectck/checkout_page.dart';
import 'package:projectck/forgot_password_page.dart';
import 'package:projectck/home_page.dart';
import 'package:projectck/login_page.dart';
import 'package:projectck/member_page.dart';
import 'package:projectck/my_survey_page.dart';
import 'package:projectck/order_detail_page.dart';
import 'package:projectck/order_page.dart';
import 'package:projectck/product_admin_page.dart';
import 'package:projectck/product_detail_page.dart';
import 'package:projectck/product_form_page.dart';
import 'package:projectck/profile_page.dart';
import 'package:projectck/question_page.dart';
import 'package:projectck/register_page.dart';
import 'package:projectck/result_page.dart';
import 'package:projectck/role_page.dart';
import 'package:projectck/survey_page.dart';
import 'package:projectck/take_page.dart';
import 'package:projectck/verify_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color primary = Color(0xFF4F46E5);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khảo Sát Doanh Nghiệp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
        scaffoldBackgroundColor: Color(0xFFF4F5FB),
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 6),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFFE6E8F0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF7F8FC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E3EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: Size(0, 48),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        "/": (context) => HomePage(title: 'Khảo Sát Doanh Nghiệp'),
        "/register": (context) => RegisterPage(title: 'Đăng ký'),
        "/login": (context) => LoginPage(title: 'Đăng nhập'),
        "/member": (context) => MemberPage(title: 'Thành viên'),
        "/profile": (context) => ProfilePage(title: 'Hồ sơ'),
        "/my_survey": (context) => MySurveyPage(title: 'Khảo sát của tôi'),
        "/survey": (context) => SurveyPage(title: 'khảo sát'),
        "/question": (context) => QuestionPage(title: 'Câu hỏi'),
        "/take": (context) => TakePage(title: 'Làm khảo sát'),
        "/result": (context) => ResultPage(title: 'Kết quả'),
        "/verify": (context) => VerifyPage(title: 'Xác thực email'),
        "/forgot_password": (context) =>
            ForgotPasswordPage(title: 'Quên mật khẩu'),
        "/change_password": (context) =>
            ChangePasswordPage(title: 'Đổi mật khẩu'),
        "/roles": (context) => RolePage(title: 'Quản lý vai trò'),
        "/product": (context) => ProductDetailPage(title: 'Chi tiết gói'),
        "/cart": (context) => CartPage(title: 'Giỏ hàng'),
        "/checkout": (context) => CheckoutPage(title: 'Đặt hàng'),
        "/orders": (context) => OrderPage(title: 'Đơn hàng của tôi'),
        "/admin_orders": (context) =>
            OrderPage(title: 'Quản lý đơn hàng', isAdmin: true),
        "/order_detail": (context) =>
            OrderDetailPage(title: 'Chi tiết đơn hàng'),
        "/categories": (context) => CategoryPage(title: 'Quản lý danh mục'),
        "/admin_products": (context) =>
            ProductAdminPage(title: 'Quản lý sản phẩm'),
        "/product_form": (context) => ProductFormPage(title: 'sản phẩm'),
      },
    );
  }
}
