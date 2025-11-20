import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('usage_stats');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);

      switch (methodCall.method) {
        case 'isUsagePermission':
          return true;
        case 'grantUsagePermission':
          return null;
        case 'queryEvents':
          return [
            {
              'eventType': '1',
              'timeStamp': '1234567890',
              'packageName': 'com.example.app',
              'className': 'MainActivity',
            }
          ];
        case 'queryConfiguration':
          return [
            {
              'activationCount': '5',
              'totalTimeActive': '3600000',
              'configuration': 'default',
              'lastTimeActive': '1234567890',
              'firstTimeStamp': '1234567000',
              'lastTimeStamp': '1234567890',
            }
          ];
        case 'queryEventStats':
          return [
            {
              'firstTimeStamp': '1234567000',
              'lastTimeStamp': '1234567890',
              'totalTime': '3600000',
              'lastEventTime': '1234567890',
              'eventType': '1',
              'count': '10',
            }
          ];
        case 'queryUsageStats':
          return [
            {
              'firstTimeStamp': '1234567000',
              'lastTimeStamp': '1234567890',
              'lastTimeUsed': '1234567890',
              'totalTimeInForeground': '3600000',
              'packageName': 'com.example.app',
            }
          ];
        case 'queryAndAggregateUsageStats':
          return {
            'com.example.app': {
              'firstTimeStamp': '1234567000',
              'lastTimeStamp': '1234567890',
              'lastTimeUsed': '1234567890',
              'totalTimeInForeground': '3600000',
              'packageName': 'com.example.app',
            }
          };
        case 'queryNetworkUsageStats':
          return [
            {
              'packageName': 'com.example.app',
              'rxTotalBytes': '1024000',
              'txTotalBytes': '512000',
            }
          ];
        case 'queryNetworkUsageStatsByPackage':
          return {
            'packageName': 'com.example.app',
            'rxTotalBytes': '1024000',
            'txTotalBytes': '512000',
          };
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('UsageStats Permission Methods', () {
    test('checkUsagePermission returns true', () async {
      final result = await UsageStats.checkUsagePermission();

      expect(result, true);
      expect(log, <Matcher>[
        isMethodCall('isUsagePermission', arguments: null),
      ]);
    });

    test('grantUsagePermission is called', () async {
      await UsageStats.grantUsagePermission();

      expect(log, <Matcher>[
        isMethodCall('grantUsagePermission', arguments: null),
      ]);
    });
  });

  group('UsageStats Query Methods', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 1, 31);

    test('queryEvents returns list of EventUsageInfo', () async {
      final result = await UsageStats.queryEvents(startDate, endDate);

      expect(result, isA<List<EventUsageInfo>>());
      expect(result.length, 1);
      expect(result[0].eventType, '1');
      expect(result[0].packageName, 'com.example.app');
      expect(result[0].className, 'MainActivity');

      expect(log[0].method, 'queryEvents');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
    });

    test('queryConfiguration returns list of ConfigurationInfo', () async {
      final result = await UsageStats.queryConfiguration(startDate, endDate);

      expect(result, isA<List<ConfigurationInfo>>());
      expect(result.length, 1);
      expect(result[0].activationCount, '5');
      expect(result[0].totalTimeActive, '3600000');
      expect(result[0].configuration, 'default');

      expect(log[0].method, 'queryConfiguration');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
    });

    test('queryEventStats returns list of EventInfo', () async {
      final result = await UsageStats.queryEventStats(startDate, endDate);

      expect(result, isA<List<EventInfo>>());
      expect(result.length, 1);
      expect(result[0].eventType, '1');
      expect(result[0].count, '10');
      expect(result[0].totalTime, '3600000');

      expect(log[0].method, 'queryEventStats');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
    });

    test('queryUsageStats returns list of UsageInfo', () async {
      final result = await UsageStats.queryUsageStats(startDate, endDate);

      expect(result, isA<List<UsageInfo>>());
      expect(result.length, 1);
      expect(result[0].packageName, 'com.example.app');
      expect(result[0].totalTimeInForeground, '3600000');

      expect(log[0].method, 'queryUsageStats');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
    });

    test('queryAndAggregateUsageStats returns map of UsageInfo', () async {
      final result = await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

      expect(result, isA<Map<String, UsageInfo>>());
      expect(result.containsKey('com.example.app'), true);
      expect(result['com.example.app']?.packageName, 'com.example.app');
      expect(result['com.example.app']?.totalTimeInForeground, '3600000');

      expect(log[0].method, 'queryAndAggregateUsageStats');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
    });
  });

  group('Network Usage Stats Methods', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 1, 31);

    test('queryNetworkUsageStats returns list of NetworkInfo', () async {
      final result = await UsageStats.queryNetworkUsageStats(
        startDate,
        endDate,
      );

      expect(result, isA<List<NetworkInfo>>());
      expect(result.length, 1);
      expect(result[0].packageName, 'com.example.app');
      expect(result[0].rxTotalBytes, '1024000');
      expect(result[0].txTotalBytes, '512000');

      expect(log[0].method, 'queryNetworkUsageStats');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
      expect(log[0].arguments['type'], NetworkType.all.value);
    });

    test('queryNetworkUsageStats with WiFi networkType', () async {
      final result = await UsageStats.queryNetworkUsageStats(
        startDate,
        endDate,
        networkType: NetworkType.wifi,
      );

      expect(result, isA<List<NetworkInfo>>());
      expect(log[0].arguments['type'], NetworkType.wifi.value);
    });

    test('queryNetworkUsageStats with Mobile networkType', () async {
      final result = await UsageStats.queryNetworkUsageStats(
        startDate,
        endDate,
        networkType: NetworkType.mobile,
      );

      expect(result, isA<List<NetworkInfo>>());
      expect(log[0].arguments['type'], NetworkType.mobile.value);
    });

    test('queryNetworkUsageStatsByPackage returns NetworkInfo', () async {
      final result = await UsageStats.queryNetworkUsageStatsByPackage(
        startDate,
        endDate,
        packageName: 'com.example.app',
      );

      expect(result, isA<NetworkInfo>());
      expect(result.packageName, 'com.example.app');
      expect(result.rxTotalBytes, '1024000');
      expect(result.txTotalBytes, '512000');

      expect(log[0].method, 'queryNetworkUsageStatsByPackage');
      expect(log[0].arguments['start'], startDate.millisecondsSinceEpoch);
      expect(log[0].arguments['end'], endDate.millisecondsSinceEpoch);
      expect(log[0].arguments['type'], NetworkType.all.value);
      expect(log[0].arguments['packageName'], 'com.example.app');
    });

    test('queryNetworkUsageStatsByPackage with WiFi networkType', () async {
      final result = await UsageStats.queryNetworkUsageStatsByPackage(
        startDate,
        endDate,
        packageName: 'com.example.app',
        networkType: NetworkType.wifi,
      );

      expect(result, isA<NetworkInfo>());
      expect(log[0].arguments['type'], NetworkType.wifi.value);
    });
  });

  group('NetworkType Extension', () {
    test('NetworkType.all has correct value', () {
      expect(NetworkType.all.value, 1);
    });

    test('NetworkType.wifi has correct value', () {
      expect(NetworkType.wifi.value, 2);
    });

    test('NetworkType.mobile has correct value', () {
      expect(NetworkType.mobile.value, 3);
    });
  });
}
