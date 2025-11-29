import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (_selectedIndex == 1) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: BubblePopGame(),
      );
    }

    if (_selectedIndex == 3) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: AntiGambleQuiz(),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(16),
      child: GeminiSupportChat(),
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
  int _bestPopped = 0;
  Size _areaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadBest();
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
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _spawnTimer?.cancel();
        _handleFinish();
      }
    });
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bestPopped = prefs.getInt('bubble_pop_best') ?? 0;
    });
  }

  Future<void> _handleFinish() async {
    await _updateBestIfNeeded();
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

  Future<void> _updateBestIfNeeded() async {
    if (_popped <= _bestPopped) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bestPopped = _popped;
    });
    await prefs.setInt('bubble_pop_best', _bestPopped);
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
                              const SizedBox(height: 4),
                              Text(
                                'Best: $_bestPopped',
                                style: const TextStyle(color: Colors.white70),
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
            Text('Best: $_bestPopped'),
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

class _QuizQuestion {
  const _QuizQuestion({
    required this.text,
    required this.isFact,
    required this.explanation,
  });

  final String text;
  final bool isFact;
  final String explanation;
}

class _AnsweredQuestion {
  const _AnsweredQuestion({
    required this.question,
    required this.userAnswerIsFact,
    required this.correct,
    required this.explanation,
  });

  final String question;
  final bool userAnswerIsFact;
  final bool correct;
  final String explanation;
}

class _ChatMessage {
  const _ChatMessage({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

class GeminiSupportChat extends StatefulWidget {
  const GeminiSupportChat({super.key});

  @override
  State<GeminiSupportChat> createState() => _GeminiSupportChatState();
}

class _GeminiSupportChatState extends State<GeminiSupportChat> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final GeminiPingService _gemini = GeminiPingService();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    if (!_gemini.hasKey) {
      setState(() {
        _error = 'Set GEMINI_API_KEY to enable chat.';
      });
      return;
    }

    setState(() {
      _error = null;
      _sending = true;
      _messages.add(_ChatMessage(fromUser: true, text: text));
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _gemini.supportChatReply(
        history: _messages,
        userMessage: text,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        if (reply == null || reply.isEmpty) {
          _error = 'Gemini did not respond. Try again.';
        } else {
          _messages.add(_ChatMessage(fromUser: false, text: reply));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Chat failed: $e';
      });
    } finally {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shield_moon_outlined, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              'AI Support',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (!_gemini.hasKey)
              Text(
                'No API key',
                style: TextStyle(color: Colors.red.shade700),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Chat with Gemini for tips to resist betting. Short, practical answers only.',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _gemini.hasKey
                          ? 'Ask about cravings, triggers, or safe ways to cope.'
                          : 'Set GEMINI_API_KEY to start the chat.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final align = msg.fromUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start;
                      final bubbleColor =
                          msg.fromUser ? Colors.teal.shade50 : Colors.grey.shade100;
                      final textColor =
                          msg.fromUser ? Colors.teal.shade900 : Colors.black87;
                      return Column(
                        crossAxisAlignment: align,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 420),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.04)),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 10),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                enabled: !_sending,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ask for a quick tip...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _sending ? null : _sendMessage,
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_sending ? 'Sending' : 'Send'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Not therapy; for quick coaching only.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}

class AntiGambleQuiz extends StatefulWidget {
  const AntiGambleQuiz({super.key});

  @override
  State<AntiGambleQuiz> createState() => _AntiGambleQuizState();
}

class _AntiGambleQuizState extends State<AntiGambleQuiz> {
  final Random _random = Random();
  final List<_QuizQuestion> _questionBank = const [
    _QuizQuestion(
      text: 'There is a betting system that guarantees long-term profit.',
      isFact: false,
      explanation: 'House edge and limits beat every “system” over time.',
    ),
    _QuizQuestion(
      text: 'Betting can be a reliable way to earn extra income.',
      isFact: false,
      explanation: 'The house edge means losses add up, not income.',
    ),
    _QuizQuestion(
      text: 'After a loss, the chance of winning goes up.',
      isFact: false,
      explanation:
          'Each spin/hand is independent. This is the Monte Carlo fallacy.',
    ),
    _QuizQuestion(
      text: 'Bookmakers always keep an edge built into the odds.',
      isFact: true,
      explanation: 'Margins are built into every price, ensuring the edge.',
    ),
    _QuizQuestion(
      text: 'Chasing losses with bigger bets usually digs the hole deeper.',
      isFact: true,
      explanation: 'Bigger stakes + same edge = faster losses and more stress.',
    ),
    _QuizQuestion(
      text: '“Near misses” are designed to keep you hooked.',
      isFact: true,
      explanation: 'Near-miss design exploits dopamine to encourage more play.',
    ),
    _QuizQuestion(
      text: 'Self-exclusion tools can help break betting habits.',
      isFact: true,
      explanation: 'Blocking apps/sites adds friction and helps protect you.',
    ),
  ];

  List<_QuizQuestion> _questions = const [];
  List<_AnsweredQuestion> _answers = const [];
  int _index = 0;
  int _correct = 0;
  String? _geminiFeedback;
  String? _geminiError;
  bool _requestingFeedback = false;
  String? _feedback;
  bool? _lastCorrect;
  final GeminiPingService _gemini = GeminiPingService();

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _questions = List<_QuizQuestion>.from(_questionBank)..shuffle(_random);
    _answers = [];
    _index = 0;
    _correct = 0;
    _geminiFeedback = null;
    _geminiError = null;
    _requestingFeedback = false;
    _feedback = null;
    _lastCorrect = null;
    setState(() {});
  }

  void _answer(bool guessFact) {
    if (_index >= _questions.length) return;
    final q = _questions[_index];
    final isCorrect = guessFact == q.isFact;
    setState(() {
      if (isCorrect) _correct++;
      _answers.add(_AnsweredQuestion(
        question: q.text,
        userAnswerIsFact: guessFact,
        correct: isCorrect,
        explanation: q.explanation,
      ));
      _feedback = isCorrect
          ? 'Correct: ${q.explanation}'
          : 'Myth busted: ${q.explanation}';
      _lastCorrect = isCorrect;
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finished = _index >= _questions.length;
    final remaining = finished ? 0 : _questions.length - _index;
    final question = finished ? null : _questions[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Myth or Fact?',
                style: Theme.of(context).textTheme.titleMedium),
            Text(finished ? 'Done' : '${_index + 1}/${_questions.length}'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          finished
              ? 'Quick myth-buster finished. Shuffle again for new order.'
              : 'Guess if each statement is a myth or a fact.',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: finished
                ? SingleChildScrollView(
                    child: _summary(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question!.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _answer(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Myth'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _answer(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Fact'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_feedback != null)
                        _feedbackBanner(
                          text: _feedback!,
                          correct: _lastCorrect ?? false,
                          remaining: remaining,
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _feedbackBanner({
    required String text,
    required bool correct,
    required int remaining,
  }) {
    final color = correct ? Colors.green : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.error_outline,
                  color: color),
              const SizedBox(width: 8),
              Text(
                correct ? 'Nice!' : 'Not quite.',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text('$remaining left'),
            ],
          ),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }

  Widget _summary() {
    final total = _questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.quiz_outlined, size: 64, color: Colors.teal),
        const SizedBox(height: 12),
        Text(
          'You got $_correct of $total.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Myths busted, facts learned.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.shuffle),
          label: const Text('Shuffle questions'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _geminiFeedbackSection(total),
        ),
      ],
    );
  }

  Widget _geminiFeedbackSection(int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Gemini feedback',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (_requestingFeedback)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Get a short, personalized note based on your quiz answers.',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: (!_gemini.hasKey || _requestingFeedback)
                    ? null
                    : _requestGeminiFeedback,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(_gemini.hasKey
                    ? 'Get feedback'
                    : 'Set GEMINI_API_KEY'),
              ),
              const SizedBox(width: 8),
              Text('Correct $_correct / $total'),
            ],
          ),
          if (!_gemini.hasKey)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Set GEMINI_API_KEY (e.g. --dart-define) to enable AI feedback.',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          if (_geminiFeedback != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _geminiFeedback!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          if (_geminiError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _geminiError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _requestGeminiFeedback() async {
    if (_answers.isEmpty) {
      setState(() {
        _geminiError = 'Finish the quiz first to get feedback.';
      });
      return;
    }

    setState(() {
      _requestingFeedback = true;
      _geminiFeedback = null;
      _geminiError = null;
    });

    try {
      final response = await _gemini.quizFeedback(
        answers: _answers,
        correct: _correct,
        total: _questions.length,
      );
      if (!mounted) return;
      setState(() {
        _requestingFeedback = false;
        if (response == null || response.isEmpty) {
          _geminiError = _gemini.hasKey
              ? 'Gemini did not respond. Try again.'
              : 'Gemini is not configured (GEMINI_API_KEY).';
        } else {
          _geminiFeedback = response;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _requestingFeedback = false;
        _geminiError = 'Gemini feedback failed: $e';
      });
    }
  }
}

class GeminiPingService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  bool get hasKey => _apiKey.isNotEmpty;

  final GenerativeModel? _model = _apiKey.isEmpty
      ? null
      : GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: _apiKey,
        );

  Future<String?> supportChatReply({
    required List<_ChatMessage> history,
    required String userMessage,
  }) async {
    if (_model == null) return null;
    final contents = <Content>[
      Content.text(
          'You are a supportive, concise coach helping someone resist gambling urges. Keep answers under 120 words, use simple actionable tips, and avoid triggering language. Only answer in ways that relate to gambling recovery; if asked about unrelated topics, politely steer back to managing betting urges and healthy coping.'),
    ];

    for (final msg in history) {
      contents.add(
        Content(msg.fromUser ? 'user' : 'model', [TextPart(msg.text)]),
      );
    }

    contents.add(Content('user', [TextPart(userMessage)]));

    final response = await _model.generateContent(contents);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  Future<String?> quizFeedback({
    required List<_AnsweredQuestion> answers,
    required int correct,
    required int total,
  }) async {
    if (_model == null) return null;
    final prompt = StringBuffer()
      ..writeln(
          'Act as a supportive coach. Write 3-5 sentences of feedback in English after a quiz about gambling risks.')
      ..writeln('Score: $correct out of $total correct.')
      ..writeln(
          'Include what went well, the key mistakes, and one concrete next step to strengthen resistance to gambling.')
      ..writeln('User answers (myth/fact):');
    for (final answer in answers) {
      final guessLabel = answer.userAnswerIsFact ? 'Fact' : 'Myth';
      final correctness = answer.correct ? 'correct' : 'incorrect';
      prompt.writeln(
        '- Question: ${answer.question}\n'
        '  Answer: $guessLabel ($correctness)\n'
        '  Explanation: ${answer.explanation}',
      );
    }

    final response =
        await _model.generateContent([Content.text(prompt.toString())]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
