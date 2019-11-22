import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as md;

typedef Widget TransitionsBuilder(Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child);

final duration = const Duration(milliseconds: 300);
final curve = Curves.linear;

class MRouter {
  static builder(Widget child, TransitionsBuilder transitionsBuilder) {
    return PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            child,
        transitionDuration: duration,
        transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) =>
            transitionsBuilder(animation, secondaryAnimation, child));
  }

  static materialPageRoute(Widget route) {
    md.MaterialPageRoute(builder: (BuildContext context) {
      return route;
    });
  }

  static PageRouteBuilder fadeIn(Widget route) {
    return builder(
        route,
        (animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child));
  }

  static PageRouteBuilder fadeInScaleLarge(Widget route) {
    return builder(
        route,
        (animation, secondaryAnimation, child) => FadeTransition(
              opacity: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.slowMiddle,
              )),
              child: new ScaleTransition(
                scale:
                    new Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                child: child,
              ),
            ));
  }

  static PageRouteBuilder left2Right(Widget route) {
    return builder(
      route,
      (animation, secondaryAnimation, child) => SlideTransition(
        transformHitTests: false,
        position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
            .animate(/*animation*/ CurvedAnimation(
                parent: animation, curve: Curves.fastOutSlowIn)),
        child: new SlideTransition(
          position: new Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0, 0.0),
          ).animate(secondaryAnimation),
          child: child,
        ),
      ),
    );
  }

  static PageRouteBuilder fedInLeft2Right(Widget route) {
    return builder(
      route,
      (animation, secondaryAnimation, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(secondaryAnimation),
            child: child,
          ),
        ),
      ),
    );
  }

  static PageRouteBuilder down2Up(Widget route) {
    return builder(
      route,
      (animation, secondaryAnimation, child) => SlideTransition(
        transformHitTests: false,
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: new SlideTransition(
          position: new Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0.0, -1.0),
          ).animate(secondaryAnimation),
          child: child,
        ),
      ),
    );
  }

  static PageRouteBuilder rotateRight2left(Widget route) {
    return builder(
      route,
      (animation, secondaryAnimation, child) => RotationTransition(
        turns: Tween(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
          child: child,
        ),
      ),
    );
  }
}
