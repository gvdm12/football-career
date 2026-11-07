import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/fc_points_service.dart';

class FCPointsShopScreen extends StatefulWidget {
  const FCPointsShopScreen({super.key});

  @override
  State<FCPointsShopScreen> createState() => _FCPointsShopScreenState();
}

class _FCPointsShopScreenState extends State<FCPointsShopScreen> {
  static const Color _gold = Color(0xFFD9B65C);
  static const Color _green = Color(0xFF8BE07F);
  static const Color _background = Color(0xFF04160A);

  int _balance = 0;
  Set<String> _ownedModes = {};
  final Set<String> _buying = {};
  bool _loading = true;

  bool get _english => AppStrings.isEnglish;

  List<_RewardInfo> get _rewards => [
    _RewardInfo(_english ? 'Season completed' : 'Завершение сезона', 10, Icons.flag_rounded),
    _RewardInfo(_english ? 'League champion' : 'Чемпион лиги', 80, Icons.emoji_events_rounded),
    _RewardInfo(_english ? 'National cup winner' : 'Обладатель кубка', 60, Icons.workspace_premium_rounded),
    _RewardInfo(_english ? 'Europa League winner' : 'Победитель Лиги Европы', 90, Icons.verified_rounded),
    _RewardInfo(_english ? 'Champions League winner' : 'Победитель Лиги чемпионов', 150, Icons.stars_rounded),
    _RewardInfo(_english ? 'Golden Boot' : 'Золотая бутса', 50, Icons.sports_soccer_rounded),
    _RewardInfo(_english ? 'Best assistant' : 'Лучший ассистент', 40, Icons.assistant_rounded),
    _RewardInfo(_english ? 'Ballon d’Or' : 'Золотой мяч', 100, Icons.military_tech_rounded),
    _RewardInfo(_english ? 'Full career completed' : 'Завершение всей карьеры', 50, Icons.workspace_premium_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final values = await Future.wait([
      FCPointsService.balance(),
      FCPointsService.ownedModes(),
    ]);
    if (!mounted) return;
    setState(() {
      _balance = values[0] as int;
      _ownedModes = values[1] as Set<String>;
      _loading = false;
    });
  }

  Future<void> _buy(FCPointsShopItem item) async {
    if (_buying.contains(item.id) || _ownedModes.contains(item.id)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF102A18),
        title: Text(_english ? 'Confirm purchase' : 'Подтверждение покупки',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          _english
              ? 'Unlock "${item.titleEn}" for ${item.price} FC Points?'
              : 'Открыть режим «${item.titleRu}» за ${item.price} FC Points?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_english ? 'Cancel' : 'Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_english ? 'Buy' : 'Купить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _buying.add(item.id));
    try {
      final result = await FCPointsService.purchaseMode(item.id);
      if (!mounted) return;
      switch (result) {
        case FCPointsPurchaseResult.purchased:
          setState(() {
            _balance -= item.price;
            _ownedModes.add(item.id);
          });
          _showMessage(_english ? '${item.titleEn} unlocked' : 'Режим «${item.titleRu}» открыт');
          break;
        case FCPointsPurchaseResult.alreadyOwned:
          await _loadShop();
          break;
        case FCPointsPurchaseResult.insufficientFunds:
          _showMessage(_english ? 'Not enough FC Points' : 'Недостаточно FC Points');
          break;
        case FCPointsPurchaseResult.unknownItem:
          _showMessage(_english ? 'This item is unavailable' : 'Покупка недоступна');
          break;
      }
    } catch (_) {
      if (mounted) _showMessage(_english ? 'Could not save the purchase' : 'Не удалось сохранить покупку');
    } finally {
      if (mounted) setState(() => _buying.remove(item.id));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF174A25)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_english ? 'FC Points Shop' : 'Магазин FC Points',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF123D20), Color(0xFF071D10), _background],
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            right: -80,
            child: _glow(220, _green.withValues(alpha: 0.10)),
          ),
          Positioned(
            top: 430,
            left: -110,
            child: _glow(240, _gold.withValues(alpha: 0.07)),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _green))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _buildBalanceCard(),
                      const SizedBox(height: 26),
                      _sectionTitle(_english ? 'CAREER MODES' : 'РЕЖИМЫ КАРЬЕРЫ',
                          _english ? 'Unlock new ways to play' : 'Открывай новые возможности'),
                      const SizedBox(height: 13),
                      for (final item in FCPointsService.shopItems)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildItemCard(item),
                        ),
                      const SizedBox(height: 17),
                      _sectionTitle(_english ? 'HOW TO EARN' : 'КАК ЗАРАБОТАТЬ',
                          _english ? 'Rewards for your achievements' : 'Награды за твои достижения'),
                      const SizedBox(height: 12),
                      _buildRewardsCard(),
                      const SizedBox(height: 16),
                      Text(
                        _english
                            ? 'Each mode is purchased separately and remains unlocked for all future careers.'
                            : 'Каждый режим покупается отдельно и остаётся открытым для всех следующих карьер.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 35)]),
  );

  Widget _glass({required Widget child, EdgeInsets padding = const EdgeInsets.all(16), Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.075),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.14)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return _glass(
      padding: const EdgeInsets.all(19),
      borderColor: _gold.withValues(alpha: 0.42),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF3D889), Color(0xFFB88A32)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.24), blurRadius: 18)],
            ),
            child: const Icon(Icons.monetization_on_rounded, color: Color(0xFF30220A), size: 34),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_english ? 'YOUR FC POINTS' : 'ТВОИ FC POINTS',
                    style: const TextStyle(color: Colors.white60, fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                const SizedBox(height: 4),
                Text('$_balance',
                    style: const TextStyle(color: _gold, fontSize: 29,
                      fontWeight: FontWeight.w900, height: 1.0)),
                const SizedBox(height: 3),
                Text(_english ? 'Available to spend' : 'Доступно для покупок',
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.white38, size: 25),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: _green, fontSize: 12,
        fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ],
  );

  Widget _buildItemCard(FCPointsShopItem item) {
    final owned = _ownedModes.contains(item.id);
    final buying = _buying.contains(item.id);
    final enough = _balance >= item.price;
    return _glass(
      borderColor: owned ? _green.withValues(alpha: 0.48) : Colors.white.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _green.withValues(alpha: 0.18)),
                ),
                child: Icon(item.icon, color: _green, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_english ? item.titleEn : item.titleRu,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              if (owned)
                const Icon(Icons.check_circle_rounded, color: _green, size: 23)
              else
                const Icon(Icons.lock_outline_rounded, color: Colors.white38, size: 21),
            ],
          ),
          const SizedBox(height: 11),
          Text(_english ? item.descriptionEn : item.descriptionRu,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.45)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: _gold, size: 19),
              const SizedBox(width: 5),
              Text('${item.price} FCP', style: const TextStyle(color: _gold,
                fontWeight: FontWeight.w900, fontSize: 14)),
              const Spacer(),
              if (owned)
                const Text('КУПЛЕНО', style: TextStyle(color: _green,
                  fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))
              else
                FilledButton(
                  onPressed: buying || !enough ? null : () => _buy(item),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: const Color(0xFF082A12),
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  ),
                  child: buying
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_english ? (enough ? 'UNLOCK' : 'NOT ENOUGH') : (enough ? 'ОТКРЫТЬ' : 'НЕ ХВАТАЕТ'),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    return _glass(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        children: [
          for (var i = 0; i < _rewards.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(_rewards[i].icon, color: _gold, size: 18),
                  ),
                  const SizedBox(width: 11),
                  Expanded(child: Text(_rewards[i].title,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                  Text('+ ${_rewards[i].points} FCP',
                    style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            if (i != _rewards.length - 1)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          ],
        ],
      ),
    );
  }
}

class _RewardInfo {
  final String title;
  final int points;
  final IconData icon;

  const _RewardInfo(this.title, this.points, this.icon);
}
