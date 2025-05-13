import 'package:flutter/material.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final VoidCallback logout;

  const CustomAppBar({Key? key, required this.userId, required this.logout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.themeblue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Use the current context directly
        },
        color: Colors.white,
        iconSize: 18.0,
      ),
      title: Text(
        'IOMOU - $userId',
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Arial',
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            if (userId == 'guest') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => IconMain2(userId: userId)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => IconMain(userId: userId)),
              );
            }
          },
          color: Colors.white,
          iconSize: 18.0,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: logout,
          color: Colors.white,
          iconSize: 18.0,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
