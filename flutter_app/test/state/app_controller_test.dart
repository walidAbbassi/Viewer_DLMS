import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/state/app_controller.dart';
import 'package:flutter_python_grpc/state/app_state.dart';

void main() {
  group('AppController', () {
    late AppController controller;

    setUp(() {
      controller = AppController();
    });

    test('initial state is default AppState', () {
      expect(controller.state, equals(const AppState()));
      expect(controller.state.moduleName, isNull);
      expect(controller.state.datamodel, isNull);
      expect(controller.state.isConnected, isFalse);
      expect(controller.state.simulation, isFalse);
      expect(controller.state.simulationFile, isNull);
      expect(controller.state.firmwareUpgrade.blockSize, equals(0));
      expect(controller.state.firmwareUpgrade.blocksNumber, equals(0));
      expect(controller.state.firmwareUpgrade.isInitiated, isFalse);
      expect(controller.state.firmwareUpgrade.imageId, equals(''));
    });

    test('setModuleName updates module name', () {
      controller.setModuleName('TestModule');
      expect(controller.state.moduleName, equals('TestModule'));
    });

    test('setModuleName with null clears module name', () {
      controller.setModuleName('TestModule');
      controller.setModuleName(null);
      expect(controller.state.moduleName, isNull);
    });

    test('setDatamodel updates datamodel', () {
      controller.setDatamodel('TestDatamodel');
      expect(controller.state.datamodel, equals('TestDatamodel'));
    });

    test('setDatamodel with null clears datamodel', () {
      controller.setDatamodel('TestDatamodel');
      controller.setDatamodel(null);
      expect(controller.state.datamodel, isNull);
    });

    test('setBlockSize updates firmware block size', () {
      controller.setBlockSize(1024);
      expect(controller.state.firmwareUpgrade.blockSize, equals(1024));
    });

    test('setBlocksNumber updates firmware blocks number', () {
      controller.setBlocksNumber(100);
      expect(controller.state.firmwareUpgrade.blocksNumber, equals(100));
    });

    test('setInitiated updates firmware initiated status', () {
      controller.setInitiated(true);
      expect(controller.state.firmwareUpgrade.isInitiated, isTrue);
    });

    test('setIsConnected updates connection status', () {
      controller.setIsConnected(true);
      expect(controller.state.isConnected, isTrue);
      
      controller.setIsConnected(false);
      expect(controller.state.isConnected, isFalse);
    });

    test('setImageId updates firmware image ID', () {
      controller.setImageId('image123');
      expect(controller.state.firmwareUpgrade.imageId, equals('image123'));
    });

    test('setSimulation updates simulation status', () {
      controller.setSimulation(true);
      expect(controller.state.simulation, isTrue);
    });

    test('setSimulationFile updates simulation file path', () {
      controller.setSimulationFile('/path/to/simulation.xml');
      expect(controller.state.simulationFile, equals('/path/to/simulation.xml'));
    });

    test('resetFirmware resets firmware upgrade to default', () {
      controller.setBlockSize(1024);
      controller.setBlocksNumber(100);
      controller.setInitiated(true);
      controller.setImageId('image123');
      
      controller.resetFirmware();
      
      expect(controller.state.firmwareUpgrade.blockSize, equals(0));
      expect(controller.state.firmwareUpgrade.blocksNumber, equals(0));
      expect(controller.state.firmwareUpgrade.isInitiated, isFalse);
      expect(controller.state.firmwareUpgrade.imageId, equals(''));
    });

    test('resetFirmware preserves other state', () {
      controller.setModuleName('TestModule');
      controller.setIsConnected(true);
      controller.setBlockSize(1024);
      
      controller.resetFirmware();
      
      expect(controller.state.moduleName, equals('TestModule'));
      expect(controller.state.isConnected, isTrue);
    });

    test('resetAll resets entire state to default', () {
      controller.setModuleName('TestModule');
      controller.setDatamodel('TestDatamodel');
      controller.setIsConnected(true);
      controller.setBlockSize(1024);
      controller.setSimulation(true);
      
      controller.resetAll();
      
      expect(controller.state, equals(const AppState()));
      expect(controller.state.moduleName, isNull);
      expect(controller.state.datamodel, isNull);
      expect(controller.state.isConnected, isFalse);
      expect(controller.state.firmwareUpgrade.blockSize, equals(0));
      expect(controller.state.simulation, isFalse);
    });

    test('multiple updates maintain state correctly', () {
      controller.setModuleName('Module1');
      controller.setDatamodel('Datamodel1');
      controller.setIsConnected(true);
      controller.setBlockSize(512);
      
      expect(controller.state.moduleName, equals('Module1'));
      expect(controller.state.datamodel, equals('Datamodel1'));
      expect(controller.state.isConnected, isTrue);
      expect(controller.state.firmwareUpgrade.blockSize, equals(512));
    });
  });

  group('AppState', () {
    test('copyWith creates new instance with updated values', () {
      const initial = AppState(moduleName: 'Module1', isConnected: false);
      final updated = initial.copyWith(isConnected: true);
      
      expect(updated.moduleName, equals('Module1'));
      expect(updated.isConnected, isTrue);
      expect(initial.isConnected, isFalse); // Original unchanged
    });

    test('copyWith preserves unspecified values', () {
      const initial = AppState(
        moduleName: 'Module1',
        datamodel: 'Datamodel1',
        isConnected: true,
        simulation: false,
      );
      final updated = initial.copyWith(moduleName: 'Module2');
      
      expect(updated.moduleName, equals('Module2'));
      expect(updated.datamodel, equals('Datamodel1'));
      expect(updated.isConnected, isTrue);
      expect(updated.simulation, isFalse);
    });
  });

  group('FirmwareUpgrade', () {
    test('default constructor sets default values', () {
      const firmware = FirmwareUpgrade();
      
      expect(firmware.blockSize, equals(0));
      expect(firmware.blocksNumber, equals(0));
      expect(firmware.isInitiated, isFalse);
      expect(firmware.imageId, equals(''));
    });

    test('copyWith creates new instance with updated values', () {
      const initial = FirmwareUpgrade(blockSize: 512, blocksNumber: 50);
      final updated = initial.copyWith(blockSize: 1024);
      
      expect(updated.blockSize, equals(1024));
      expect(updated.blocksNumber, equals(50));
      expect(initial.blockSize, equals(512)); // Original unchanged
    });

    test('copyWith preserves unspecified values', () {
      const initial = FirmwareUpgrade(
        blockSize: 512,
        blocksNumber: 50,
        isInitiated: true,
        imageId: 'image123',
      );
      final updated = initial.copyWith(blocksNumber: 100);
      
      expect(updated.blockSize, equals(512));
      expect(updated.blocksNumber, equals(100));
      expect(updated.isInitiated, isTrue);
      expect(updated.imageId, equals('image123'));
    });
  });
}
