import 'club.dart';

class TransferOffer {
  final Club club;
  final int salary;
  final int contractYears;
  final bool isRenewal;
  final bool isAgentOffer;

  const TransferOffer({
    required this.club,
    required this.salary,
    required this.contractYears,
    this.isRenewal = false,
    this.isAgentOffer = false,
  });
}
