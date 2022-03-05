import 'package:flutter/cupertino.dart';

class PageTransition extends PageRouteBuilder {
  Widget child;
  Curve curve;
  PageTransition({required this.child, this.curve = Curves.ease})
      : super(
            pageBuilder: (context, animation, secondaryAnimation) => child,
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, ch) {
              animation = CurvedAnimation(parent: animation, curve: curve);
              return ScaleTransition(
                scale: animation,
                alignment: Alignment.center,
                child: ch,
              );
            });
}
