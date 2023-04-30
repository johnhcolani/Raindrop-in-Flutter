import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rain Animation Demo',
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.blue,
            ),
            RainContainer(),
          ],
        ),
      ),
    );
  }
}

class RainContainer extends StatefulWidget {
  @override
  _RainContainerState createState() => _RainContainerState();
}

class _RainContainerState extends State<RainContainer> {
  final GlobalKey _containerKey = GlobalKey();
  final List<Raindrop> raindrops = [];
  bool isBouncing = false;
  Offset getPosition(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  @override
  void initState() {
    super.initState();
    // start a timer to add new raindrops to the list
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // add a new raindrop to the list
        raindrops.add(Raindrop(
          x: Random().nextDouble() * MediaQuery.of(context).size.width,
          y: 0,
          speed: Random().nextInt(5) + 5,
          size: Random().nextInt(5) + 5,
        ));
        // remove any raindrops that have fallen off the screen
        raindrops.removeWhere((raindrop) => raindrop.y > MediaQuery.of(context).size.height);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: _containerKey,
          width: MediaQuery.of(context).size.width,
          height: 300,
          color: Colors.grey[400],
          // add a gesture detector to handle taps on the container
          child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              // check if a raindrop was tapped
              raindrops.forEach((raindrop) {
                var containerPosition = getPosition(_containerKey);
                if (details.localPosition.dx >= raindrop.x - raindrop.size / 2 &&
                    details.localPosition.dx <= raindrop.x + raindrop.size / 2 &&
                    details.localPosition.dy >= raindrop.y + containerPosition.dy - raindrop.size / 2 &&
                    details.localPosition.dy <= raindrop.y + containerPosition.dy + raindrop.size / 2) {
                  // reduce the speed and bounce the raindrop upwards
                  raindrop.speed = -raindrop.speed / 2;
                  raindrop.y -= raindrop.size * 2;
                }
              });
            },
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: RainPainter(raindrops: raindrops, containerKey: _containerKey),
            size: MediaQuery.of(context).size,
          ),
        ),
      ],
    );
  }
}




