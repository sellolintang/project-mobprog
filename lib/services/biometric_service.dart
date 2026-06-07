import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometric() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
      await _auth.getAvailableBiometrics();

      return isSupported &&
          canCheckBiometrics &&
          availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool canUse = await canUseBiometric();

      if (!canUse) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Gunakan biometric untuk masuk ke aplikasi.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}