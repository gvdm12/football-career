import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_logos.dart';

/// Проверяет, что список эмблем, файлы в assets/club_logos и модель клубов
/// согласованы, а сами PNG безопасны для показа.
void main() {
  final directory = Directory(ClubLogos.directory);

  List<File> pngFiles() => directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .toList();

  String keyOf(File file) {
    final name = file.uri.pathSegments.last;
    return name.substring(0, name.length - '.png'.length);
  }

  test('папка с эмблемами существует', () {
    expect(directory.existsSync(), isTrue);
  });

  test('у каждого ключа из списка есть PNG-файл', () {
    for (final key in ClubLogos.available) {
      expect(
        File('${ClubLogos.directory}/$key.png').existsSync(),
        isTrue,
        reason: 'нет файла для $key',
      );
    }
  });

  test('в папке нет файлов, которых нет в списке', () {
    final extra = pngFiles()
        .map(keyOf)
        .where((key) => !ClubLogos.available.contains(key))
        .toList();
    expect(extra, isEmpty, reason: 'добавьте в ClubLogos.available: $extra');
  });

  test('все PNG настоящие, не больше 256 px и не тяжёлые', () {
    const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

    for (final file in pngFiles()) {
      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(24), reason: file.path);
      expect(bytes.sublist(0, 8), signature, reason: file.path);

      final data = ByteData.sublistView(bytes);
      final width = data.getUint32(16);
      final height = data.getUint32(20);
      expect(width, inInclusiveRange(1, 256), reason: file.path);
      expect(height, inInclusiveRange(1, 256), reason: file.path);
      expect(bytes.length, lessThan(120 * 1024), reason: file.path);
    }
  });

  test('эмблема клуба из модели всегда указывает на существующий файл', () {
    for (final club in Clubs.all) {
      final asset = club.logoAsset;
      if (asset == null) continue;
      expect(File(asset).existsSync(), isTrue, reason: club.name);
    }
  });

  test('у каждой эмблемы из списка есть клуб в модели', () {
    final keys = Clubs.all
        .map((club) => ClubLogos.normalize(club.name))
        .toSet();
    final orphans = ClubLogos.available.where((key) => !keys.contains(key));
    expect(orphans, isEmpty);
  });

  test('Deportivo La Coruna и Deportivo Alaves получают разные эмблемы', () {
    final coruna = ClubLogos.assetFor('Deportivo La Coruna');
    final alaves = ClubLogos.assetFor('Deportivo Alaves');
    expect(coruna, isNotNull);
    expect(alaves, isNotNull);
    expect(coruna, isNot(alaves));
  });

  test('pubspec подключает PNG-эмблемы и не тянет старые SVG', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/club_logos/'));
    expect(pubspec, isNot(contains('assets/clubs/')));
  });
}
