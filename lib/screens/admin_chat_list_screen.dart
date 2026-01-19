import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'admin_chat_detail_screen.dart'; // File detail chat (di bawah)

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  List _users = [];
  bool _isLoading = true;
 final String _baseUrl = 'http://10.0.2.2/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _fetchChatCustomers();
  }

  Future<void> _fetchChatCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_chat_customers.php'),
        // TAMBAHKAN HEADERS DI BAWAH INI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _users = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch customers: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return "";
    try {
      DateTime dt = DateTime.parse(dateTime);
      return DateFormat('dd MMM HH:mm').format(dt);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Pesan Masuk"),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text("Belum ada pesan dari user"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    int unread = int.tryParse(user['unread'].toString()) ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: Text(
                            user['username'][0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ),
                        title: Text(
                          user['username'],
                          style: TextStyle(
                            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          "Terakhir: ${_formatTime(user['last_time'])}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: unread > 0
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unread.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              )
                            : const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () async {
                          // Buka Detail Chat
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminChatDetailScreen(
                                userId: user['id'].toString(),
                                userName: user['username'],
                              ),
                            ),
                          );
                          _fetchChatCustomers(); // Refresh pas balik
                        },
                      ),
                    );
                  },
                ),
    );
  }
}