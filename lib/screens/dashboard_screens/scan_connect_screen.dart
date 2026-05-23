import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/core/utils/card_scanner_helper.dart';
import 'package:tapzy/models/scanned_contact.dart';
import 'package:tapzy/providers/scan_connect_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';
import 'package:tapzy/screens/dashboard_screens/camera_capture_screen.dart';

class ScanConnectScreen extends StatefulWidget {
  const ScanConnectScreen({Key? key}) : super(key: key);

  @override
  State<ScanConnectScreen> createState() => _ScanConnectScreenState();
}

class _ScanConnectScreenState extends State<ScanConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanConnectProvider>().fetchSharedContacts(filter: 'all');
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filter = _getFilterForIndex(_tabController.index);
        context.read<ScanConnectProvider>().fetchSharedContacts(filter: filter);
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final filter = _getFilterForIndex(_tabController.index);
        context.read<ScanConnectProvider>().fetchSharedContacts(
              filter: filter,
              searchKeyword: _searchController.text,
            );
      }
    });
    setState(() => _search = _searchController.text);
  }

  String _getFilterForIndex(int index) {
    switch (index) {
      case 1:
        return 'scanned';
      case 2:
        return 'received';
      default:
        return 'all';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanConnectProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: _ScanCardFab(onTap: () => _showScanDialog(context)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient purple orbs
          IgnorePointer(
            child: CustomPaint(painter: _OrbPainter()),
          ),
          NestedScrollView(
            headerSliverBuilder: (ctx, innerScrolled) => [
              // ── Collapsible: search bar (floats away on scroll) ──
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                floating: true,
                snap: true,
                elevation: 0,
                toolbarHeight: 64,
                flexibleSpace: _GlassBar(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: _SearchField(
                      controller: _searchController,
                      search: _search,
                    ),
                  ),
                ),
              ),

              // ── Pinned: tab bar ──
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabBar: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppColors.gradientPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.colorWhite,
                    unselectedLabelColor: AppColors.colorTextMuted,
                    labelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    dividerColor: Colors.transparent,
                    tabs: [
                      _buildTab('All'),
                      _buildTab('Scanned'),
                      _buildTab('Received'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _TabContent(
                  contacts: provider.allContacts,
                  filter: 'all',
                  provider: provider,
                  onEdit: (c) => _openEdit(context, c, provider),
                ),
                _TabContent(
                  contacts: provider.scannedContacts,
                  filter: 'scanned',
                  provider: provider,
                  onEdit: (c) => _openEdit(context, c, provider),
                ),
                _TabContent(
                  contacts: provider.receivedContacts,
                  filter: 'received',
                  provider: provider,
                  onEdit: null,
                ),
              ],
            ),
          ),
          if (provider.isLoading)
            Container(
              color: Colors.black26,
              child: AppUtils.loaderWidget(),
            ),
        ],
      ),
    );
  }

  void _openEdit(
      BuildContext context, ScannedContact c, ScanConnectProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditContactSheet(
        contact: c,
        onSave: (updated) async {
          int contactId = int.tryParse(updated.id) ?? 0;
          final response = await provider.editSharedContact(
            contactId: contactId,
            name: updated.name,
            company: updated.company ?? '',
            email: updated.email ?? '',
            phone: updated.phone ?? '',
            address: updated.address ?? '',
          );
          if (response.isSuccessful == 1) {
            // Refresh contact listings
            provider.fetchSharedContacts(filter: 'all');
            provider.fetchSharedContacts(filter: 'scanned');
            provider.fetchSharedContacts(filter: 'received');

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response.message ?? 'Contact updated successfully'),
              backgroundColor: AppColors.colorPurple,
            ));
            return true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response.message ?? 'Failed to update contact'),
              backgroundColor: Colors.redAccent,
            ));
            return false;
          }
        },
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ScanCardDialog(),
    );
  }

  Tab _buildTab(String label) => Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
          ],
        ),
      );
}

// ─── Scan Card Dialog ────────────────────────
class _ScanCardDialog extends StatefulWidget {
  const _ScanCardDialog();

  @override
  State<_ScanCardDialog> createState() => _ScanCardDialogState();
}

class _ScanCardDialogState extends State<_ScanCardDialog> {
  File? _frontImage;
  File? _backImage;
  List<String>? _frontText;
  List<String>? _backText;
  bool _isFrontLoading = false;
  bool _isBackLoading = false;
  bool _isSubmitting = false;

