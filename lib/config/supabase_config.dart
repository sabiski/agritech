import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://zfoqgivlbxtqosaupxoa.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpmb3FnaXZsYnh0cW9zYXVweG9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE1NTM4ODYsImV4cCI6MjA1NzEyOTg4Nn0.TbzHaudhQMHQgSA1_JnKsBOBuxvkrPh5kOfpgb98V8I';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
} 