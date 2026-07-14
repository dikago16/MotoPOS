import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../activation/activation_screen.dart';
import '../selling/selling_screen.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kTxtLow = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E3A5F);
const _kMuted = Color(0xFF334155);
// ──────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _spotCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _spotAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLicense();
  }

  // ── Animations ──────────────────────────────────────────────────────────────
  void _initAnimations() {
    // Fade-in semua konten
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Spotlight sweep dari kiri ke kanan
    _spotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _spotAnim = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _spotCtrl, curve: Curves.easeInOut));

    _loopSpotlight();
  }

  Future<void> _loopSpotlight() async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      while (mounted) {
        await _spotCtrl.forward(from: 0.0);
        if (!mounted) break;
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (_) {
      // Ticker dibatalkan saat widget di-dispose
    }
  }

  // ── License check (logika asli tidak berubah) ────────────────────────────────
  Future<void> _checkLicense() async {
    await Future.delayed(const Duration(seconds: 4));
    final result = await ActivationService.validateLicense();
    if (!mounted) return;

    if (result['success'] == true) {
      if (result['is_offline'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SellingScreen()),
      );
    } else {
      if (result['is_invalid'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ActivationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _spotCtrl.dispose();
    super.dispose();
  }

  // ── Spotlight shader: beam warna putih menyapu dari kiri ke kanan ────────────
  Shader _buildSpotlightShader(Rect bounds) {
    final pos = _spotAnim.value;
    const beamRadius = 0.22; // lebar beam spotlight (lebih kecil = lebih fokus)
    const numStops = 18;

    final stops = List<double>.generate(numStops, (i) => i / (numStops - 1));
    final colors = stops.map((s) {
      final dist = (s - pos).abs();
      final t = (1.0 - dist / beamRadius).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(t);
      return Color.lerp(const Color(0xFF253E57), Colors.white, eased)!;
    }).toList();

    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: stops,
      colors: colors,
    ).createShader(bounds);
  }

  // ── Widget teks DX-BYTES dengan efek spotlight ───────────────────────────────
  Widget _buildSpotlightText() {
    return AnimatedBuilder(
      animation: _spotAnim,
      builder: (_, _) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: _buildSpotlightShader,
        child: const Text(
          'DX-BYTES',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 10.0,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  // ── Divider aksen dengan titik tengah ────────────────────────────────────────
  Widget _buildAccentDivider() {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kAccent.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kAccent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kAccent.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build utama ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // ── Latar: dot grid pattern ──────────────────────────────────────────
          CustomPaint(size: size, painter: const _DotGridPainter()),

          // ── Radial glow di tengah layar ──────────────────────────────────────
          Positioned.fill(
            child: Center(
              child: IgnorePointer(
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _kAccent.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Corner brackets di keempat sudut ─────────────────────────────────
          for (final corner in _CornerPos.values)
            Positioned(
              top: corner.isTop ? 48 : null,
              bottom: corner.isTop ? null : 48,
              left: corner.isLeft ? 48 : null,
              right: corner.isLeft ? null : 48,
              child: Transform.scale(
                scaleX: corner.isLeft ? 1.0 : -1.0,
                scaleY: corner.isTop ? 1.0 : -1.0,
                child: const _CornerBracket(color: _kBorder),
              ),
            ),

          // ── Konten utama ─────────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // ── DX-BYTES dengan efek sorotan lampu ───────────────────────
                  _buildSpotlightText(),

                  const SizedBox(height: 14),

                  // ── Badge "ENTERPRISE SOFTWARE" ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _kAccent.withValues(alpha: 0.30),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      color: _kAccent.withValues(alpha: 0.05),
                    ),
                    child: const Text(
                      'ENTERPRISE EDITION',
                      style: TextStyle(
                        fontSize: 9,
                        color: _kTxtLow,
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Garis aksen ──────────────────────────────────────────────
                  _buildAccentDivider(),

                  const SizedBox(height: 38),

                  // ── Nama aplikasi ────────────────────────────────────────────
                  const Text(
                    'MotoPOS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 3.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Motorcycle Service  ·  Point of Sales',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kTxtLow,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Indikator loading ────────────────────────────────────────
                  const _LoadingDots(),

                  const SizedBox(height: 14),

                  const Text(
                    'VALIDATING  LICENSE',
                    style: TextStyle(
                      color: _kMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Copyright footer ─────────────────────────────────────────
                  Text(
                    '© ${DateTime.now().year}  DX-BYTES  ·  All rights reserved',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF1E3A55),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Corner Position Enum ──────────────────────────────────────────────────────
enum _CornerPos {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  bool get isTop => this == _CornerPos.topLeft || this == _CornerPos.topRight;
  bool get isLeft =>
      this == _CornerPos.topLeft || this == _CornerPos.bottomLeft;
}

// ─── Corner Bracket Widget ─────────────────────────────────────────────────────
class _CornerBracket extends StatelessWidget {
  final Color color;
  const _CornerBracket({required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(26, 26),
    painter: _CornerBracketPainter(color: color),
  );
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  const _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Bracket pojok kiri-atas → dua sisi: vertikal dan horizontal
    canvas.drawLine(Offset(0, size.height * 0.55), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(size.width * 0.55, 0), paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) => old.color != color;
}

// ─── Dot Grid Background ───────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF14263A)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.85, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

// ─── Animated Loading Dots (berurutan) ────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final _controllers = <AnimationController>[];
  final _anims = <Animation<double>>[];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      );
      _controllers.add(ctrl);
      _anims.add(
        Tween<double>(
          begin: 0.18,
          end: 1.0,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut)),
      );
    }

    _runLoop();
  }

  Future<void> _runLoop() async {
    try {
      while (mounted) {
        for (int i = 0; i < _controllers.length; i++) {
          if (!mounted) return;
          _controllers[i].forward(from: 0.0);
          await Future.delayed(const Duration(milliseconds: 155));
        }
        await Future.delayed(const Duration(milliseconds: 460));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, _) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kAccent.withValues(alpha: _anims[i].value),
            ),
          ),
        );
      }),
    );
  }
}
