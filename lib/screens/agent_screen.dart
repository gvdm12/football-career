import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
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
    interests = TransferService.generateOffers(career);
  }

  void _upgradeAgent() {
    if (career.agentLevel >= 3) return;
    final cost = career.agentLevel == 1 ? 150 : 350;

    if (career.agentCredits < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.agentNotEnoughMoney)),
      );
      return;
    }

    setState(() {
      career = career.copyWith(
        agentCredits: career.agentCredits - cost,
        agentLevel: career.agentLevel + 1,
      );
      interests = TransferService.generateOffers(career);
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
    final isMax = level >= 3;
    final upgradeCost = level == 1 ? 150 : 350;

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
                  const Icon(Icons.handshake_rounded, color: Color(0xFF8BE07F), size: 38),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.agentLevel(level),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.agentDescription,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.agentBonus((level - 1) * 4),
                    style: const TextStyle(color: Color(0xFF8BE07F), fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isMax || career.money < upgradeCost ? null : _upgradeAgent,
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
                    style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.currentContract.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF8BE07F), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  _line(AppStrings.team, career.player.club),
                  _line(AppStrings.monthlyWage, '€${_money(career.monthlySalary)}'),
                  _line(AppStrings.contractRemaining, AppStrings.transferContractDuration(career.contractYears)),
                  _line(AppStrings.agentLevel(level), AppStrings.agentBonus((level - 1) * 4)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.interestedClubs.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF8BE07F), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.isEnglish
                        ? 'Preliminary interest based on your performances. Final offers may change during the transfer window.'
                        : 'Предварительный интерес клубов с учётом ваших выступлений. Окончательные предложения могут измениться в трансферное окно.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  if (interests.isEmpty)
                    Text(AppStrings.noInterestedClubs, style: const TextStyle(color: Colors.white70))
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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              Text(
                'OVR ${offer.club.strength}',
                style: const TextStyle(color: Color(0xFF8BE07F), fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.isEnglish ? offer.club.league.displayName : offer.club.league.countryName,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 9),
          _line(AppStrings.estimatedOffer, '€${_money(offer.salary)} / ${AppStrings.isEnglish ? 'month' : 'мес.'}'),
          _line(AppStrings.contractRemaining, AppStrings.transferContractDuration(offer.contractYears)),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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
