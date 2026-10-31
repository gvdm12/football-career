import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/transfer_offer.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/transfer_service.dart';

class TransferScreen extends StatefulWidget {
  final Career career;

  const TransferScreen({super.key, required this.career});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late Career career;
  late List<TransferOffer> offers;
  TransferOffer? renewalOffer;

  @override
  void initState() {
    super.initState();

    career = widget.career;
    _generateTransferOffers();
  }

  void _generateTransferOffers() {
    offers = TransferService.generateOffers(career);
    renewalOffer = TransferService.generateRenewalOffer(career);
  }

  void _acceptTransfer(TransferOffer offer) {
    final newCareer = career.acceptTransfer(offer);
    Navigator.pop(context, newCareer);
  }

  void _rejectAll() {
    // Нельзя остаться в клубе, если контракт истёк.
    if (career.contractYears <= 0) return;

    Navigator.pop(context, career);
  }

  void _upgradeAgent() {
    if (career.agentLevel >= 3) return;
    final cost = career.agentLevel == 1 ? 15000 : 35000;
    if (career.money < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.agentNotEnoughMoney)),
      );
      return;
    }

    setState(() {
      career = career.copyWith(
        money: career.money - cost,
        agentLevel: career.agentLevel + 1,
      );
      _generateTransferOffers();
    });
  }

  Widget _buildAgentCard() {
    final level = career.agentLevel;
    final cost = level == 1 ? 15000 : 35000;
    final isMax = level >= 3;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF102B17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF397B43)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.agent,
            style: const TextStyle(
              color: Color(0xFF8BE07F),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.agentLevel(level),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.agentBonus((level - 1) * 4),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isMax || career.money < cost ? null : _upgradeAgent,
              child: Text(
                isMax
                    ? AppStrings.agentMaxLevel
                    : '${AppStrings.upgradeAgent} · €${_formatMoney(cost)}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _contractDuration(int years) {
    return AppStrings.transferContractDuration(years);
  }

  String _leagueLabel(TransferOffer offer) {
    return AppStrings.isEnglish
        ? offer.club.league.displayName
        : offer.club.league.countryName;
  }

  String _formatMoney(int amount) {
    final digits = amount.toString();
    final result = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(digits[i]);
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hasContract = career.contractYears > 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            AppStrings.transferTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 2,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),

                const SizedBox(height: 10),

                _buildAgentCard(),

                const SizedBox(height: 10),

                if (renewalOffer != null) ...[
                  _buildRenewalCard(renewalOffer!),
                  const SizedBox(height: 10),
                ],

                Text(
                  AppStrings.otherClubOffers,
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 10),

                if (offers.isEmpty) ...[
                  _buildNoOffers(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _generateTransferOffers();
                        });
                      },
                      child: Text(
                        AppStrings.refreshOffers,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ] else
                  ...offers.map(
                    (offer) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOfferCard(offer),
                    ),
                  ),

                const SizedBox(height: 2),

                if (hasContract)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _rejectAll,
                      child: Text(
                        AppStrings.stayAtCurrentClub,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                if (!hasContract) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.expiredContractMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRenewalCard(TransferOffer offer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3C884A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.renewalContract,
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  offer.club.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _leagueLabel(offer),
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.newContract}: '
                  '${_contractDuration(offer.contractYears)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.salaryPerMonth}: '
                  '€${_formatMoney(offer.salary)} / '
                  '${AppStrings.isEnglish ? 'month' : 'месяц'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          SizedBox(
            width: 80,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _acceptTransfer(offer),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.isEnglish ? 'Accept' : 'Принять',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.transferWindow,
            style: const TextStyle(
              color: Color(0xFF3C884A),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${AppStrings.currentClubLabel}: ${career.player.club}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            '${AppStrings.overallLabel}: ${career.player.overall}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          Text(
            '${AppStrings.contractRemaining}: '
            '${_contractDuration(career.contractYears)}',
            style: TextStyle(
              color: career.contractYears <= 0
                  ? Colors.orangeAccent
                  : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(TransferOffer offer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Информация о клубе
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.club.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _leagueLabel(offer),
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.clubStrengthLabel}: ${offer.club.strength}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.salaryPerMonth}: '
                  '€${_formatMoney(offer.salary)} / '
                  '${AppStrings.isEnglish ? 'month' : 'месяц'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.contractLabel}: '
                  '${_contractDuration(offer.contractYears)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Кнопка справа
          SizedBox(
            width: 80,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _acceptTransfer(offer),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.isEnglish ? 'Accept' : 'Принять',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOffers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        AppStrings.noTransferOffers,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
