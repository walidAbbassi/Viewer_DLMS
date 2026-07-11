import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'generated/authentication.pbgrpc.dart';

abstract class IAuthenticationClient {
  Future<ConnexionResponse> connexion(String username, String password);
  Future<ChangePasswordResponse> changePassword(String username, String oldPassword, String newPassword,String license);
  Future<bool> importLicense(String licensePath);
  Future<CheckLicenseResponse> checkLicense();
  Future<void> deleteLicenses(String username, String password);
}

@visibleForTesting
IAuthenticationClient Function() connexionClientFactory = () => AuthenticationClient();

class AuthenticationClient implements IAuthenticationClient {
  final String host;
  final int port;

  late final ClientChannel _channel;
  late final  AuthenticationServiceClient _stub;

  AuthenticationClient({
    this.host = '127.0.0.1',
    this.port = 50051,
  }) {
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _stub = AuthenticationServiceClient(_channel);
  }
  Future<bool>  importLicense(String licensePath) async { // coverage:ignore-start
      final resp = await _stub.importLicense(ImportLicenseRequest()..licensePath =licensePath );
      return resp.success;
  } // coverage:ignore-end

  Future<ConnexionResponse>  connexion(String username, String password) async { // coverage:ignore-start
      final resp = await _stub.connexion(ConnexionRequest()..username=username..password=password );
      return resp;
  } // coverage:ignore-end

  Future<ChangePasswordResponse>  changePassword(String username, String oldPassword,String newPassword,String license) async { // coverage:ignore-start
      final resp = await _stub.changePassword(ChangePasswordRequest()..username=username..oldPassword=oldPassword..newPassword=newPassword..license=license );
      return resp;
  } // coverage:ignore-end


  Future<CheckLicenseResponse>  checkLicense() async { // coverage:ignore-start
      final resp = await _stub.checkLicense(Empty() );
      return resp;
  } // coverage:ignore-end

  Future<void> deleteLicenses(String username, String password) async { 
    // coverage:ignore-start
    await _stub.deleteLicenses(DeleteLicensesRequest()..username=username..password=password );

  }
    
}