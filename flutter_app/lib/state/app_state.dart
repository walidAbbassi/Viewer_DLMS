class FirmwareUpgrade {
  final int blockSize;
  final int blocksNumber;
  final bool isInitiated;
  final String imageId;
  // Download progress persistence (survives page navigation after cancel)
  final String? filePath;
  final String? fileName;
  final int fileSize;
  final int transferredBlocks;
  final int totalBlocks;
  final bool isCancelled;
  const FirmwareUpgrade({
    this.blockSize = 0,
    this.blocksNumber = 0,
    this.isInitiated = false,
    this.imageId = '',
    this.filePath,
    this.fileName,
    this.fileSize = 0,
    this.transferredBlocks = 0,
    this.totalBlocks = 0,
    this.isCancelled = false,
  });

  FirmwareUpgrade copyWith(
          {int? blockSize,
          int? blocksNumber,
          bool? isInitiated,
          String? imageId,
          String? filePath,
          String? fileName,
          int? fileSize,
          int? transferredBlocks,
          int? totalBlocks,
          bool? isCancelled}) =>
      FirmwareUpgrade(
          blockSize: blockSize ?? this.blockSize,
          blocksNumber: blocksNumber ?? this.blocksNumber,
          isInitiated: isInitiated ?? this.isInitiated,
          imageId: imageId ?? this.imageId,
          filePath: filePath ?? this.filePath,
          fileName: fileName ?? this.fileName,
          fileSize: fileSize ?? this.fileSize,
          transferredBlocks: transferredBlocks ?? this.transferredBlocks,
          totalBlocks: totalBlocks ?? this.totalBlocks,
          isCancelled: isCancelled ?? this.isCancelled);
}

class AppState {
  final String? moduleName;
  final String? datamodel;
  final bool isConnected;
  final FirmwareUpgrade firmwareUpgrade;
  final bool simulation;
  final String? simulationFile;
  final bool isAuthenticated;
  final String? userRole;
  final bool isSideNavOpen;
  final bool isFirmwareDownloading;
  final bool isMeterOperationInProgress;

  /// Number of active background processes (firmware download, export, etc.).
  /// The HDLC idle timer is paused whenever this counter is greater than zero.
  final int activeBackgroundProcesses;
  const AppState({
    this.moduleName,
    this.datamodel,
    this.isConnected = false,
    this.firmwareUpgrade = const FirmwareUpgrade(),
    this.simulation = false,
    this.simulationFile,
    this.isAuthenticated = false,
    this.userRole,
    this.isSideNavOpen = true,
    this.isFirmwareDownloading = false,
    this.activeBackgroundProcesses = 0,
    this.isMeterOperationInProgress = false,
  });

  AppState copyWith({
    bool? isConnected,
    Object? moduleName = _undefined,
    Object? datamodel = _undefined,
    FirmwareUpgrade? firmwareUpgrade,
    bool? simulation,
    Object? simulationFile = _undefined,
    bool? isAuthenticated,
    Object? userRole = _undefined,
    bool? isSideNavOpen,
    bool? isFirmwareDownloading,
    int? activeBackgroundProcesses,
    bool? isMeterOperationInProgress,
  }) =>
      AppState(
        isConnected: isConnected ?? this.isConnected,
        moduleName:
            moduleName == _undefined ? this.moduleName : moduleName as String?,
        datamodel:
            datamodel == _undefined ? this.datamodel : datamodel as String?,
        firmwareUpgrade: firmwareUpgrade ?? this.firmwareUpgrade,
        simulation: simulation ?? this.simulation,
        simulationFile: simulationFile == _undefined
            ? this.simulationFile
            : simulationFile as String?,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        userRole: userRole == _undefined ? this.userRole : userRole as String?,
        isSideNavOpen: isSideNavOpen ?? this.isSideNavOpen,
        isFirmwareDownloading:
            isFirmwareDownloading ?? this.isFirmwareDownloading,
        activeBackgroundProcesses:
            activeBackgroundProcesses ?? this.activeBackgroundProcesses,
        isMeterOperationInProgress:
            isMeterOperationInProgress ?? this.isMeterOperationInProgress,
      );
}

const _undefined = Object();
