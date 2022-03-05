import 'package:flutter/cupertino.dart';

class PageSlideTransition extends PageRouteBuilder {
  Widget child;
  Curve curve;
  PageSlideTransition({required this.child, this.curve = Curves.ease})
      : super(
            pageBuilder: (context, animation, secondaryAnimation) => child,
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, ch) {
              animation = CurvedAnimation(parent: animation, curve: curve);
              Animation<Offset> custom =
                  Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                      .animate(animation);
              return SlideTransition(
                position: custom,
                child: child,
              );
            });
}
