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

  int _balance = 0;
  Set<String> _ownedModes = {};
  final Set<String> _buying = {};
  bool _loading = true;

  bool get _english => AppStrings.isEnglish;

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
        title: Text(
          _english ? 'Confirm purchase' : 'Подтверждение покупки',
          style: const TextStyle(color: Colors.white),
        ),
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
          _showMessage(
            _english
                ? '${item.titleEn} unlocked'
                : 'Режим «${item.titleRu}» открыт',
          );
        case FCPointsPurchaseResult.alreadyOwned:
          await _loadShop();
        case FCPointsPurchaseResult.insufficientFunds:
          _showMessage(
            _english
                ? 'Not enough FC Points'
                : 'Недостаточно FC Points',
          );
        case FCPointsPurchaseResult.unknownItem:
          _showMessage(
            _english ? 'This item is unavailable' : 'Покупка недоступна',
          );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          _english ? 'Could not save the purchase' : 'Не удалось сохранить покупку',
        );
      }
    } finally {
      if (mounted) setState(() => _buying.remove(item.id));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF174A25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04160A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF082A12),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_english ? 'FC Points Shop' : 'Магазин FC Points'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3A1A), Color(0xFF04160A)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 22),
                  Text(
                    _english ? 'CAREER MODES' : 'РЕЖИМЫ КАРЬЕРЫ',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in FCPointsService.shopItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildItemCard(item),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    _english
                        ? 'Each mode is purchased separately. Unlocked modes remain available for future careers.'
                        : 'Каждый режим покупается отдельно. Открытые режимы будут доступны и в следующих карьерах.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_rounded, color: _gold, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _english ? 'YOUR BALANCE' : 'ТВОЙ БАЛАНС',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_balance FC Points',
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(FCPointsShopItem item) {
    final owned = _ownedModes.contains(item.id);
    final buying = _buying.contains(item.id);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: owned
              ? _green.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: _green, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _english ? item.titleEn : item.titleRu,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (owned)
                const Icon(Icons.check_circle_rounded, color: _green, size: 23)
              else
                const Icon(Icons.lock_outline_rounded, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _english ? item.descriptionEn : item.descriptionRu,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: _gold, size: 18),
              const SizedBox(width: 5),
              Text(
                '${item.price} FCP',
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (owned)
                Text(
                  _english ? 'OWNED' : 'КУПЛЕНО',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                )
              else
                FilledButton(
                  onPressed: buying ? null : () => _buy(item),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: const Color(0xFF082A12),
                    disabledBackgroundColor: Colors.white24,
                  ),
                  child: buying
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_english ? 'UNLOCK' : 'ОТКРЫТЬ'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
