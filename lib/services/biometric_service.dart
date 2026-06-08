import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometric() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
      await _auth.getAvailableBiometrics();

      debugPrint('BIO isSupported: $isSupported');
      debugPrint('BIO canCheckBiometrics: $canCheckBiometrics');
      debugPrint('BIO availableBiometrics: $availableBiometrics');

      return isSupported || canCheckBiometrics || availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('BIO canUseBiometric PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('BIO canUseBiometric error: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool canUse = await canUseBiometric();

      if (!canUse) {
        debugPrint('BIO authenticate stopped: device cannot use biometric/local auth.');
        return false;
      }

      final bool result = await _auth.authenticate(
        localizedReason: 'Gunakan biometric atau kunci layar untuk masuk.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      debugPrint('BIO authenticate result: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('BIO authenticate PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('BIO authenticate error: $e');
      return false;
    }
  }
}