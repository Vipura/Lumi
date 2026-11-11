import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/providers.dart';

/// Covers app content when Biometric Lock is enabled in Settings.
class BiometricLockGate extends ConsumerStatefulWidget {
  const BiometricLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends ConsumerState<BiometricLockGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _unlocked = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool get _platformSupportsBiometric =>
      !kIsWeb && defaultTargetPlatform != TargetPlatform.linux;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final enabled = ref.read(settingsControllerProvider).biometricLockEnabled;
    if (!enabled || !_platformSupportsBiometric) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      setState(() => _unlocked = false);
    } else if (state == AppLifecycleState.resumed && !_unlocked) {
      _authenticate();
    }
  }

  Future<void> _checkInitialAuth() async {
    final enabled = ref.read(settingsControllerProvider).biometricLockEnabled;
    if (!enabled || !_platformSupportsBiometric) {
      _unlocked = true;
      return;
    }
    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        if (mounted) {
          setState(() {
            _unlocked = true;
            _authenticating = false;
          });
        }
        return;
      }
      final didAuth = await _auth.authenticate(
        localizedReason: 'Unlock Lumi to access your notes and plans',
      );
      if (mounted) {
        setState(() {
          _unlocked = didAuth;
          _authenticating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _authenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(settingsControllerProvider).biometricLockEnabled;
    if (!enabled || !_platformSupportsBiometric || _unlocked) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: LumiBackground(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(LumiSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: LumiGlass(
                    blur: 20,
                    elevated: true,
                    grouped: false,
                    padding: const EdgeInsets.all(LumiSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LumiLogo(size: 72),
                        const SizedBox(height: LumiSpacing.md),
                        Text(
                          'Lumi is locked',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: LumiSpacing.xs),
                        Text(
                          'Verify with Face ID, Touch ID, or device passcode.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: LumiSpacing.lg),
                        LumiGlassButton(
                          label: 'Unlock',
                          primary: true,
                          expanded: true,
                          isLoading: _authenticating,
                          icon: Icons.lock_open_rounded,
                          onPressed: _authenticate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
