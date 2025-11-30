import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamblerSurvey extends StatefulWidget {
  final VoidCallback? onCompleted;
  const GamblerSurvey({super.key, this.onCompleted});

  @override
  State<GamblerSurvey> createState() => _GamblerSurveyState();
}

class _GamblerSurveyState extends State<GamblerSurvey> {
  int _currentStep = 0;
  
  // Survey answers
  String? _frequency;
  List<String> _gamesPlayed = [];
  bool? _goesToGym;
  bool? _drinksCoffee;
  bool? _knowsSpending;
  double? _monthlySpending;
  
  // Text controller for spending amount
  final TextEditingController _spendingController = TextEditingController();
  
  final List<String> _availableGames = [
    'Slot machines',
    'Poker',
    'Blackjack',
    'Roulette',
    'Sports betting',
    'Online casino',
    'Other'
  ];

  bool _isGambler() {
    // User is considered a gambler if they visit frequently or play regularly
    if (_frequency == null) return false;
    
    final frequentGambling = [
      'Daily',
      'Several times a week',
      'Once a week',
      'Several times a month'
    ];
    
    return frequentGambling.contains(_frequency) && _gamesPlayed.isNotEmpty;
  }

  @override
  void dispose() {
    _spendingController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Save monthly spending when moving from step 5
    if (_currentStep == 5 && _knowsSpending == true) {
      final text = _spendingController.text.trim();
      _monthlySpending = double.tryParse(text);
    }
    
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _frequency != null;
      case 1:
        return _gamesPlayed.isNotEmpty;
      case 2:
        // Skip gym question if not a gambler
        if (!_isGambler()) return true;
        return _goesToGym != null;
      case 3:
        // Skip coffee question if not a gambler
        if (!_isGambler()) return true;
        return _drinksCoffee != null;
      case 4:
        return _knowsSpending != null;
      case 5:
        if (_knowsSpending == false) return true;
        // Check if there's valid text in the controller
        final text = _spendingController.text.trim();
        return text.isNotEmpty && double.tryParse(text) != null;
      default:
        return false;
    }
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildFrequencyQuestion();
      case 1:
        return _buildGamesQuestion();
      case 2:
        if (!_isGambler()) {
          return _buildNonGamblerResult();
        }
        return _buildGymQuestion();
      case 3:
        return _buildCoffeeQuestion();
      case 4:
        return _buildSpendingKnowledgeQuestion();
      case 5:
        return _buildSpendingAmountQuestion();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFrequencyQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How often do you visit a betting shop or casino?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...[
          'Daily',
          'Several times a week',
          'Once a week',
          'Several times a month',
          'Rarely (less than once a month)',
        ].map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _frequency,
              onChanged: (value) => setState(() => _frequency = value),
            )),
      ],
    );
  }

  Widget _buildGamesQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which games do you play most often? (You can select multiple)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ..._availableGames.map((game) => CheckboxListTile(
              title: Text(game),
              value: _gamesPlayed.contains(game),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _gamesPlayed.add(game);
                  } else {
                    _gamesPlayed.remove(game);
                  }
                });
              },
            )),
      ],
    );
  }

  Widget _buildGymQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you regularly visit the gym or exercise?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        RadioListTile<bool>(
          title: const Text('Yes'),
          value: true,
          groupValue: _goesToGym,
          onChanged: (value) => setState(() => _goesToGym = value),
        ),
        RadioListTile<bool>(
          title: const Text('No'),
          value: false,
          groupValue: _goesToGym,
          onChanged: (value) => setState(() => _goesToGym = value),
        ),
      ],
    );
  }

  Widget _buildCoffeeQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you regularly drink coffee?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        RadioListTile<bool>(
          title: const Text('Yes'),
          value: true,
          groupValue: _drinksCoffee,
          onChanged: (value) => setState(() => _drinksCoffee = value),
        ),
        RadioListTile<bool>(
          title: const Text('No'),
          value: false,
          groupValue: _drinksCoffee,
          onChanged: (value) => setState(() => _drinksCoffee = value),
        ),
      ],
    );
  }

  Widget _buildSpendingKnowledgeQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you know how much money you spend on gambling monthly?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        RadioListTile<bool>(
          title: const Text('Yes'),
          value: true,
          groupValue: _knowsSpending,
          onChanged: (value) => setState(() => _knowsSpending = value),
        ),
        RadioListTile<bool>(
          title: const Text('No'),
          value: false,
          groupValue: _knowsSpending,
          onChanged: (value) => setState(() => _knowsSpending = value),
        ),
      ],
    );
  }

  Widget _buildSpendingAmountQuestion() {
    if (_knowsSpending == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 60, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            'Tracking expenses is the first step to control!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'We recommend you start keeping track of your gambling expenses. This will help you understand how much you actually spend.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How much money do you spend on gambling monthly?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _spendingController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Amount (RSD)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
          onChanged: (value) {
            // Trigger rebuild to enable/disable Next button
            setState(() {});
          },
        ),
        if (_monthlySpending != null && _monthlySpending! > 0) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perspective:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('• Yearly: ${(_monthlySpending! * 12).toStringAsFixed(0)} RSD'),
                Text('• In 5 years: ${(_monthlySpending! * 60).toStringAsFixed(0)} RSD'),
                const SizedBox(height: 8),
                const Text(
                  'With that money you could:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('• Buy a phone every ${(50000 / _monthlySpending!).toStringAsFixed(1)} months'),
                Text('• Pay for gym for ${(_monthlySpending! / 3000).toStringAsFixed(1)} months'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNonGamblerResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.celebration, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          'Great news!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 16),
        const Text(
          'Based on your answers, you don\'t appear to have a gambling problem.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keep it that way:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('• Continue gambling responsibly'),
              const Text('• Set limits before you play'),
              const Text('• Never chase losses'),
              const Text('• Keep gambling as entertainment, not income'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'You can still use this app to track your habits and get support if needed.',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.analytics, size: 60, color: Colors.teal),
          const SizedBox(height: 20),
          const Text(
            'Thank you for your answers!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your answers:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem('Frequency', _frequency ?? 'N/A'),
          _buildSummaryItem('Games', _gamesPlayed.join(', ')),
          if (_isGambler()) ...[
            _buildSummaryItem('Gym', _goesToGym == true ? 'Yes' : 'No'),
            _buildSummaryItem('Coffee', _drinksCoffee == true ? 'Yes' : 'No'),
          ],
          _buildSummaryItem(
            'Knows spending',
            _knowsSpending == true ? 'Yes' : 'No',
          ),
          if (_knowsSpending == true && _monthlySpending != null)
            _buildSummaryItem(
              'Monthly spending',
              '${_monthlySpending!.toStringAsFixed(0)} RSD',
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (!_isGambler())
                  const Text('• Great! Keep gambling casual and set limits')
                else ...[
                  if (_goesToGym == false)
                    const Text('• Consider physical activity - proven to reduce gambling urges'),
                  if (_drinksCoffee == true)
                    const Text('• Limit caffeine - it can increase impulsive behavior'),
                  if (_knowsSpending == false)
                    const Text('• Start tracking your expenses - awareness is the first step'),
                  if (_monthlySpending != null && _monthlySpending! > 10000)
                    const Text('• Your monthly expenses are significant - consider setting limits'),
                  const Text('• Use the app regularly for support'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Save monthly spending from text field if user knows spending
                if (_knowsSpending == true) {
                  final text = _spendingController.text.trim();
                  _monthlySpending = double.tryParse(text) ?? 0;
                }
                
                // Save survey results
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_gambler', _isGambler());
                // Save all survey data
                await prefs.setBool('goes_to_gym', _goesToGym ?? false);
                await prefs.setBool('drinks_coffee', _drinksCoffee ?? false);
                await prefs.setString('frequency', _frequency ?? '');
                await prefs.setStringList('games_played', _gamesPlayed);
                await prefs.setBool('knows_spending', _knowsSpending ?? false);
                await prefs.setDouble('monthly_spending', _monthlySpending ?? 0);
                
                widget.onCompleted?.call();
                setState(() {
                  _currentStep = 0;
                  _frequency = null;
                  _gamesPlayed = [];
                  _goesToGym = null;
                  _drinksCoffee = null;
                  _knowsSpending = null;
                  _monthlySpending = null;
                  _spendingController.clear();
                });
              },
              child: const Text('Finish Survey'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == 5;
    final isCompleted = isLastStep && _canProceed();

    if (isCompleted) {
      return _buildSummary();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / 6,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${_currentStep + 1} of 6',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: _buildStep(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canProceed()
                    ? (isLastStep
                        ? () => setState(() {}) // Trigger rebuild to show summary
                        : _nextStep)
                    : null,
                icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                label: Text(isLastStep ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
