import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();

    return canCheckBiometrics && isDeviceSupported;
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Use sua biometria para acessar o Cheguei.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
