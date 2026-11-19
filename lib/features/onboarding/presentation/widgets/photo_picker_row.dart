import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/tokens.dart';

/// `.photo-area` — dashed panel with the round avatar and an UPLOAD button.
/// Picks the file only; the caller decides when to send it.
class PhotoPickerRow extends StatelessWidget {
  const PhotoPickerRow({
    super.key,
    required this.onPicked,
    this.file,
    this.busy = false,
  });

  final ValueChanged<String> onPicked;
  final File? file;
  final bool busy;

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      imageQuality: 85,
    );
    if (picked != null) onPicked(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(
          color: const Color(0xFFD8C8B8),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E3D5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: file == null
                ? const Icon(Icons.add, size: 25, color: HFColors.primary)
                : Image.file(file!, fit: BoxFit.cover, width: 62, height: 62),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Add your profile photo',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: HFColors.primary,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: busy ? null : _pick,
              borderRadius: BorderRadius.circular(9),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                child: busy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'UPLOAD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
