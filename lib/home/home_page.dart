import 'dart:math';

import 'package:counter_app_ci_cd/animation/firework_painter.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  List<Shard>? _shards;

  late final AnimationController _celebration;
  late final AnimationController _voidCtrl;

  @override
  void initState() {
    super.initState();
    _celebration = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _voidCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _celebration.dispose();
    _voidCtrl.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    if (_counter >= 10) return;
    final next = _counter + 1;
    setState(() => _counter = next);
    if (next == 10) {
      _voidCtrl.reverse();
      _celebration.forward(from: 0);
    }
  }

  void _decrementCounter() {
    if (_counter <= 0) return;
    final next = _counter - 1;
    setState(() => _counter = next);
    if (next == 0) {
      _celebration
        ..stop()
        ..reset();
      _voidCtrl.forward(from: 0);
    } else {
      _voidCtrl.reverse();
    }
  }

  List<Shard> _burst(Size size) {
    final rnd = Random(10);
    final origin = Offset(size.width / 2, size.height * 0.42);
    return List.generate(64, (i) {
      final angle = rnd.nextDouble() * pi * 2;
      final speed = 180 + rnd.nextDouble() * 280;
      return Shard(
        origin: origin,
        velocity: Offset(cos(angle), sin(angle)) * speed,
        color: Colors.primaries[i % Colors.primaries.length],
        hueShift: 40 + rnd.nextDouble() * 80,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have pushed the button this many times:'),
                TweenAnimationBuilder<double>(
                  key: ValueKey(_counter),
                  tween: Tween(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_celebration, _voidCtrl]),
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      if (_shards == null && size.shortestSide > 0) {
                        _shards = _burst(size);
                      }
                      final voidT = Curves.easeInCubic.transform(
                        _voidCtrl.value,
                      );
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.15 * voidT),
                              Colors.black.withValues(alpha: 0.88 * voidT),
                            ],
                            stops: const [0.2, 1],
                          ),
                        ),
                        child: CustomPaint(
                          painter: FireworksPainter(
                            progress: _celebration.value,
                            shards: _shards ?? const [],
                          ),
                          size: size,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
