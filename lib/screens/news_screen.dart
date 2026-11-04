import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_news.dart';
import 'package:flutter_football/services/app_strings.dart';

class NewsScreen extends StatelessWidget {
  final Career career;

  const NewsScreen({super.key, required this.career});

  static const Color backgroundColor = Color(0xFF06110B);
  static const Color accentColor = Color(0xFF9BEA8D);
  static const Color mutedColor = Color(0xFF9BA99F);

  IconData _getIcon(CareerNewsType type) {
    switch (type) {
      case CareerNewsType.match:
        return Icons.sports_soccer_rounded;
      case CareerNewsType.achievement:
        return Icons.emoji_events_rounded;
      case CareerNewsType.transfer:
        return Icons.swap_horiz_rounded;
      case CareerNewsType.contract:
        return Icons.description_rounded;
      case CareerNewsType.season:
        return Icons.calendar_month_rounded;
      case CareerNewsType.form:
        return Icons.trending_up_rounded;
      case CareerNewsType.objective:
        return Icons.flag_rounded;
      case CareerNewsType.sponsor:
        return Icons.handshake_rounded;
      case CareerNewsType.rumor:
        return Icons.campaign_rounded;
    }
  }

  Color _getAccent(CareerNewsType type) {
    switch (type) {
      case CareerNewsType.match:
        return const Color(0xFF8BE07F);
      case CareerNewsType.achievement:
        return const Color(0xFFFFD166);
      case CareerNewsType.transfer:
        return const Color(0xFF78C7FF);
      case CareerNewsType.contract:
        return const Color(0xFFC3A6FF);
      case CareerNewsType.season:
        return const Color(0xFFFFA875);
      case CareerNewsType.form:
        return const Color(0xFF71D6B3);
      case CareerNewsType.objective:
        return const Color(0xFF8EB8FF);
      case CareerNewsType.sponsor:
        return const Color(0xFFE6C56F);
      case CareerNewsType.rumor:
        return const Color(0xFFB99AFF);
    }
  }

  String _getCategory(CareerNewsType type) {
    switch (type) {
      case CareerNewsType.match:
        return AppStrings.matchNewsCategory;
      case CareerNewsType.achievement:
        return AppStrings.achievementNewsCategory;
      case CareerNewsType.transfer:
        return AppStrings.transferNewsCategory;
      case CareerNewsType.contract:
        return AppStrings.contractNewsCategory;
      case CareerNewsType.season:
        return AppStrings.seasonNewsCategory;
      case CareerNewsType.form:
        return AppStrings.isEnglish ? 'FORM' : 'ФОРМА';
      case CareerNewsType.objective:
        return AppStrings.isEnglish ? 'OBJECTIVES' : 'ЦЕЛИ';
      case CareerNewsType.sponsor:
        return AppStrings.isEnglish ? 'SPONSORS' : 'СПОНСОРЫ';
      case CareerNewsType.rumor:
        return AppStrings.isEnglish ? 'RUMOURS' : 'СЛУХИ';
    }
  }

