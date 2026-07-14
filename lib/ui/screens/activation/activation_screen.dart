import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../selling/selling_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kCard = Color(0xFF0F2137);
const _kInputBg = Color(0xFF091624);
const _kAccent = Color(0xFF2563EB);
const _kAccentLt = Color(0xFF60A5FA);
const _kTxtLow = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E3A5F);
const _kMuted = Color(0xFF334155);
const _kDanger = Color(0xFFEF4444);
// ──────────────────────────────────────────────────────────────────────────────

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen>
    with SingleTickerProviderStateMixin {
  String _deviceId = 'Loading...';
  final _codeCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isFocused = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });

    _loadDeviceId();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _codeCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Logic (tidak berubah dari aslinya) ───────────────────────────────────────
  Future<void> _loadDeviceId() async {
    final id = await ActivationService.getDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  void _copyDeviceId() {
    Clipboard.setData(ClipboardData(text: _deviceId));
    _showSnack('Device ID copied to clipboard', const Color(0xFF0F2137));
  }

  Future<void> _activate() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _showSnack('Please enter your License Key', const Color(0xFF78350F));
      return;
    }

    setState(() => _isLoading = true);
    final result = await ActivationService.activateLicense(code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnack(result['message'], const Color(0xFF14532D));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SellingScreen()),
      );
    } else {
      _showSnack(
        result['message'] ?? 'Activation failed',
        const Color(0xFF7F1D1D),
      );
    }
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 13)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _kNavy,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Background: dot grid ─────────────────────────────────────────────
            CustomPaint(size: size, painter: const _DotGridPainter()),

            // ── Radial ambient glow ──────────────────────────────────────────────
            Positioned.fill(
              child: Center(
                child: IgnorePointer(
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _kAccent.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Corner brackets di 4 sudut ───────────────────────────────────────
            for (final c in _CornerPos.values)
              Positioned(
                top: c.isTop ? 22 : null,
                bottom: c.isTop ? null : 22,
                left: c.isLeft ? 22 : null,
                right: c.isLeft ? null : 22,
                child: Transform.scale(
                  scaleX: c.isLeft ? 1.0 : -1.0,
                  scaleY: c.isTop ? 1.0 : -1.0,
                  child: const _CornerBracket(color: _kBorder),
                ),
              ),

            // ── Konten utama ─────────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),
                              _buildHeader(),
                              const SizedBox(height: 10),
                              _buildSectionSeparator(),
                              const SizedBox(height: 10),
                              _buildDeviceIdCard(),
                              const SizedBox(height: 10),
                              _buildLicenseInput(),
                              const SizedBox(height: 10),
                              _buildActivateButton(),
                              const SizedBox(height: 10),
                              _buildInfoNote(),
                              const SizedBox(height: 10),
                              _buildFooter(),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: brand + status badge ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Status badge merah
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: _kDanger.withValues(alpha: 0.38),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(3),
            color: _kDanger.withValues(alpha: 0.07),
          ),
          child: const Text(
            'ACTIVATION REQUIRED',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFFFCA5A5),
              letterSpacing: 3.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Nama brand
        const Text(
          'MotoPOS',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 7.0,
            height: 1.0,
          ),
        ),

        const SizedBox(height: 10),

        // Accent divider kecil
        SizedBox(
          width: 200,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _kAccent.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Container(
                  width: 4,
                  height: 4,
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
                        _kAccent.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Produk
        const Text(
          'www.dx-bytes.com',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  // ── Garis pemisah horizontal ─────────────────────────────────────────────────
  Widget _buildSectionSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: _kBorder.withValues(alpha: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'DEVICE INFORMATION',
            style: TextStyle(
              fontSize: 8,
              color: _kMuted,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: _kBorder.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  // ── Kartu Device ID ──────────────────────────────────────────────────────────
  Widget _buildDeviceIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label baris atas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR DEVICE ID',
                style: TextStyle(
                  fontSize: 9,
                  color: _kTxtLow,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: _kAccent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'REQUIRED FOR LICENSE',
                  style: TextStyle(
                    fontSize: 8,
                    color: _kAccentLt,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Blok ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kInputBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _kBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _deviceId,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: _kAccentLt,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Copy button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _copyDeviceId,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _kBorder, width: 1),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: _kTxtLow.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 11,
                color: _kTxtLow.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Share this Device ID with DX-BYTES support to obtain a license.',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kTxtLow,
                    letterSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Input License Key ─────────────────────────────────────────────────────────
  Widget _buildLicenseInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: _kBorder.withValues(alpha: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'LICENSE KEY',
                style: TextStyle(
                  fontSize: 8,
                  color: _kMuted,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: _kBorder.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Input field dengan animated border saat fokus
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isFocused ? _kAccent : _kBorder,
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.14),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: _codeCtrl,
            focusNode: _focusNode,
            enabled: !_isLoading,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 14,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              hintStyle: TextStyle(
                color: _kMuted.withValues(alpha: 0.7),
                fontSize: 13,
                letterSpacing: 2.5,
                fontFamily: 'monospace',
              ),
              filled: true,
              fillColor: _kInputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(Icons.key_rounded, color: _kMuted, size: 18),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Format: XXXX-XXXX-XXXX-XXXX · Case insensitive',
          style: TextStyle(fontSize: 10, color: _kMuted, letterSpacing: 0.3),
        ),
      ],
    );
  }

  // ── Tombol Activate ──────────────────────────────────────────────────────────
  Widget _buildActivateButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _activate,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          disabledBackgroundColor: _kAccent.withValues(alpha: 0.35),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'ACTIVATE  LICENSE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.5,
                ),
              ),
      ),
    );
  }

  // ── Info note ────────────────────────────────────────────────────────────────
  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kAccent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kAccent.withValues(alpha: 0.13), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 14, color: _kAccentLt),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This is a licensed enterprise software. Contact WhatsApp 0851-1722-2788 for support or click link below',
                  style: TextStyle(
                    fontSize: 11,
                    color: _kTxtLow,
                    height: 1.65,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _launchWhatsApp,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 13,
                          color: Color(0xFF4ADE80),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'WhatsApp Support',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4ADE80),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer copyright ─────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Text(
      '© ${DateTime.now().year}  DX-BYTES  ·  All rights reserved',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF1E3A55),
        letterSpacing: 0.5,
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse(
      'https://wa.me/6285117222788?text=Saya%20tertarik%20dengan%20aplikasi%20MotoPOS',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
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

// ─── Corner Bracket ────────────────────────────────────────────────────────────
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
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(0, size.height * 0.55), Offset.zero, p);
    canvas.drawLine(Offset.zero, Offset(size.width * 0.55, 0), p);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) => old.color != color;
}

// ─── Dot Grid Background ───────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF14263A)
      ..style = PaintingStyle.fill;
    for (double x = 28; x < size.width; x += 28) {
      for (double y = 28; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 0.85, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}
