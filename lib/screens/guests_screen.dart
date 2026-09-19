import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/widgets/app_header.dart';

class _Guest {
  final String name;

  const _Guest(this.name);
}

class GuestsScreen extends StatefulWidget {
  final String cardTitle;
  final String cardDescription;
  final Uint8List cardImageBytes;

  const GuestsScreen({
    super.key,
    required this.cardTitle,
    required this.cardDescription,
    required this.cardImageBytes,
  });

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  final _nameController = TextEditingController();
  final List<_Guest> _guests = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addGuest() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _guests.add(_Guest(name));
      _nameController.clear();
    });
  }

  void _removeGuest(int index) {
    setState(() => _guests.removeAt(index));
  }

  Future<void> _sendInvite(_Guest guest) async {
    final caption =
        'دعوة: ${widget.cardTitle}\n'
        '${widget.cardDescription}\n\n'
        'إلى الحبيب/ة ${guest.name}، يسعدنا حضورك 🌸';

    await SharePlus.instance.share(
      ShareParams(
        text: caption,
        files: [
          XFile.fromData(
            widget.cardImageBytes,
            mimeType: 'image/png',
            name: 'invitation.png',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.beige,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  title: 'قائمة المدعوين',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 18),
                _buildAddGuestCard(),
                const SizedBox(height: 18),
                Text(
                  'المدعوون (${_guests.length})',
                  style: GoogleFonts.amiri(
                    color: AppColors.burgundy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _guests.isEmpty
                      ? Center(
                          child: Text(
                            'لسه ما أضفتي أي مدعو',
                            style: GoogleFonts.amiri(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _guests.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildGuestCard(_guests[index], index),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddGuestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(color: AppColors.burgundy),
            decoration: InputDecoration(
              hintText: 'اسم المدعو',
              hintStyle: GoogleFonts.amiri(color: Colors.grey.shade400),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _addGuest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.add, color: AppColors.burgundy),
              label: Text(
                'إضافة للقائمة',
                style: GoogleFonts.amiri(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(_Guest guest, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              guest.name,
              style: GoogleFonts.amiri(
                color: AppColors.burgundy,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _sendInvite(guest),
            icon: const Icon(Icons.send, color: Colors.green),
            tooltip: 'مشاركة البطاقة',
          ),
          IconButton(
            onPressed: () => _removeGuest(index),
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }
}