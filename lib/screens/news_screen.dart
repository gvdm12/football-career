import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_news.dart';
import 'package:flutter_football/services/app_strings.dart';

class NewsScreen extends StatelessWidget {
  final Career career;

  const NewsScreen({super.key, required this.career});

  static const Color backgroundColor = Color(0xFF04160A);
  static const Color cardColor = Color(0xFF0B2B14);
  static const Color accentColor = Color(0xFF8BE07F);

  IconData _getIcon(CareerNewsType type) {
    switch (type) {
      case CareerNewsType.match:
        return Icons.sports_soccer;
      case CareerNewsType.achievement:
        return Icons.emoji_events;
      case CareerNewsType.transfer:
        return Icons.swap_horiz;
      case CareerNewsType.contract:
        return Icons.description;
      case CareerNewsType.season:
        return Icons.calendar_month;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedNews =
        career.news.where((item) => item.season == career.season).toList()
          ..sort((a, b) => b.matchNumber.compareTo(a.matchNumber));

    final visibleNews = sortedNews.take(6).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.footballNewsTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: visibleNews.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildHeader(visibleNews.length),
                const SizedBox(height: 18),
                ...visibleNews.map(_buildNewsCard),
              ],
            ),
    );
  }

  Widget _buildHeader(int newsCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14401E), Color(0xFF0B2B14)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.newspaper, color: accentColor, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.careerNewsHeader,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.seasonNewsCount(career.season, newsCount),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(CareerNews news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_getIcon(news.type), color: accentColor, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategory(news.type),
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  news.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  news.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.newsSeasonAndMatch(news.season, news.matchNumber),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.newspaper_outlined,
              size: 68,
              color: accentColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.noNewsYet,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.firstMatchNewsHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
