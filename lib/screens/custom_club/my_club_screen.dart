import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/custom_club.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/services/custom_club_service.dart';
import 'package:flutter_football/widgets/custom_club_badge.dart';

/// Управление клубом, созданным игроком: бюджет, улучшения, цены на билеты,
/// вложения личных денег и история сезонов.
class MyClubScreen extends StatefulWidget {
  final Career career;

  const MyClubScreen({super.key, required this.career});

  @override
  State<MyClubScreen> createState() => _MyClubScreenState();
}

class _MyClubScreenState extends State<MyClubScreen> {
  static const Color _background = Color(0xFF061B0C);
  static const Color _card = Color(0xFF0B2414);
  static const Color _green = Color(0xFF22C55E);

  late Career career;

  bool get _en => AppStrings.isEnglish;

  @override
  void initState() {
    super.initState();
    career = widget.career;
  }

  Future<void> _apply(Career updated) async {
    setState(() => career = updated);
    try {
      await CareerStorage.save(updated);
    } catch (_) {
      // Сохранение повторится при выходе на экран сезона.
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _money(int value) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    if (abs >= 1000000) {
      final text = (abs / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1);
      return _en ? '$sign$text M €' : '$sign$text млн €';
    }
    final thousands = (abs / 1000).round();
    return _en ? '$sign$thousands K €' : '$sign$thousands тыс. €';
  }

  ({String title, String description, IconData icon}) _info(
    ClubFacility facility,
  ) {
    switch (facility) {
      case ClubFacility.academy:
        return (
          title: _en ? 'Youth academy' : 'Академия',
          description: _en
              ? 'Raises the club strength by +0.2 per level every season.'
              : 'Растит клуб: +0.2 к силе за сезон на каждый уровень.',
          icon: Icons.school_outlined,
        );
      case ClubFacility.training:
        return (
          title: _en ? 'Training ground' : 'Тренировочная база',
          description: _en
              ? 'Raises the club strength by +0.25 per level every season.'
              : 'Растит клуб: +0.25 к силе за сезон на каждый уровень.',
          icon: Icons.fitness_center,
        );
      case ClubFacility.scouting:
        return (
          title: _en ? 'Scouting network' : 'Скаутинг',
          description: _en
              ? 'Raises the club strength by +0.25 per level every season.'
              : 'Растит клуб: +0.25 к силе за сезон на каждый уровень.',
          icon: Icons.travel_explore,
        );
      case ClubFacility.stadium:
        return (
          title: _en ? 'Stadium' : 'Стадион',
          description: _en
              ? 'More seats mean more ticket income.'
              : 'Больше мест, больше дохода от билетов.',
          icon: Icons.stadium_outlined,
        );
    }
  }

  void _upgrade(CustomClub club, ClubFacility facility) {
    final upgraded = CustomClubService.upgrade(club, facility);
    if (upgraded == null) {
      _message(
        _en
            ? 'Not enough club funds or the maximum level is reached'
            : 'Не хватает денег клуба или достигнут максимум',
      );
      return;
    }
    _apply(career.copyWith(customClub: upgraded));
  }

  Future<void> _donate(CustomClub club) async {
    const options = [50000, 100000, 250000, 500000, 1000000];

    final amount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: _card,
        title: Text(
          _en ? 'Invest your own money' : 'Вложить личные деньги',
          style: const TextStyle(color: Colors.white),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: Text(
              _en
                  ? 'Your money: ${_money(career.money)}'
                  : 'Твои деньги: ${_money(career.money)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          for (final option in options)
            SimpleDialogOption(
              onPressed: career.money >= option
                  ? () => Navigator.pop(dialogContext, option)
                  : null,
              child: Text(
                _money(option),
                style: TextStyle(
                  color: career.money >= option ? Colors.white : Colors.white30,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );

    if (amount == null || !mounted) return;
    await _apply(
      career.copyWith(
        money: career.money - amount,
        customClub: CustomClubService.donate(club, amount),
      ),
    );
  }

  Future<void> _renameStadium(CustomClub club) async {
    final controller = TextEditingController(text: club.stadiumName);
    String? error;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _card,
          title: Text(
            _en ? 'Stadium name' : 'Название стадиона',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: CustomClubService.maxStadiumNameLength,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              errorText: error,
              counterStyle: const TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_en ? 'Cancel' : 'Отмена'),
            ),
            TextButton(
              onPressed: () {
                final issue = CustomClubService.validateStadiumName(
                  controller.text,
                );
                if (issue != null) {
                  setDialogState(() {
                    error = _en
                        ? 'From ${CustomClubService.minStadiumNameLength} to ${CustomClubService.maxStadiumNameLength} letters or digits'
                        : 'От ${CustomClubService.minStadiumNameLength} до ${CustomClubService.maxStadiumNameLength} букв или цифр';
                  });
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  CustomClubService.cleanName(controller.text),
                );
              },
              child: Text(
                _en ? 'Save' : 'Сохранить',
                style: const TextStyle(color: _green),
              ),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    if (name == null || !mounted) return;
    await _apply(career.copyWith(customClub: club.copyWith(stadiumName: name)));
  }

  Widget _cardBox({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _header(CustomClub club) {
    final strength = Clubs.getByName(club.name).strength;
    final division =
        LeagueDivisionService.divisionForClub(
          club.name,
          career.leagueDivisions,
        ) ??
        club.division;

    return _cardBox(
      child: Column(
        children: [
          Row(
            children: [
              CustomClubBadge.fromClub(club, size: 76),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${club.league.displayName} · ${_en ? 'Division' : 'Дивизион'} $division',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${club.stadiumName} · ${CustomClubService.stadiumCapacity(club.levelOf(ClubFacility.stadium))} ${_en ? 'seats' : 'мест'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _en ? 'Rename stadium' : 'Переименовать стадион',
                onPressed: () => _renameStadium(club),
                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(_en ? 'Strength' : 'Сила', '$strength', color: _green),
              _stat(
                _en ? 'Club funds' : 'Бюджет',
                _money(club.funds),
                color: club.funds < 0 ? Colors.redAccent : Colors.white,
              ),
              _stat(_en ? 'Titles' : 'Титулы', '${club.titles}'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _en ? 'Fans' : 'Болельщики',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${club.fans}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: club.fans / 100,
              minHeight: 7,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _facilityCard(CustomClub club, ClubFacility facility) {
    final info = _info(facility);
    final level = club.levelOf(facility);
    final cost = CustomClubService.upgradeCost(facility, level);
    final affordable = cost != null && club.funds >= cost;

    return _cardBox(
      child: Row(
        children: [
          Icon(info.icon, color: _green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.description,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < CustomClubService.maxFacilityLevel; i++)
                      Container(
                        width: 14,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: i < level ? _green : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 104,
            child: FilledButton(
              onPressed: affordable ? () => _upgrade(club, facility) : null,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                cost == null ? (_en ? 'Maximum' : 'Максимум') : _money(cost),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _policyCard(CustomClub club) {
    String label(TicketPolicy policy) {
      switch (policy) {
        case TicketPolicy.affordable:
          return _en ? 'Cheap' : 'Дешёвые';
        case TicketPolicy.standard:
          return _en ? 'Normal' : 'Обычные';
        case TicketPolicy.premium:
          return _en ? 'Premium' : 'Дорогие';
      }
    }

    return _cardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _en ? 'Ticket prices' : 'Цены на билеты',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _en
                ? 'Cheap tickets win fans, expensive ones bring more money.'
                : 'Дешёвые билеты привлекают болельщиков, дорогие приносят больше денег.',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<TicketPolicy>(
              showSelectedIcon: false,
              segments: [
                for (final policy in TicketPolicy.values)
                  ButtonSegment<TicketPolicy>(
                    value: policy,
                    label: Text(
                      '${label(policy)}\n${CustomClubService.ticketPrice(policy)} €',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
              ],
              selected: {club.ticketPolicy},
              onSelectionChanged: (selection) => _apply(
                career.copyWith(
                  customClub: club.copyWith(ticketPolicy: selection.first),
                ),
              ),
              style: SegmentedButton.styleFrom(
                foregroundColor: Colors.white70,
                selectedForegroundColor: Colors.black,
                selectedBackgroundColor: _green,
                side: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecastCard(CustomClub club) {
    final strength = Clubs.getByName(club.name).strength;
    final division =
        LeagueDivisionService.divisionForClub(
          club.name,
          career.leagueDivisions,
        ) ??
        club.division;
    final finance = CustomClubService.seasonFinance(
      club: club,
      position: 0,
      teamCount: 0,
      division: division,
      strength: strength,
    );
    final growth = CustomClubService.growthPerSeason(club);

    Widget row(String label, int value, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: bold ? Colors.white : Colors.white70,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              _money(value),
              style: TextStyle(
                color: bold
                    ? (value < 0 ? Colors.redAccent : _green)
                    : Colors.white,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return _cardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _en
                ? 'Season forecast (mid-table finish)'
                : 'Прогноз бюджета на сезон (середина таблицы)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          row(_en ? 'TV and prize money' : 'ТВ и призовые', finance.tv + finance.prize),
          row(_en ? 'Tickets' : 'Билеты', finance.tickets),
          row(_en ? 'Sponsors' : 'Спонсоры', finance.sponsors),
          row(_en ? 'Wages' : 'Зарплаты', -finance.wages),
          row(_en ? 'Upkeep' : 'Содержание', -finance.upkeep),
          const Divider(color: Colors.white12),
          row(_en ? 'Expected result' : 'Ожидаемый итог', finance.net, bold: true),
          const SizedBox(height: 6),
          Text(
            _en
                ? 'Growth from upgrades: +${growth.toStringAsFixed(2)} strength per season'
                : 'Рост от улучшений: +${growth.toStringAsFixed(2)} к силе за сезон',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _donateCard(CustomClub club) {
    return _cardBox(
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism_outlined, color: _green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _en
                  ? 'Invest your own money into the club (you have ${_money(career.money)}).'
                  : 'Вложи личные деньги в клуб (у тебя ${_money(career.money)}).',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _donate(club),
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: const BorderSide(color: _green),
            ),
            child: Text(_en ? 'Invest' : 'Вложить'),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(CustomClub club) {
    if (club.history.isEmpty) {
      return _cardBox(
        child: Text(
          _en
              ? 'The history will appear after the first season.'
              : 'История появится после первого сезона.',
          style: const TextStyle(color: Colors.white60),
        ),
      );
    }

    return _cardBox(
      child: Column(
        children: [
          for (final item in club.history.reversed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: item.champion
                        ? const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFFFD54F),
                            size: 18,
                          )
                        : null,
                  ),
                  SizedBox(
                    width: 74,
                    child: Text(
                      '${_en ? 'Season' : 'Сезон'} ${item.season}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.position > 0
                          ? '${item.position}/${item.teamCount} · OVR ${item.strength}'
                          : 'OVR ${item.strength}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Text(
                    _money(item.net),
                    style: TextStyle(
                      color: item.net < 0 ? Colors.redAccent : _green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = career.customClub;

    return PopScope<Career>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, career);
      },
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _card,
          foregroundColor: Colors.white,
          title: Text(
            _en ? 'My club' : 'Мой клуб',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: club == null
            ? Center(
                child: Text(
                  _en ? 'You have no club of your own' : 'У тебя нет своего клуба',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: [
                    _header(club),
                    _title(_en ? 'Development' : 'Развитие клуба'),
                    for (final facility in ClubFacility.values)
                      _facilityCard(club, facility),
                    _policyCard(club),
                    _donateCard(club),
                    _forecastCard(club),
                    _title(_en ? 'Club history' : 'История клуба'),
                    _historyCard(club),
                  ],
                ),
              ),
      ),
    );
  }
}
