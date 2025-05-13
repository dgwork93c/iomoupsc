import 'package:flutter/material.dart';

class ToastUtil {
  static void showCustomToast(BuildContext? context, String message) {
    final OverlayState overlayState = Overlay.of(context!);
    const Duration toastDuration = Duration(seconds: 2);
    const double toastHeight = 500;
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          bottom: toastHeight,
          left: 50,
          right: 50,
          child: AnimatedOpacity(
            duration: toastDuration,
            opacity: 1.0,
            onEnd: () {
              overlayEntry?.remove();
            },
            child: Center(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(20), // Apply a 20% border radius
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  color: Colors.grey,
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: 'Arial',
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Remove the toast after a delay
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry?.remove();
    });
  }
}
