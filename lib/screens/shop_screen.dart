import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/services/career_storage.dart';

class ShopScreen extends StatefulWidget {
  final Career career;

  const ShopScreen({super.key, required this.career});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Career career;
  SkillName selectedSkill = SkillName.shooting;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    career = widget.career;
    selectedSkill = _defaultSkill(career.player.position);
  }

  SkillName _defaultSkill(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return SkillName.defending;
      case PlayerPosition.defender:
        return SkillName.defending;
      case PlayerPosition.midfielder:
        return SkillName.passing;
      case PlayerPosition.forward:
        return SkillName.shooting;
    }
  }

  String _skillName(SkillName skill) {
    switch (skill) {
      case SkillName.pace:
        return 'Скорость';
      case SkillName.physical:
        return 'Физическая форма';
      case SkillName.shooting:
        return 'Удар';
      case SkillName.passing:
        return 'Пас';
      case SkillName.dribbling:
        return 'Дриблинг';
      case SkillName.defending:
        return 'Защита';
      case SkillName.heading:
        return 'Игра головой';
      case SkillName.vision:
        return 'Видение поля';
    }
  }

  int _skillValue(PlayerSkills skills, SkillName skill) {
    return skills.getSkill(skill);
  }

  int get _trainingBasePrice {
    final value = _skillValue(career.player.skills, selectedSkill);
    return 20000 + value * 250;
  }

  int get _trainingPurchaseCount =>
      career.skillTrainingPurchases[selectedSkill.name] ?? 0;

  int get _trainingPrice =>
      (_trainingBasePrice * (100 + _trainingPurchaseCount * 50) / 100).round();

  bool get _trainingActive =>
      (career.temporarySkillBoostMatches[selectedSkill.name] ?? 0) > 0;

  int get _recoveryPrice => 25000;

  void _closeShop() {
    if (_allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop<Career>(career);
    });
  }

  Future<void> _buyTraining() async {
    if (_trainingActive || career.money < _trainingPrice) return;

    final purchases = Map<String, int>.from(career.skillTrainingPurchases);
    purchases[selectedSkill.name] = _trainingPurchaseCount + 1;
    final boosts = Map<String, int>.from(career.temporarySkillBoosts);
    final durations = Map<String, int>.from(career.temporarySkillBoostMatches);
    boosts[selectedSkill.name] = 5;
    durations[selectedSkill.name] = 3;

    setState(() {
      career = career.copyWith(
        money: career.money - _trainingPrice,
        skillTrainingPurchases: purchases,
        temporarySkillBoosts: boosts,
        temporarySkillBoostMatches: durations,
      );
    });

    await CareerStorage.save(career);
    _showMessage(
      'Тренировка куплена: ${_skillName(selectedSkill)} +5 на 3 матча',
    );
  }

  Future<void> _buyRecovery() async {
    if (!career.isInjured ||
        career.injuryRecoveryUsed ||
        career.money < _recoveryPrice) {
      return;
    }

    final remaining = (career.injuryMatchesRemaining - 2).clamp(0, 10).toInt();

    setState(() {
      career = career.copyWith(
        money: career.money - _recoveryPrice,
        injuryMatchesRemaining: remaining,
        injuryRecoveryUsed: true,
        clearInjury: remaining == 0,
      );
    });

    await CareerStorage.save(career);
    _showMessage(
      remaining == 0
          ? 'Вы полностью восстановились!'
          : 'Восстановление ускорено. Осталось матчей: $remaining',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF14532D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canTrain = !_trainingActive && career.money >= _trainingPrice;

    return PopScope<Career>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeShop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF061B0C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B3A1A),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeShop,
          ),
          title: const Text('Магазин'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B3A1A), Color(0xFF082A12), Color(0xFF04160A)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF102D18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3E9950)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF8BE07F),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Деньги игрока',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${career.money} €',
                      style: const TextStyle(
                        color: Color(0xFF8BE07F),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionTitle('ТРЕНИРОВКИ'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Color(0xFF8BE07F),
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Индивидуальная тренировка',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Повышает выбранную характеристику на +5 на следующие 3 матча. Пока бустер активен, повторная покупка недоступна. После окончания можно купить снова, но цена вырастет на 50% за каждую предыдущую покупку этого навыка.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<SkillName>(
                      initialValue: selectedSkill,
                      dropdownColor: const Color(0xFF12351B),
                      decoration: InputDecoration(
                        labelText: 'Характеристика',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3E9950),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF8BE07F),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: SkillName.values.map((skill) {
                        return DropdownMenuItem(
                          value: skill,
                          child: Text(
                            '${_skillName(skill)} · ${_skillValue(career.player.skills, skill)}/99'
                            '${(career.temporarySkillBoostMatches[skill.name] ?? 0) > 0 ? '  (+5 · ${career.temporarySkillBoostMatches[skill.name]} мат.)' : ''}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => selectedSkill = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Стоимость · покупка №${_trainingPurchaseCount + 1}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        Text(
                          '$_trainingPrice €',
                          style: const TextStyle(
                            color: Color(0xFF8BE07F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canTrain ? _buyTraining : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BE07F),
                          foregroundColor: const Color(0xFF082A12),
                          disabledBackgroundColor: Colors.white12,
                          disabledForegroundColor: Colors.white38,
                        ),
                        child: Text(
                          _trainingActive
                              ? 'Бустер уже активен'
                              : career.money < _trainingPrice
                              ? 'Недостаточно денег'
                              : 'Купить бустер +5 на 3 матча',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionTitle('ВОССТАНОВЛЕНИЕ'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.healing, color: Color(0xFFFF9999), size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ускоренное лечение',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      career.isInjured
                          ? 'Травма: ${career.injuryName ?? 'повреждение'}. Осталось пропустить матчей: ${career.injuryMatchesRemaining}. ${career.injuryRecoveryUsed ? 'Лечение уже использовано для этой травмы.' : 'Можно воспользоваться лечением один раз.'}'
                          : 'Сейчас вы здоровы. Лечение станет доступно при получении травмы.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Стоимость лечения',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Text(
                          '$_recoveryPrice €',
                          style: TextStyle(
                            color: Color(0xFF8BE07F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            career.isInjured &&
                                !career.injuryRecoveryUsed &&
                                career.money >= _recoveryPrice
                            ? _buyRecovery
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BE07F),
                          foregroundColor: const Color(0xFF082A12),
                          disabledBackgroundColor: Colors.white12,
                          disabledForegroundColor: Colors.white38,
                        ),
                        child: Text(
                          !career.isInjured
                              ? 'Лечение не требуется'
                              : career.injuryRecoveryUsed
                              ? 'Уже использовано для этой травмы'
                              : career.money < _recoveryPrice
                              ? 'Недостаточно денег'
                              : 'Сократить травму на 2 матча',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8BE07F),
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          fontSize: 12,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0A2110),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF24552C)),
    );
  }
}
