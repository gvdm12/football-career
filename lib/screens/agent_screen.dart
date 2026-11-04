import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/transfer_offer.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/transfer_service.dart';

class AgentScreen extends StatefulWidget {
  final Career career;

  const AgentScreen({super.key, required this.career});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  late Career career;
  late List<TransferOffer> interests;

  @override
  void initState() {
    super.initState();
    career = widget.career;
    interests = career.agentInterestedClubs.isNotEmpty
        ? TransferService.generateAgentOffersFromInterest(career)
        : TransferService.generateOffers(career);
    if (career.agentInterestedClubs.isEmpty) {
      career = career.copyWith(
        agentInterestedClubs: interests
            .map((offer) => offer.club.name)
            .toList(),
      );
    }
  }

  static const List<int> _upgradeCosts = [
    50,
    100,
    175,
    275,
    400,
    550,
    725,
    925,
    1150,
  ];

  void _upgradeAgent() {
    if (career.agentLevel >= 10) return;
    final cost = _upgradeCosts[career.agentLevel - 1];

    if (career.agentCredits < cost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.agentNotEnoughMoney)));
      return;
    }

    final upgradedCareer = career.copyWith(
      agentCredits: career.agentCredits - cost,
      agentLevel: career.agentLevel + 1,
    );
    // Повышение уровня улучшает условия предложений, но не меняет клубы,
    // которые агент уже нашёл для игрока.
    final updatedInterests =
        TransferService.generateAgentOffersFromInterest(upgradedCareer);

    setState(() {
      career = upgradedCareer;
      interests = updatedInterests;
    });
  }

  bool get _canTalk =>
      career.teamMatches - career.lastAgentNegotiationTeamMatch >= 7;

  Future<void> _talkToAgent() async {
    if (!_canTalk) return;
    final choice = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF14251B),
        title: const Text('Переговоры с агентом', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Обсудите следующий шаг в карьере. Агент может открыть новые варианты, но не гарантирует переход.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, 0), child: const Text('Найти новые предложения')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, 1), child: const Text('Связаться с бывшим клубом')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, 2), child: const Text('Обсудить зарплату и контракт')),
        ],
      ),
    );
    if (!mounted || choice == null) return;

    var updated = career;
    if (choice == 0) {
      final generated = TransferService.generateOffers(career)
          .where((offer) => offer.club.name != career.player.club)
          .take(2)
          .map((offer) => offer.club.name)
          .toList();
      updated = career.copyWith(
        agentInterestedClubs: {...career.agentInterestedClubs, ...generated}.toList(),
      );
    } else if (choice == 1) {
      final former = career.history
          .map((item) => item.club)
          .where((club) => club != career.player.club && club != 'Без клуба')
          .toSet()
          .toList()
        ..shuffle();
      if (former.isNotEmpty) {
        updated = career.copyWith(
          agentInterestedClubs: {...career.agentInterestedClubs, former.first}.toList(),
        );
      }
    } else {
      final remainingCareer = (21 - career.season).clamp(1, 20).toInt();
      final successChance = (0.35 + career.agentLevel * 0.045 +
              (career.averageRating ?? 6.0) * 0.015)
          .clamp(0.35, 0.85);
      if (career.contractYears <= 1 && Random().nextDouble() < successChance) {
        updated = career.copyWith(
          monthlySalary: (career.monthlySalary * 1.08).round(),
          contractYears: remainingCareer < 2 ? remainingCareer : 2,
        );
      }
    }

    updated = updated.copyWith(
      lastConversationMatch: career.matches,
      lastAgentNegotiationTeamMatch: career.teamMatches,
    );
    setState(() {
      career = updated;
      interests = TransferService.generateAgentOffersFromInterest(career);
    });
  }

  String _money(int amount) {
    final digits = amount.toString();
    final output = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) output.write(',');
      output.write(digits[i]);
    }
    return output.toString();
  }

  @override
  Widget build(BuildContext context) {
    final level = career.agentLevel;
    final isMax = level >= 10;
    final upgradeCost = isMax ? 0 : _upgradeCosts[level - 1];

    return PopScope<Career>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, career);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF07130F),
        appBar: AppBar(
          backgroundColor: const Color(0xAA18241F),
          foregroundColor: Colors.white,
          title: Text(AppStrings.agentProfileTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, career),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Icon(
                  //   Icons.handshake_rounded,
                  //   color: Color(0xFF8BE07F),
                  //   size: 30,
                  // ),
                  // const SizedBox(height: 10),
                  Text(
                    AppStrings.agentLevel(level),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Text(
                  //   AppStrings.agentDescription,
                  //   style: const TextStyle(
                  //     color: Colors.white70,
                  //     height: 1.2,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  Text(
                    AppStrings.agentBonus((level - 1) * 2),
                    style: const TextStyle(
                      color: Color(0xFF8BE07F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: isMax || career.agentCredits < upgradeCost
                          ? null
                          : _upgradeAgent,
                      child: Text(
                        isMax
                            ? AppStrings.agentMaxLevel
                            : '${AppStrings.upgradeAgent} · 🪙 ${_money(upgradeCost)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Text(
                  //   AppStrings.currencyRewardsHint,
                  //   style: const TextStyle(
                  //     color: Colors.white54,
                  //     fontSize: 11,
                  //     height: 1.35,
                  //   ),
                  // ),
                  // SizedBox(height: 2),
                  Text(
                    '${AppStrings.gameCurrency}: 🪙 ${_money(career.agentCredits)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _canTalk ? _talkToAgent : null,
                      icon: const Icon(Icons.handshake_outlined, size: 17),
                      label: Text(
                        _canTalk
                            ? (AppStrings.isEnglish
                                ? 'Talk to agent'
                                : 'Переговоры с агентом')
                            : (AppStrings.isEnglish
                                ? 'Next talk in ${(7 - (career.teamMatches - career.lastAgentNegotiationTeamMatch)).clamp(0, 7)} team matches'
                                : 'Новый разговор через ${(7 - (career.teamMatches - career.lastAgentNegotiationTeamMatch)).clamp(0, 7)} матчей команды'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.currentContract.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8BE07F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _line(AppStrings.team, career.player.club),
                  _line(
                    AppStrings.monthlyWage,
                    '€${_money(career.monthlySalary)}',
                  ),
                  _line(
                    AppStrings.contractRemaining,
                    AppStrings.transferContractDuration(career.contractYears),
                  ),
                  _line(
                    AppStrings.agentLevel(level),
                    AppStrings.agentBonus((level - 1) * 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.interestedClubs.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8BE07F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.isEnglish
                        ? 'Preliminary interest based on your performances.'
                        : 'Предварительный интерес клубов с учётом ваших выступлений.',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (interests.isEmpty)
                    Text(
                      AppStrings.noInterestedClubs,
                      style: const TextStyle(color: Colors.white70),
                    )
                  else
                    ...interests.map(_offerCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerCard(TransferOffer offer) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.19)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  offer.club.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                'OVR ${offer.club.strength}',
                style: const TextStyle(
                  color: Color(0xFF8BE07F),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.isEnglish
                ? offer.club.league.displayName
                : offer.club.league.countryName,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 5),
          _line(
            AppStrings.estimatedOffer,
            '€${_money(offer.salary)} / ${AppStrings.isEnglish ? 'month' : 'мес.'}',
          ),
          _line(
            AppStrings.contractLabel,
            AppStrings.transferContractDuration(offer.contractYears),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.13),
                Colors.white.withValues(alpha: 0.055),
                const Color(0xFF101B16).withValues(alpha: 0.42),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.24),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
