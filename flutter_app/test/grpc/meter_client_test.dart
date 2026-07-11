import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  group('MeterClient', () {
    test('creates client with default host and port', () {
      final client = MeterClient();
      expect(client.host, equals('127.0.0.1'));
      expect(client.port, equals(50051));
    });

    test('creates client with custom host and port', () {
      final client = MeterClient(host: '192.168.1.100', port: 8080);
      expect(client.host, equals('192.168.1.100'));
      expect(client.port, equals(8080));
    });
  });

  group('toTimestamp', () {
    test('converts DateTime to Timestamp', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final timestamp = toTimestamp(dateTime);
      
      expect(timestamp, isA<Timestamp>());
      expect(timestamp.toDateTime(), equals(dateTime.toUtc()));
    });

    test('converts current DateTime to Timestamp', () {
      final now = DateTime.now();
      final timestamp = toTimestamp(now);
      
      expect(timestamp, isA<Timestamp>());
      expect(timestamp.toDateTime().difference(now.toUtc()).inSeconds.abs(), lessThan(1));
    });

    test('handles UTC DateTime', () {
      final utcDateTime = DateTime.utc(2024, 6, 20, 15, 45, 30);
      final timestamp = toTimestamp(utcDateTime);
      
      expect(timestamp.toDateTime(), equals(utcDateTime));
    });

    test('converts epoch DateTime to Timestamp', () {
      final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final timestamp = toTimestamp(epoch);
      
      expect(timestamp.seconds, equals(Int64(0)));
      expect(timestamp.nanos, equals(0));
    });

    test('preserves microsecond precision', () {
      final dateTime = DateTime.utc(2024, 1, 1, 0, 0, 0, 0, 123);
      final timestamp = toTimestamp(dateTime);
      final recovered = timestamp.toDateTime();
      
      expect(recovered.microsecond, equals(dateTime.microsecond));
    });
  });
}
