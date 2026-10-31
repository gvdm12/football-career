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

    setState(() {
      career = career.copyWith(
        agentCredits: career.agentCredits - cost,
        agentLevel: career.agentLevel + 1,
      );
      interests = TransferService.generateOffers(career);
      career = career.copyWith(
        agentInterestedClubs: interests
            .map((offer) => offer.club.name)
            .toList(),
      );
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
        backgroundColor: const Color(0xFF04160A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B3A1A),
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
                  Text(
                    AppStrings.agentDescription,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.agentBonus((level - 1) * 2),
                    style: const TextStyle(
                      color: Color(0xFF8BE07F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
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
                  Text(
                    '${AppStrings.gameCurrency}: 🪙 ${_money(career.agentCredits)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.currencyRewardsHint,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 7),
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
      margin: const EdgeInsets.only(top: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12371C),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF285D32)),
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
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                'OVR ${offer.club.strength}',
                style: const TextStyle(
                  color: Color(0xFF8BE07F),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.isEnglish
                ? offer.club.league.displayName
                : offer.club.league.countryName,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2B14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF24552C)),
      ),
      child: child,
    );
  }
}