  String _getMeta(CareerNews news) {
    if (news.matchNumber == 0 && news.type == CareerNewsType.transfer) {
      return 'ТРАНСФЕРНОЕ ОКНО  •  СЕЗОН ${news.season}';
    }
    if (news.matchNumber == 0 && news.type == CareerNewsType.season) {
      return 'ФУТБОЛЬНЫЕ ИТОГИ  •  СЕЗОН ${news.season}';
    }
    if (news.matchNumber == 0 && news.type == CareerNewsType.achievement) {
      return 'НАГРАДЫ  •  СЕЗОН ${news.season}';
    }
    if (news.matchNumber < 0) {
      return 'ПРЕДСЕЗОНЬЕ  •  СЕЗОН ${news.season}';
    }
    return AppStrings.newsSeasonAndMatch(news.season, news.matchNumber)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final sortedNews =
        career.news.where((item) => item.season == career.season).toList()
          ..sort((a, b) {
            final aSeasonEvent = a.matchNumber == 0 ? 1 : 0;
            final bSeasonEvent = b.matchNumber == 0 ? 1 : 0;
            if (aSeasonEvent != bSeasonEvent) {
              return bSeasonEvent.compareTo(aSeasonEvent);
            }
            return b.matchNumber.compareTo(a.matchNumber);
          });
    final visibleNews = sortedNews.take(20).toList();
    final transferCount = sortedNews
        .where((item) => item.type == CareerNewsType.transfer)
        .length;
    final matchCount = sortedNews
        .where((item) => item.type == CareerNewsType.match)
        .length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          AppStrings.footballNewsTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.35,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: accentColor, size: 7),
                const SizedBox(width: 7),
                Text(
                  'S${career.season}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: visibleNews.isEmpty
          ? _buildEmptyState()
          : Stack(
              children: [
                Positioned(
                  top: -110,
                  right: -100,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.055),
                    ),
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                  children: [
                    _buildHero(visibleNews.length, transferCount, matchCount),
                    if (career.objectives.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildObjectivesPanel(),
                    ],
                    const SizedBox(height: 23),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 17,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'ЛЕНТА СОБЫТИЙ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.35,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${visibleNews.length} НОВОСТЕЙ',
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    ...visibleNews.asMap().entries.map(
                      (entry) => _buildTimelineItem(
                        entry.value,
                        isLast: entry.key == visibleNews.length - 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildHero(int newsCount, int transferCount, int matchCount) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1D4930).withValues(alpha: 0.96),
                    const Color(0xFF102A1B).withValues(alpha: 0.96),
                    const Color(0xFF101C16).withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -25,
            top: -30,
            child: Icon(
              Icons.newspaper_rounded,
              size: 170,
              color: Colors.white.withValues(alpha: 0.045),
            ),
          ),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 19, 18, 17),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.17)),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: accentColor,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.careerNewsHeader.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'ГЛАВНЫЕ СОБЫТИЯ ВАШЕЙ КАРЬЕРЫ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  Text(
                    '$newsCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.seasonNewsCount(career.season, newsCount),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: _heroMetric(
                          icon: Icons.swap_horiz_rounded,
                          label: 'ТРАНСФЕРЫ',
                          value: transferCount.toString(),
                          color: const Color(0xFF78C7FF),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 31,
                        color: Colors.white.withValues(alpha: 0.13),
                      ),
                      Expanded(
                        child: _heroMetric(
                          icon: Icons.sports_soccer_rounded,
                          label: 'МАТЧИ',
                          value: matchCount.toString(),
                          color: accentColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 31,
                        color: Colors.white.withValues(alpha: 0.13),
                      ),
                      Expanded(
                        child: _heroMetric(
                          icon: Icons.calendar_month_rounded,
                          label: 'СЕЗОН',
                          value: career.season.toString(),
                          color: const Color(0xFFFFD166),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesPanel() {
    final objectives = career.objectives.where((item) => item.season == career.season).toList();
    if (objectives.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.isEnglish ? 'COACH OBJECTIVES' : 'ЗАДАЧИ ТРЕНЕРА',
            style: const TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 10),
          for (final objective in objectives) ...[
            Row(children: [
              Expanded(child: Text(objective.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
              Text(objective.completed ? (AppStrings.isEnglish ? 'DONE' : 'ВЫПОЛНЕНО') : '${objective.progress}/${objective.target}',
                style: TextStyle(color: objective.completed ? accentColor : Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 5),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
              value: objective.progressRatio, minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(objective.completed ? accentColor : const Color(0xFF8EB8FF)),
            )),
            const SizedBox(height: 4),
            Text('${objective.description} · ${AppStrings.isEnglish ? 'Reward' : 'Премия'} €${objective.reward}',
              style: const TextStyle(color: mutedColor, fontSize: 10)),
            if (objective != objectives.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CareerNews news, {required bool isLast}) {
    final accent = _getAccent(news.type);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(_getIcon(news.type), color: accent, size: 12),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.055),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.11),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getCategory(news.type).toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.circle,
                              color: Colors.white24,
                              size: 5,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _getMeta(news),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: mutedColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          news.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          news.description,
                          style: const TextStyle(
                            color: Color(0xFFC0CBC3),
                            fontSize: 11,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: accentColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.noNewsYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.firstMatchNewsHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
