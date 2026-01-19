import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  List _chatList = [];
  bool _isLoading = true;
  final String _baseUrl = 'http://10.0.2.2/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _markAsRead(); // <--- TANDAI SUDAH DIBACA ADMIN
  }

   Future<void> _markAsRead() async {
    try {
      await http.post(
        Uri.parse('${_baseUrl}mark_admin_read.php'),
        headers: {
          // Wajib untuk InfinityFree
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {'id_user': widget.userId},
      );
      print("Pesan ditandai sudah dibaca admin.");
    } catch (e) {
      print("Error mark read: $e");
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_pesan.php?id_user=${widget.userId}'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _chatList = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch: $e");
    }
  }

  Future<void> _sendReply() async {
    if (_msgController.text.isEmpty) return;

    String pesan = _msgController.text;
    _msgController.clear();

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}admin_reply.php'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {
          'id_user': widget.userId,
          'balasan': pesan,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _fetchMessages(); 
      }
    } catch (e) {
      print("Error kirim: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chat: ${widget.userName}",
              style: const TextStyle(fontSize: 16),
            ),
            const Text(
              "User Support",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF673AB7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _chatList.length,
                    itemBuilder: (context, index) {
                      final chat = _chatList[index];
                      return Column(
                        children: [
                          _buildBubble(
                            chat['isi_pesan'],
                            false,
                            chat['waktu_kirim'],
                          ),
                          if (chat['balasan_admin'] != null)
                            _buildBubble(
                              chat['balasan_admin'],
                              true,
                              chat['waktu_balas'] ?? "",
                            ),
                        ],
                      );
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Balas pesan ${widget.userName}...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFF673AB7),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendReply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isAdmin, String time) {
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAdmin ? const Color(0xFF673AB7) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isAdmin ? const Radius.circular(15) : Radius.zero,
            bottomRight: isAdmin ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isAdmin ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 10,
                  color: isAdmin ? Colors.white70 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTime) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(dateTime));
    } catch (e) {
      return "";
    }
  }
}
