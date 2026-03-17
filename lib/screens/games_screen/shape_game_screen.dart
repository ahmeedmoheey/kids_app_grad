import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:kids_app_grad/utils/colors_manager.dart';

import '../../utils/routes_manager.dart';

class ShapeModel {
  final String id;
  final IconData icon;
  final Color color;
  bool isMatched;
  bool showCorrect;

  ShapeModel({
    required this.id,
    required this.icon,
    required this.color,
    this.isMatched = false,
    this.showCorrect = false,
  });
}

class ShapeGameScreen extends StatefulWidget {
  const ShapeGameScreen({super.key});

  @override
  State<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends State<ShapeGameScreen>
    with TickerProviderStateMixin {
  int level = 1;

  List<ShapeModel> shapes = [];
  List<ShapeModel> targets = [];

  // animations
  late AnimationController successController;
  late Animation<double> scaleAnim;

  late AnimationController confettiController;

  // shake animation for wrong
  late AnimationController wrongController;
  late Animation<double> wrongAnimation;

  @override
  void initState() {
    super.initState();

    successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    scaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: successController, curve: Curves.elasticOut),
    );

    confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // shake controller
    wrongController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    wrongAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: wrongController, curve: Curves.elasticIn),
    );

    generateLevel();
  }


  void generateLevel() {
    shapes.clear();
    targets.clear();

    List<ShapeModel> allShapes = [
      ShapeModel(id: "circle", icon: Icons.circle, color: Colors.pink),
      ShapeModel(id: "square", icon: Icons.crop_square, color: Colors.blue),
      ShapeModel(id: "triangle", icon: Icons.change_history, color: Colors.orange),
      ShapeModel(id: "pentagon", icon: Icons.pentagon, color: Colors.green),
    ];

    allShapes.shuffle();

    int number = min(1 + level, allShapes.length);

    shapes = allShapes.take(number).toList();
    targets = List.from(shapes)..shuffle();

    for (var t in targets) {
      t.isMatched = false;
      t.showCorrect = false;
    }

    setState(() {});
  }

  void checkMatch(ShapeModel dragged, ShapeModel target) {
    if (dragged.id == target.id) {
      successController.forward(from: 0);

      setState(() {
        target.showCorrect = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          target.isMatched = true;
          shapes.remove(dragged);
        });

        if (shapes.isEmpty) {
          confettiController.forward(from: 0);

          Future.delayed(const Duration(milliseconds: 900), () {
            level++;
            generateLevel();
          });
        }
      });
    } else {
      wrongController.forward(from: 0);
    }
  }

  // ===== UI BOX SHAPE =====
  Widget shapeBox(ShapeModel shape, {double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shape.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Icon(shape.icon, color: Colors.white, size: size * 0.55),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            GoRouter.of(context).push(RoutesManager.kHomeScreen);
          },
          child: const Icon(Icons.close, color: Colors.orange),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text('Shape Matcher',
                style: TextStyle(color: Colors.black, fontSize: 18)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffFFF1D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LEVEL $level',
                style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),

              /// 🎯 Targets (سيكشنز)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: targets.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final target = targets[index];

                    return DragTarget<ShapeModel>(
                      onAccept: (received) {
                        checkMatch(received, target);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: target.isMatched
                                ? Colors.green.withOpacity(.2)
                                : const Color(0xffEFE9DB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: target.showCorrect
                                  ? Colors.green
                                  : Colors.brown.shade200,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: target.isMatched
                                ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 40)
                                : ScaleTransition(
                              scale: target.showCorrect
                                  ? scaleAnim
                                  : kAlwaysCompleteAnimation,
                              child: Opacity(
                                opacity: 0.3,
                                child: shapeBox(target),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// 🎮 Draggable Shapes
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: shapes.map((shape) {
                    return AnimatedBuilder(
                      animation: wrongController,
                      builder: (context, child) {
                        double offset = 0;
                        if (wrongController.isAnimating) {
                          offset =
                              sin(wrongController.value * pi * 4) * 8; // shake
                        }
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: Draggable<ShapeModel>(
                        data: shape,
                        feedback: Material(
                          color: Colors.transparent,
                          child: shapeBox(shape, size: 75),
                        ),
                        childWhenDragging:
                        Opacity(opacity: 0.3, child: shapeBox(shape)),
                        child: shapeBox(shape),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // 🎉 CONFETTI
          AnimatedBuilder(
            animation: confettiController,
            builder: (context, child) {
              if (!confettiController.isAnimating) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: Opacity(
                  opacity: 1 - confettiController.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🎉 🎊 ⭐ 🎉',
                          style: TextStyle(fontSize: 50)),
                      SizedBox(height: 10),
                      Text('برافوووو 👏',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}