// class RainPainter extends CustomPainter {
//   List<Raindrop> raindrops;
//   GlobalKey containerKey;
//
//   RainPainter({required this.raindrops, required this.containerKey});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     var containerPosition = getPosition(containerKey);
//
//     for (var raindrop in raindrops) {
//       // check if the raindrop has hit the container
//       if (raindrop.y + containerPosition.dy + 20 + raindrop.size >=
//           size.height) {
//         raindrop.y = size.height - containerPosition.dy - 20 - raindrop.size;
//         raindrop.speed = 0;
//       }
//
//       // draw the raindrop
//       var path = Path();
//       path.moveTo(raindrop.x, raindrop.y + containerPosition.dy);
//       path.cubicTo(
//         raindrop.x - 10,
//         raindrop.y + 20 + containerPosition.dy,
//         raindrop.x + 10,
//         raindrop.y + 20 + containerPosition.dy,
//         raindrop.x,
//         raindrop.y + containerPosition.dy,
//       );
//       canvas.drawPath(path, paint);
//
//       // update the position of the raindrop for the next frame
//       if (raindrop.speed != 0) {
//         raindrop.y += raindrop.speed;
//         raindrop.x += sin(raindrop.y / 20) * 2;
//       }
//
//       // randomly change the size and speed of the raindrop
//       if (Random().nextInt(20) == 0) {
//         raindrop.size += Random().nextDouble() * 2 - 1;
//         raindrop.size = max(raindrop.size, 1);
//         raindrop.speed += Random().nextDouble() * 2 - 1;
//         raindrop.speed = max(raindrop.speed, 1);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
//
//   // gets the position of the container on the screen
//   Offset getPosition(GlobalKey key) {
//     RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
//     return renderBox.localToGlobal(Offset.zero);
//   }
// }
// class RainPainter extends CustomPainter {
//   List<Raindrop> raindrops;
//   GlobalKey containerKey;
//
//   RainPainter({required this.raindrops, required this.containerKey});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     var containerPosition = getPosition(containerKey);
//     var containerBottom = containerPosition.dy + size.height;
//
//     for (var raindrop in raindrops) {
//       // check if the raindrop has hit the container
//       if (raindrop.y + raindrop.size >= containerBottom) {
//         // raindrop has hit the container
//         raindrops.remove(raindrop);
//       }
//
//       // draw the raindrop
//       var path = Path();
//       path.moveTo(raindrop.x, raindrop.y);
//       path.cubicTo(
//         raindrop.x - 10,
//         raindrop.y + 20,
//         raindrop.x + 10,
//         raindrop.y + 20,
//         raindrop.x,
//         raindrop.y,
//       );
//       canvas.drawPath(path, paint);
//
//       // update the position of the raindrop for the next frame
//       raindrop.y += raindrop.speed;
//       raindrop.x += sin(raindrop.y / 20) * 2;
//
//       // randomly change the size and speed of the raindrop
//       if (Random().nextInt(20) == 0) {
//         raindrop.size += Random().nextDouble() * 2 - 1;
//         raindrop.size = max(raindrop.size, 1);
//         raindrop.speed += Random().nextDouble() * 2 - 1;
//         raindrop.speed = max(raindrop.speed, 1);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
//
//   // gets the position of the container on the screen
//   Offset getPosition(GlobalKey key) {
//     RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
//     return renderBox.localToGlobal(Offset.zero);
//   }
// }
// class RainPainter extends CustomPainter {
//   List<Raindrop> raindrops;
//   GlobalKey containerKey;
//
//   RainPainter({required this.raindrops, required this.containerKey});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     var containerPosition = getPosition(containerKey);
//
//     for (var raindrop in raindrops) {
//       // check if the raindrop has hit the container
//       if (raindrop.y + containerPosition.dy + 20 + raindrop.size >=
//           size.height) {
//         // make the raindrop bounce off the container
//         raindrop.direction = -1 * raindrop.direction;
//         raindrop.y = size.height - containerPosition.dy - 20 - raindrop.size;
//         raindrop.speed *= raindrop.direction;
//       }
//
//       // draw the raindrop
//       var path = Path();
//       path.moveTo(raindrop.x, raindrop.y + containerPosition.dy);
//       path.cubicTo(
//         raindrop.x - 10,
//         raindrop.y + 20 + containerPosition.dy,
//         raindrop.x + 10,
//         raindrop.y + 20 + containerPosition.dy,
//         raindrop.x,
//         raindrop.y + containerPosition.dy,
//       );
//       canvas.drawPath(path, paint);
//
//       // update the position of the raindrop for the next frame
//       if (raindrop.speed != 0) {
//         raindrop.y += raindrop.speed * raindrop.direction;
//         raindrop.x += sin(raindrop.y / 20) * 2;
//       }
//
//       // randomly change the size and speed of the raindrop
//       if (Random().nextInt(20) == 0) {
//         raindrop.size += Random().nextDouble() * 2 - 1;
//         raindrop.size = max(raindrop.size, 1);
//         raindrop.speed += Random().nextDouble() * 2 - 1;
//         raindrop.speed = max(raindrop.speed, 1);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
//
//   // gets the position of the container on the screen
//   Offset getPosition(GlobalKey key) {
//     RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
//     return renderBox.localToGlobal(Offset.zero);
//   }
// }
class RainPainter extends CustomPainter {
  List<Raindrop> raindrops;
  GlobalKey containerKey;

  RainPainter({required this.raindrops, required this.containerKey});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var containerPosition = getPosition(containerKey);

    for (var raindrop in raindrops) {
      // check if the raindrop has hit the container
      if (raindrop.y + containerPosition.dy + 20 + raindrop.size >=
          size.height) {
        raindrop.y = size.height - containerPosition.dy - 20 - raindrop.size;
        raindrop.speed /= -2; // make the raindrop bounce back up
        raindrop.isBouncing = true;
      }

      // draw the raindrop
      var path = Path();
      path.moveTo(raindrop.x, raindrop.y + containerPosition.dy);
      path.cubicTo(
        raindrop.x - 10,
        raindrop.y + 20 + containerPosition.dy,
        raindrop.x + 10,
        raindrop.y + 20 + containerPosition.dy,
        raindrop.x,
        raindrop.y + containerPosition.dy,
      );
      canvas.drawPath(path, paint);

      // update the position of the raindrop for the next frame
      if (raindrop.speed != 0) {
        raindrop.y += raindrop.speed;
        raindrop.x += sin(raindrop.y / 20) * 2;
      }

      // randomly change the size and speed of the raindrop
      if (Random().nextInt(20) == 0) {
        raindrop.size += Random().nextDouble() * 2 - 1;
        raindrop.size = max(raindrop.size, 1);
        raindrop.speed += Random().nextDouble() * 2 - 1;
        raindrop.speed = max(raindrop.speed, 1);
      }

      // remove the raindrop if it has fallen off the screen or finished bouncing
      if (raindrop.y > size.height || (raindrop.isBouncing && raindrop.speed <= 1)) {
        raindrops.remove(raindrop);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  // gets the position of the container on the screen
  Offset getPosition(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }
}


class Raindrop {
  double x;
  double y;
  double speed;
  double size;
  int direction; // added field to keep track of direction

  Raindrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    this.direction = 1, // default direction is down
  });

  bool get isBouncing => false;

  set isBouncing(bool isBouncing) {}
}
