import 'package:flutter/material.dart';

class ThankModalHomeBlood extends StatelessWidget {
  final VoidCallback onClose;

  const ThankModalHomeBlood({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✔ Green checkmark icon
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4EDDA),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF28A745),
                size: 50,
              ),
            ),
            const SizedBox(height: 20),

            // "Appointment Completed!" heading
            const Text(
              "Appointment Completed!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // "Thank You for Your Support" in red italic
            const Text(
              "Thank You for Your Support",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC3545),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // "Now you can save 3 lives..." subtitle
            const Text(
              "Now you can save 3 lives together in one shot!",
              style: TextStyle(fontSize: 14, color: Color(0xFFDC3545)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Confirmation email message
            const Text(
              "A confirmation email has been sent to your registered email address. Please check.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // "Back Home" button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3545),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Back Home",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
