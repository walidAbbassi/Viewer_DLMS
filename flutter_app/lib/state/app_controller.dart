import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';

class AppController extends StateNotifier<AppState> {
  AppController() : super(const AppState());

  void setModuleName(String? name) => state = state.copyWith(moduleName: name);

  void setDatamodel(String? name) => state = state.copyWith(datamodel: name);

  void setBlockSize(int size) => state = state.copyWith(
      firmwareUpgrade: state.firmwareUpgrade.copyWith(blockSize: size));

  void setBlocksNumber(int n) => state = state.copyWith(
      firmwareUpgrade: state.firmwareUpgrade.copyWith(blocksNumber: n));

  void setInitiated(bool v) => state = state.copyWith(
      firmwareUpgrade: state.firmwareUpgrade.copyWith(isInitiated: v));

  void setIsConnected(bool v) => state = state.copyWith(isConnected: v);

  void setFirmwareDownloading(bool v) =>
      state = state.copyWith(isFirmwareDownloading: v);

  /// Sets whether a meter communication or data retrieval operation
  /// while this flag is true to avoid interrupting the meter connection.
  void setMeterOperationInProgress(bool v) =>
      state = state.copyWith(isMeterOperationInProgress: v);

  /// Increments the background-process counter, pausing the HDLC idle timer.
  /// Call at the start of any long-running operation without user interaction
  /// (firmware transfer, bulk export, etc.).
  void beginBackgroundProcess() => state = state.copyWith(
        activeBackgroundProcesses: state.activeBackgroundProcesses + 1,
      );

  /// Decrements the background-process counter. The HDLC idle timer resumes
  /// automatically once the counter reaches zero.
  void endBackgroundProcess() => state = state.copyWith(
        activeBackgroundProcesses:
            (state.activeBackgroundProcesses - 1).clamp(0, 1 << 31),
      );

  void setImageId(String v) => state = state.copyWith(
      firmwareUpgrade: state.firmwareUpgrade.copyWith(imageId: v));

  /// Persists the current download progress so it can be restored when the
  /// user returns to the Firmware Download page after a cancel.
  void saveFirmwareProgress({
    required String? filePath,
    required String? fileName,
    required int fileSize,
    required int transferredBlocks,
    required int totalBlocks,
  }) =>
      state = state.copyWith(
        firmwareUpgrade: state.firmwareUpgrade.copyWith(
          filePath: filePath,
          fileName: fileName,
          fileSize: fileSize,
          transferredBlocks: transferredBlocks,
          totalBlocks: totalBlocks,
          isCancelled: true,
        ),
      );

  /// Clears the persisted download progress (e.g. on reset or new file
  /// selection).
  void clearFirmwareProgress() => state = state.copyWith(
        firmwareUpgrade: state.firmwareUpgrade.copyWith(
          transferredBlocks: 0,
          totalBlocks: 0,
          isCancelled: false,
        ),
      );
  void setSimulation(bool v) => state = state.copyWith(simulation: v);

  void setSimulationFile(String? file) =>
      state = state.copyWith(simulationFile: file);

  void setSideNavOpen(bool v) => state = state.copyWith(isSideNavOpen: v);

  void resetFirmware() =>
      state = state.copyWith(firmwareUpgrade: const FirmwareUpgrade());

  void resetAll() => state = const AppState();
}

final appControllerProvider =
    StateNotifierProvider<AppController, AppState>((ref) => AppController());
