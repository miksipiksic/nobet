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
  bool? _hasBettingAccounts;
  Map<String, String> _bettingAccounts = {}; // platform -> username
  bool? _goesToGym;
  bool? _drinksCoffee;
  bool? _knowsSpending;
  double? _monthlySpending;
  bool _spendingSubmitted = false;

  // Text controllers
  final TextEditingController _spendingController = TextEditingController();
  final Map<String, TextEditingController> _accountControllers = {};

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
    for (var controller in _accountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    // Reset spending submitted flag when leaving step 6
    if (_currentStep == 6) {
      _spendingSubmitted = false;
    }

    // Save monthly spending when moving from step 6
    if (_currentStep == 6 && _knowsSpending == true) {
      final text = _spendingController.text.trim();
      _monthlySpending = double.tryParse(text);
    }

    // Save betting accounts when leaving step 2
    if (_currentStep == 2 && _hasBettingAccounts == true) {
      for (var platform in _bettingAccounts.keys.toList()) {
        final controller = _accountControllers[platform];
        if (controller != null) {
          _bettingAccounts[platform] = controller.text.trim();
        }
      }
    }

    if (_currentStep < 6) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        if (_currentStep == 6) {
          _spendingSubmitted = false;
        }
        _currentStep--;
      });
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _frequency != null;
      case 1:
        return _gamesPlayed.isNotEmpty;
      case 2:
        return _hasBettingAccounts != null;
      case 3:
        // Skip gym question if not a gambler
        if (!_isGambler()) return true;
        return _goesToGym != null;
      case 4:
        // Skip coffee question if not a gambler
        if (!_isGambler()) return true;
        return _drinksCoffee != null;
      case 5:
        return _knowsSpending != null;
      case 6:
        if (_knowsSpending == false) return true;
        // Require Enter key to be pressed
        return _spendingSubmitted;
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
        return _buildBettingAccountsQuestion();
      case 3:
        if (!_isGambler()) {
          return _buildNonGamblerResult();
        }
        return _buildGymQuestion();
      case 4:
        return _buildCoffeeQuestion();
      case 5:
        return _buildSpendingKnowledgeQuestion();
      case 6:
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

  Widget _buildBettingAccountsQuestion() {
    final platforms = {
      'MaxBet': 'Popular betting platform in Bosnia',
      'Mozzart': 'International sports betting',
      'Meridian': 'Regional betting operator',
      'Soccer': 'Sports betting specialist',
      'Bet365': 'Global betting platform',
      'Favbet': 'Sports and casino betting',
      'Pinnacle': 'Professional betting site',
      'Other': 'Any other betting platform',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you have accounts on betting platforms?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RadioListTile<bool>(
          title: const Text('Yes'),
          value: true,
          groupValue: _hasBettingAccounts,
          onChanged: (value) => setState(() => _hasBettingAccounts = value),
        ),
        RadioListTile<bool>(
          title: const Text('No'),
          value: false,
          groupValue: _hasBettingAccounts,
          onChanged: (value) {
            setState(() {
              _hasBettingAccounts = value;
              _bettingAccounts.clear();
              for (var controller in _accountControllers.values) {
                controller.dispose();
              }
              _accountControllers.clear();
            });
          },
        ),
        if (_hasBettingAccounts == true) ...[
          const SizedBox(height: 20),
          const Text(
            'Select platforms you have accounts on:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...platforms.entries.map((entry) {
            final platform = entry.key;
            final description = entry.value;
            final isSelected = _bettingAccounts.containsKey(platform);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      platform,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      description,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _bettingAccounts[platform] = '';
                          _accountControllers[platform] =
                              TextEditingController();
                        } else {
                          _bettingAccounts.remove(platform);
                          _accountControllers[platform]?.dispose();
                          _accountControllers.remove(platform);
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          }),
          if (_bettingAccounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected ${_bettingAccounts.length} platform${_bettingAccounts.length > 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_bettingAccounts.length >= 3) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Having accounts on multiple platforms may increase gambling frequency',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your data is stored locally and never shared',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            hintText: 'Press Enter to continue',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            final amount = double.tryParse(value.trim());
            if (amount != null && amount > 0) {
              setState(() {
                _monthlySpending = amount;
                _spendingSubmitted = true;
              });
            }
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
                Text(
                    '• Yearly: ${(_monthlySpending! * 12).toStringAsFixed(0)} RSD'),
                Text(
                    '• In 5 years: ${(_monthlySpending! * 60).toStringAsFixed(0)} RSD'),
                const SizedBox(height: 8),
                const Text(
                  'With that money you could:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                    '• Buy a phone every ${(50000 / _monthlySpending!).toStringAsFixed(1)} months'),
                Text(
                    '• Pay for gym for ${(_monthlySpending! / 3000).toStringAsFixed(1)} months'),
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
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                _buildSummaryItem(
                  'Betting accounts',
                  _hasBettingAccounts == true
                      ? '${_bettingAccounts.length} platform${_bettingAccounts.length != 1 ? "s" : ""} (${_bettingAccounts.keys.join(", ")})'
                      : 'No',
                ),
                if (_isGambler()) ...[
                  _buildSummaryItem('Gym', _goesToGym == true ? 'Yes' : 'No'),
                  _buildSummaryItem(
                      'Coffee', _drinksCoffee == true ? 'Yes' : 'No'),
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
              ],
            ),
          ),
        ),
        SafeArea(
          child: SizedBox(
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
                await prefs.setBool(
                    'has_betting_accounts', _hasBettingAccounts ?? false);
                await prefs.setStringList(
                    'betting_platforms', _bettingAccounts.keys.toList());
                await prefs.setBool('knows_spending', _knowsSpending ?? false);
                await prefs.setDouble(
                    'monthly_spending', _monthlySpending ?? 0);

                widget.onCompleted?.call();
                setState(() {
                  _currentStep = 0;
                  _frequency = null;
                  _gamesPlayed = [];
                  _hasBettingAccounts = null;
                  _bettingAccounts = {};
                  for (var controller in _accountControllers.values) {
                    controller.dispose();
                  }
                  _accountControllers.clear();
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
        ),
      ],
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
    final isLastStep = _currentStep == 6;
    final isCompleted = isLastStep && _canProceed();

    if (isCompleted) {
      return _buildSummary();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / 7,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${_currentStep + 1} of 7',
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
                        ? () =>
                            setState(() {}) // Trigger rebuild to show summary
                        : _nextStep)
                    : null,
                icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                label: Text(isLastStep ? 'Next' : 'Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
