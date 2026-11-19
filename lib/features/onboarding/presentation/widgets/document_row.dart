import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../profile/domain/instructor_profile.dart';

/// One row of the document list: name, state, and its action.
class DocumentRow extends StatelessWidget {
  const DocumentRow({
    super.key,
    required this.label,
    required this.document,
    required this.busy,
    required this.onUpload,
    required this.onDelete,
  });

  final String label;
  final InstructorDocument? document;
  final bool busy;
  final VoidCallback onUpload;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final uploaded = document != null;
    final verified = document?.verified ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: uploaded ? HFColors.primary : const Color(0xFFE8DCCF),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              verified
                  ? Icons.verified_rounded
                  : uploaded
                  ? Icons.description_rounded
                  : Icons.upload_file_rounded,
              size: 20,
              color: uploaded ? HFColors.primary : const Color(0xFF9A8C7E),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    verified
                        ? 'Verified'
                        : uploaded
                        ? 'Awaiting verification'
                        : 'Not uploaded',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF75695E),
                    ),
                  ),
                ],
              ),
            ),
            if (busy)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              if (onDelete != null && !verified)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: const Color(0xFF9A8C7E),
                ),
              TextButton(
                onPressed: onUpload,
                child: Text(
                  uploaded ? 'REPLACE' : 'UPLOAD',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: HFColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
