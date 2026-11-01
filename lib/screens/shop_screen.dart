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

  int get _trainingPrice {
    final value = _skillValue(career.player.skills, selectedSkill);
    return 20000 + value * 250;
  }

  int get _recoveryPrice => 25000;

  Future<void> _buyTraining() async {
    if (career.money < _trainingPrice) return;

    final boosts = Map<String, int>.from(career.temporarySkillBoosts);
    final durations = Map<String, int>.from(career.temporarySkillBoostMatches);
    boosts[selectedSkill.name] = 5;
    durations[selectedSkill.name] = 3;

    setState(() {
      career = career.copyWith(
        money: career.money - _trainingPrice,
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
    if (!career.isInjured || career.money < _recoveryPrice) return;

    final remaining = (career.injuryMatchesRemaining - 2)
        .clamp(0, 10)
        .toInt();

    setState(() {
      career = career.copyWith(
        money: career.money - _recoveryPrice,
        injuryMatchesRemaining: remaining,
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
    final selectedValue = _skillValue(career.player.skills, selectedSkill);
    final canTrain = career.money >= _trainingPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF061B0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text('Магазин карьеры'),
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
          padding: const EdgeInsets.all(16),
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
                  const Icon(Icons.account_balance_wallet,
                      color: Color(0xFF8BE07F), size: 28),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _sectionTitle('ТРЕНИРОВКИ'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.fitness_center,
                          color: Color(0xFF8BE07F), size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Индивидуальная тренировка',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Повышает выбранную характеристику на +5 на следующие 3 матча. Базовые навыки и общий рейтинг не меняются.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<SkillName>(
                    value: selectedSkill,
                    dropdownColor: const Color(0xFF12351B),
                    decoration: InputDecoration(
                      labelText: 'Характеристика',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF3E9950)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF8BE07F)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: SkillName.values.map((skill) {
                      return DropdownMenuItem(
                        value: skill,
                        child: Text(
                          '${_skillName(skill)} · ${_skillValue(career.player.skills, skill)}/99'
                          '${career.temporarySkillBoostMatches[skill.name] != null ? '  (+5 · ${career.temporarySkillBoostMatches[skill.name]} мат.)' : ''}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedSkill = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Стоимость',
                          style: TextStyle(color: Colors.white70),
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
                  const SizedBox(height: 12),
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
                        career.money < _trainingPrice
                            ? 'Недостаточно денег'
                            : 'Купить бустер +5 на 3 матча',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('ВОССТАНОВЛЕНИЕ'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.healing, color: Color(0xFFFF9999), size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ускоренное лечение',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    career.isInjured
                        ? 'Травма: ${career.injuryName ?? 'повреждение'}. Осталось пропустить матчей: ${career.injuryMatchesRemaining}.'
                        : 'Сейчас вы здоровы. Лечение станет доступно при получении травмы.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: career.isInjured && career.money >= _recoveryPrice
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
                            : career.money < _recoveryPrice
                                ? 'Недостаточно денег'
                                : 'Сократить травму на 2 матча',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Покупки оплачиваются из обычного баланса игрока. Монеты агента не используются.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
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
