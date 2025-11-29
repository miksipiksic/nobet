import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double savedBySkipping = 245.50;
  final double earnedFromDiscounts = 82.30;
  final int streakDays = 9;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_pageTitle()),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {},
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: _buildBody(theme),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_rounded), label: 'Game'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat AI'),
          BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined), label: 'Mini Quiz'),
        ],
      ),
    );
  }

  String _pageTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Game';
      case 2:
        return 'Chat with AI';
      case 3:
        return 'Mini Quiz';
      default:
        return 'Nobet';
    }
  }

  Widget _buildBody(ThemeData theme) {
    if (_selectedIndex == 0) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'See how much you saved and what is next.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _overviewCard(),
            const SizedBox(height: 16),
            Text('Snapshot', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard(
                  label: 'Saved (no betting)',
                  value: _formatCurrency(savedBySkipping),
                  icon: Icons.block,
                  color: Colors.teal,
                ),
                _statCard(
                  label: 'Earned from discounts',
                  value: _formatCurrency(earnedFromDiscounts),
                  icon: Icons.local_offer_outlined,
                  color: Colors.orange,
                ),
                _statCard(
                  label: 'Streak',
                  value: '$streakDays days',
                  icon: Icons.whatshot_outlined,
                  color: Colors.pinkAccent,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _selectedIndex == 1
            ? const BubblePopGame()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedIndex == 2
                        ? Icons.chat_bubble_outline
                        : Icons.quiz_outlined,
                    size: 60,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedIndex == 2
                        ? 'Chat with AI placeholder.'
                        : 'Mini quiz placeholder.',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Connect this tab with your real screens or backend.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _overviewCard() {
    final total = savedBySkipping + earnedFromDiscounts;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total saved',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+${streakDays}d streak',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(total),
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _pill(text: 'No betting ${_formatCurrency(savedBySkipping)}'),
              const SizedBox(width: 8),
              _pill(text: 'Discounts ${_formatCurrency(earnedFromDiscounts)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} RSD';
  }
}

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _Bubble {
  _Bubble({required this.position, required this.size, required this.color});
  final Offset position;
  final double size;
  final Color color;
}

class _BubblePopGameState extends State<BubblePopGame> {
  final Random _random = Random();
  final List<_Bubble> _bubbles = [];
  Timer? _spawnTimer;
  Timer? _gameTimer;
  int _secondsLeft = 25;
  int _popped = 0;
  Size _areaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _bubbles.clear();
    _popped = 0;
    _secondsLeft = 25;

    _spawnTimer = Timer.periodic(
        const Duration(milliseconds: 700), (_) => _spawnBubble());
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _spawnTimer?.cancel();
      }
    });
  }

  void _spawnBubble() {
    if (_areaSize == Size.zero || _secondsLeft <= 0) return;
    final size = 40 + _random.nextDouble() * 40;
    final maxX = (_areaSize.width - size).clamp(0, double.infinity);
    final maxY = (_areaSize.height - size).clamp(0, double.infinity);
    final pos =
        Offset(_random.nextDouble() * maxX, _random.nextDouble() * maxY);
    final colorOptions = [
      Colors.teal,
      Colors.orange,
      Colors.pinkAccent,
      Colors.blueAccent
    ];
    setState(() {
      _bubbles.add(_Bubble(
        position: pos,
        size: size,
        color: colorOptions[_random.nextInt(colorOptions.length)],
      ));
      if (_bubbles.length > 12) {
        _bubbles.removeAt(0);
      }
    });
  }

  void _popBubble(int index) {
    if (_secondsLeft <= 0) return;
    setState(() {
      _bubbles.removeAt(index);
      _popped++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finished = _secondsLeft <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bubble Pop', style: Theme.of(context).textTheme.titleMedium),
            Text('$_secondsLeft s'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          finished
              ? 'Time is up. Are you still tempted?'
              : 'Tap bubbles to pop them. Ultra simple, feel-good dopamine.',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _areaSize = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onTap: () {},
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    ..._bubbles.asMap().entries.map((entry) {
                      final i = entry.key;
                      final b = entry.value;
                      return Positioned(
                        left: b.position.dx,
                        top: b.position.dy,
                        child: GestureDetector(
                          onTap: () => _popBubble(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: b.size,
                            height: b.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: b.color.withOpacity(0.7),
                              boxShadow: [
                                BoxShadow(
                                  color: b.color.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (finished)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Time is up!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Popped: $_popped',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Still tempted?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Restart'),
                                onPressed: _startGame,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popped: $_popped'),
            TextButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart'),
            ),
          ],
        ),
      ],
    );
  }
}