  Future<void> _pickImage(bool isFront) async {
    final String? pickedPath = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
    if (pickedPath == null) return;

    setState(() {
      if (isFront) {
        _isFrontLoading = true;
      } else {
        _isBackLoading = true;
      }
    });

    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(File(pickedPath));
      final recognized = await recognizer.processImage(inputImage);
      final lines = recognized.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      await recognizer.close();

      setState(() {
        if (isFront) {
          _frontImage = File(pickedPath);
          _frontText = lines;
          _isFrontLoading = false;
        } else {
          _backImage = File(pickedPath);
          _backText = lines;
          _isBackLoading = false;
        }
      });
    } catch (_) {
      setState(() {
        if (isFront) {
          _isFrontLoading = false;
        } else {
          _isBackLoading = false;
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<ScanConnectProvider>();
      final result = await provider.scanPaperCard(
        frontOcr: _frontText ?? [],
        backOcr: _backText ?? [],
      );

      setState(() => _isSubmitting = false);

      if (result.isSuccessful == 1) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.message ?? 'Card scanned successfully!'),
            backgroundColor: AppColors.colorPurple,
          ));
          // Refresh the contacts list
          provider.fetchSharedContacts(filter: 'all');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.message ?? 'Failed to scan card.'),
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = _frontImage != null &&
        !_isFrontLoading &&
        !_isBackLoading &&
        !_isSubmitting;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: GlassContainer(
        borderRadius: 28,
        blur: 24,
        opacity: 0.08,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.colorPurple.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.colorPurple.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.document_scanner_rounded,
                        color: AppColors.colorPurple, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Scan Business Card',
                    style: TextStyle(
                      color: AppColors.colorOffWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.colorTextMuted, size: 20),
                  onPressed: _isFrontLoading || _isBackLoading || _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Instruction
            Text(
              'Capture both sides of your business card for best results',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorTextMuted,
                fontSize: 12.5,
                height: 1.4,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),

            // Image previews
            Row(
              children: [
                Expanded(
                  child: _ImagePreview(
                    label: 'Front Card Side',
                    image: _frontImage,
                    isLoading: _isFrontLoading,
                    onTap: () => _pickImage(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImagePreview(
                    label: 'Back Card Side\n(Optional)',
                    image: _backImage,
                    isLoading: _isBackLoading,
                    onTap: () => _pickImage(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Submit button
            GestureDetector(
              onTap: isButtonEnabled ? _submit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isButtonEnabled ? AppColors.gradientPurple : null,
                  color: !isButtonEnabled ? Colors.white.withOpacity(0.04) : null,
                  borderRadius: BorderRadius.circular(14),
                  border: !isButtonEnabled
                      ? Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 0.8,
                        )
                      : null,
                  boxShadow: isButtonEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.colorPurple.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: _isSubmitting
                      ? AppUtils.loaderWidget(
                          size: 22, color: AppColors.colorWhite)
                      : Text(
                          'Continue',
                          style: TextStyle(
                            color: isButtonEnabled
                                ? AppColors.colorWhite
                                : AppColors.colorTextMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image preview card ──────────────────────
class _ImagePreview extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onTap;
  final bool isLoading;

  const _ImagePreview({
    required this.label,
    this.image,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: GlassContainer(
        height: 160,
        borderRadius: 18,
        blur: 20,
        opacity: 0.05,
        padding: EdgeInsets.zero,
        border: Border.all(
          color: image != null
              ? AppColors.colorPurple.withOpacity(0.5)
              : Colors.white.withOpacity(0.08),
          width: 1,
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.colorPurple,
                  strokeWidth: 2,
                ),
              )
            : image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.file(image!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.colorPurple.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_a_photo_rounded,
                          color: AppColors.colorPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.colorTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ─── Scan Card FAB ───────────────────────────
class _ScanCardFab extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanCardFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPurple,
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorPurple.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.document_scanner_rounded,
                    color: AppColors.colorWhite, size: 20),
                SizedBox(width: 10),
                Text(
                  'Scan Card',
                  style: TextStyle(
                    color: AppColors.colorWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ambient orb background ──────────────────
class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.shader = RadialGradient(colors: [
      AppColors.colorPurple.withOpacity(0.18),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.08), radius: 180));
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.08), 180, paint);

    paint.shader = RadialGradient(colors: [
      AppColors.colorPurpleLight.withOpacity(0.12),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.25), radius: 140));
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.25), 140, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => false;
}

// ─── Frosted glass wrapper ───────────────────
class _GlassBar extends StatelessWidget {
  final Widget child;

  const _GlassBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Colors.white.withOpacity(0.08),
            //     Colors.white.withOpacity(0.03),
            //   ],
            // ),
            border: Border(
              bottom:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 0.8),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Search field ────────────────────────────
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String search;

  const _SearchField({required this.controller, required this.search});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.colorOffWhite, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: TextStyle(color: AppColors.colorTextMuted, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.colorPurple.withOpacity(0.7), size: 18),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIcon: search.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 15, color: AppColors.colorTextMuted),
                  onPressed: () => controller.clear(),
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ─── Pinned tab bar delegate ─────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Colors.white.withOpacity(0.08),
            //     Colors.white.withOpacity(0.03),
            //   ],
            // ),
            border: Border(
              bottom:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 0.8),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.1), width: 0.8),
            ),
            child: tabBar,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}

class _TabContent extends StatelessWidget {
  final List<ScannedContact> contacts;
  final String filter;
  final ScanConnectProvider provider;
  final void Function(ScannedContact)? onEdit;

  const _TabContent({
    required this.contacts,
    required this.filter,
    required this.provider,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchSharedContacts(filter: filter),
      color: AppColors.colorPurple,
      backgroundColor: AppColors.colorCard,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200) {
            provider.fetchSharedContacts(filter: filter, isLoadMore: true);
          }
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: _ContactList(
                contacts: contacts,
                onDelete: (id) => provider.deleteScannedContact(id),
                onEdit: onEdit,
                isLoading: provider.isLoading,
              ),
            ),
            if (provider.isPaginating)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.colorPurple,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Contact list ────────────────────────────
class _ContactList extends StatelessWidget {
  final List<ScannedContact> contacts;
  final void Function(String id)? onDelete;
  final void Function(ScannedContact)? onEdit;
  final bool isLoading;

  const _ContactList({
    required this.contacts,
    this.onDelete,
    this.onEdit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    if (contacts.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: constraints.maxHeight,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.colorGreyLatest,
                    border: Border.all(color: AppColors.colorBorder),
                  ),
                  child: Icon(Icons.people_alt_outlined,
                      size: 32, color: AppColors.colorTextSubtle),
                ),
                const SizedBox(height: 14),
                Text('No contacts yet',
                    style: TextStyle(
                        color: AppColors.colorTextMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      itemCount: contacts.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ContactCard(
          contact: contacts[i],
          onDelete: onDelete != null ? () => onDelete!(contacts[i].id) : null,
          onEdit: contacts[i].source == ContactSource.scanned && onEdit != null
              ? () => onEdit!(contacts[i])
              : null,
        ),
      ),
    );
  }
}

// ─── Contact card ────────────────────────────
class _ContactCard extends StatelessWidget {
  final ScannedContact contact;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _ContactCard({required this.contact, this.onDelete, this.onEdit});

  String get _initials {
    final cleanName = contact.name.trim();
    if (cleanName.isEmpty) return '?';
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    final initials = '$first$second'.toUpperCase();
    return initials.isNotEmpty ? initials : '?';
  }

  String get _date {
    final dt = contact.dateTime;
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  bool get _isScanned => contact.source == ContactSource.scanned;

  Future<void> _saveToContacts(BuildContext context) async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saving to device contacts is only supported on mobile devices.'),
            backgroundColor: Colors.amber));
      }
      return;
    }
    try {
      if (!await FlutterContacts.requestPermission()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Contacts permission denied'),
              backgroundColor: Colors.redAccent));
        }
        return;
      }
      final c = contact;
      final nc = Contact()
        ..name = Name(first: c.name)
        ..phones = c.phone != null ? [Phone(c.phone!)] : []
        ..emails = c.email != null ? [Email(c.email!)] : []
        ..organizations = (c.company != null || c.designation != null)
            ? [
                Organization(
                    company: c.company ?? '', title: c.designation ?? '')
              ]
            : []
        ..addresses = c.address != null ? [Address(c.address!)] : [];
      await FlutterContacts.insertContact(nc);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${c.name} saved'),
            backgroundColor: AppColors.colorPurple));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to save contact'),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: avatar + info + badge ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.colorPurple.withOpacity(0.4),
                            AppColors.colorPurpleLight.withOpacity(0.25),
                          ],
                        ),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                      child: Center(
                        child: _initials == "?"
                            ? Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              )
                            : Text(_initials,
                                style: const TextStyle(
                                    color: AppColors.colorWhite,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name,
                              style: const TextStyle(
                                  color: AppColors.colorOffWhite,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700)),
                          if (contact.designation != null ||
                              contact.company != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                [contact.designation, contact.company]
                                    .where((s) => s != null)
                                    .join(' · '),
                                style: const TextStyle(
                                    color: AppColors.colorTextMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          if (contact.email?.isNotEmpty?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                children: [
                                  Icon(Icons.email_outlined,
                                      size: 11,
                                      color: AppColors.colorTextSubtle),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(contact.email ?? '',
                                        style: const TextStyle(
                                            color: AppColors.colorTextMuted,
                                            fontSize: 11.5),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          if (contact.address?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 11,
                                      color: AppColors.colorTextSubtle),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(contact.address ?? '',
                                        style: const TextStyle(
                                            color: AppColors.colorTextMuted,
                                            fontSize: 11.5),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Badge + date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SourceBadge(isScanned: _isScanned),
                        const SizedBox(height: 4),
                        Text(_date,
                            style: const TextStyle(
                                color: AppColors.colorTextSubtle,
                                fontSize: 10)),
                      ],
                    ),
                  ],
                ),

                // ── Divider ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),

                // ── Action row ──
                Row(
                  children: [
                    if (contact.phone != null)
                      _ActionBtn(
                        icon: Icons.phone_rounded,
                        label: contact.phone!,
                        onTap: () =>
                            launchUrl(Uri.parse('tel:${contact.phone}')),
                      ),
                    const Spacer(),
                    _IconAction(
                      icon: Icons.person_add_alt_1_rounded,
                      color: AppColors.colorPurple,
                      tooltip: 'Save to contacts',
                      onTap: () => _saveToContacts(context),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 6),
                      _IconAction(
                        icon: Icons.edit_outlined,
                        color: AppColors.colorPurpleLight,
                        tooltip: 'Edit',
                        onTap: onEdit!,
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 6),
                      _IconAction(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.colorError,
                        tooltip: 'Delete',
                        onTap: () => _confirmDelete(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Delete contact?',
      message: 'Remove "${contact.name}" from your contacts?',
      confirmText: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
      onConfirm: () => onDelete!(),
    );
  }
}

// ─── Source badge ────────────────────────────
class _SourceBadge extends StatelessWidget {
  final bool isScanned;

  const _SourceBadge({required this.isScanned});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.colorPurpleLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.colorPurpleLight.withOpacity(0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            size: 9,
            color: AppColors.colorTextMuted,
          ),
          const SizedBox(width: 3),
          Text(
            isScanned ? 'Scanned' : 'Received',
            style: TextStyle(
              color: AppColors.colorTextMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action pill button ──────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.colorPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: AppColors.colorPurple.withOpacity(0.3), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.colorPurple),
            const SizedBox(width: 5),
            Flexible(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.colorOffWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Icon action button ──────────────────────
class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction(
      {required this.icon,
      required this.color,
      required this.tooltip,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 0.8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

// ─── Edit contact bottom sheet ───────────────
class _EditContactSheet extends StatefulWidget {
  final ScannedContact contact;
  final Future<bool> Function(ScannedContact) onSave;

  const _EditContactSheet({required this.contact, required this.onSave});

  @override
  State<_EditContactSheet> createState() => _EditContactSheetState();
}

class _EditContactSheetState extends State<_EditContactSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _company;
  late final TextEditingController _address;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _name = TextEditingController(text: c.name);
    _phone = TextEditingController(text: c.phone ?? '');
    _email = TextEditingController(text: c.email ?? '');
    _company = TextEditingController(text: c.company ?? '');
    _address = TextEditingController(text: c.address ?? '');
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (_errorMessage != null && _name.text.trim().length >= 2) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _company.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Name is required';
      });
      return;
    }
    if (name.length < 2) {
      setState(() {
        _errorMessage = 'Name must be at least 2 characters';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await widget.onSave(ScannedContact(
      id: widget.contact.id,
      name: name,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      company: _company.text.trim().isEmpty ? null : _company.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      designation: widget.contact.designation,
      source: ContactSource.scanned,
      dateTime: widget.contact.dateTime,
    ));
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.colorCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.colorBorderBright,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.colorPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.colorPurple, size: 16),
                ),
                const SizedBox(width: 10),
                const Text('Edit Contact',
                    style: TextStyle(
                        color: AppColors.colorOffWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 18),
            _Field(label: 'Name *', controller: _name),
            const SizedBox(height: 10),
            _Field(
                label: 'Phone',
                controller: _phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            _Field(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _Field(label: 'Company', controller: _company),
            const SizedBox(height: 10),
            _Field(label: 'Address', controller: _address),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.colorError, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.colorError,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.colorBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: AppColors.colorTextMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? AppUtils.loaderWidget(
                            size: 20, color: AppColors.colorWhite)
                        : const Text('Save',
                            style: TextStyle(
                                color: AppColors.colorWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Text field ──────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _Field(
      {required this.label, required this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.colorOffWhite, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.colorTextMuted, fontSize: 12),
        filled: true,
        fillColor: AppColors.colorGreyLatest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.colorPurple, width: 1.5),
        ),
      ),
    );
  }
}
