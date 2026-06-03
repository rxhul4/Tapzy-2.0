import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/capitlize_string.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/appConstants.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/models/delete_card_model.dart';
import 'package:tapzy/models/get_digital_card_model.dart';
import 'package:tapzy/providers/profiles_provider.dart';
import 'package:tapzy/screens/profiles/business_profile_screen.dart';
import 'package:tapzy/core/common/commonDialog.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({Key? key}) : super(key: key);

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DeleteCardModel? deleteCardModel;
  GetDigitalCardModel? getDigitalCardModel;

  ValueNotifier<bool> showNoData = ValueNotifier<bool>(false);
  ValueNotifier<bool> showNoList = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postMdl = Provider.of<ProfilesProvider>(context, listen: false);
      getDigitalCard(postMdl);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    showNoData.dispose();
    showNoList.dispose();
    super.dispose();
  }

  callDeleteApi(BuildContext ctx, ProfilesProvider postMdl1, String? cardId,
      String? cardType) async {
    postMdl1.callDeleteCardApi(cardId ?? '', cardType ?? '').then((value) {
      setState(() {
        deleteCardModel = value;
      });
      print("print ${deleteCardModel?.toJson()}");
      if (deleteCardModel?.isSuccessful == 1) {
        AppUtils.showSnackBarWithColor(
            context: ctx, message: deleteCardModel?.message ?? '');
        getDigitalCard(postMdl1);
      } else {
        AppUtils.showSnackBarWithColor(
            context: ctx,
            message: deleteCardModel?.message ?? '',
            giveColor: Colors.redAccent);
      }
    });
  }

  getDigitalCard(ProfilesProvider postMdl) {
    postMdl.callGetDigitalCardsApiProfiles().then((value) {
      print("ddddddd $value");
      setState(() {
        getDigitalCardModel = value;
      });
      if (getDigitalCardModel?.isSuccessful == 1) {
        if (getDigitalCardModel?.data?.cardData?.toList().isEmpty ?? false) {
          showNoList.value = true;
        } else {
           showNoList.value = false;
        }
        showNoData.value = false;
      } else {
        showNoList.value = false;
        showNoData.value = true;
      }
      print("Cards are here ${getDigitalCardModel?.toJson()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<ProfilesProvider>(context);

    if (postMdl.isFetching) {
      return Scaffold(
          backgroundColor: Colors.transparent, body: AppUtils.loaderWidget());
    }

    final activeCards = getDigitalCardModel?.data?.cardData
            ?.where((element) => element.isActive == 1)
            .toList() ??
        [];
    final inactiveCards = getDigitalCardModel?.data?.cardData
            ?.where((element) => element.isActive == 0)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 95),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.gradientPurple,
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPurple.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: RawMaterialButton(
            shape: const CircleBorder(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CommonDialog(selectedIndex: 1),
              );
            },
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient purple orbs
          IgnorePointer(
            child: CustomPaint(painter: _OrbPainter()),
          ),
          
          ValueListenableBuilder<bool>(
            valueListenable: showNoData,
            builder: (context, noData, _) {
              if (noData) {
                return RefreshIndicator(
                  onRefresh: () async {
                    getDigitalCard(postMdl);
                  },
                  color: AppColors.colorPurpleLight,
                  backgroundColor: AppColors.colorMainBlack,
                  child: ListView(
                     children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        AppUtils.noDataFound()
                     ]
                  )
                );
              }
              
              return ValueListenableBuilder<bool>(
                valueListenable: showNoList,
                builder: (context, noList, _) {
                   if (noList) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          getDigitalCard(postMdl);
                        },
                        color: AppColors.colorPurpleLight,
                        backgroundColor: AppColors.colorMainBlack,
                        child: ListView(
                           children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                              AppUtils.noListWidget()
                           ]
                        )
                      );
                   }
                   
                   return NestedScrollView(
                    headerSliverBuilder: (ctx, innerScrolled) => [
                      // Pinned tab bar
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
                                fontSize: 13, fontWeight: FontWeight.w700),
                            unselectedLabelStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            dividerColor: Colors.transparent,
                            tabs: [
                              _buildTab('Active', activeCards.length),
                              _buildTab('Inactive', inactiveCards.length),
                            ],
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileList(activeCards, postMdl, context),
                        _buildProfileList(inactiveCards, postMdl, context),
                      ],
                    ),
                  );
                }
              );
            }
          ),

          if (postMdl.isLoading)
            AppUtils.loaderWidget(color: AppColors.colorPurpleLight),
        ],
      ),
    );
  }

  Tab _buildTab(String label, int count) => Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.colorPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _buildProfileList(
      List<CardData> cards, ProfilesProvider postMdl, BuildContext context) {
    if (cards.isEmpty) {
      return Center(
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
              child: Icon(Icons.credit_card_off_outlined,
                  size: 32, color: AppColors.colorTextSubtle),
            ),
            const SizedBox(height: 14),
            Text('No profiles found',
                style: TextStyle(
                    color: AppColors.colorTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        getDigitalCard(postMdl);
      },
      color: AppColors.colorPurpleLight,
      backgroundColor: AppColors.colorMainBlack,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProfileCard(
              card: card,
              onEdit: () {
                if (card.type != "business") {
                  AppUtils.showSnackBarWithColor(
                      context: context,
                      giveColor: AppColors.colorGreyLatest,
                      message: "Only business profile can be edited");
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusinessProfileScreen(
                            selectedIndex: 1,
                            isView: false,
                            businessId: card.id.toString()),
                      ));
                }
              },
              onDelete: () {
                openDeleteCardDialog(
                    postMdl, card.id.toString(), card.type, context);
              },
            ),
          );
        },
      ),
    );
  }

  void openDeleteCardDialog(ProfilesProvider postMdl1, String? cardId,
      String? cardType, BuildContext ctx1) {
    ConfirmationDialog.showDeleteProfile(
      context: context,
      onConfirm: () => callDeleteApi(ctx1, postMdl1, cardId, cardType),
    );
  }
}

// ─── Profile Card ────────────────────────────
class _ProfileCard extends StatelessWidget {
  final CardData card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfileCard({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isActive => card.isActive == 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12), blurRadius: 12)
        ],
      ),
      child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Profile
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.colorMainBlack.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: (card.cardImage == null || card.cardImage!.isEmpty || card.isImageSet != 1)
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            AppUtils.setIconByType(card.type ?? ''),
                            fit: BoxFit.contain,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: card.cardImage!,
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.colorPurple,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              AppUtils.setIconByType(card.type ?? ''),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${card.type.toString().toCapitalize()} Card",
                      style: TextStyle(
                        color: AppColors.colorOffWhite,
                        fontSize: 14,
                        fontFamily: StringUtils.fontFamilyHeading,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (card.field1 != null && card.field1!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13,
                              color: AppColors.colorTextMuted.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              card.field1!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.colorTextMuted,
                                fontSize: 11,
                                fontFamily: StringUtils.fontFamilyPara,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 2),
                    if (card.field2 != null && card.field2!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.domain_rounded,
                              size: 13,
                              color: AppColors.colorTextMuted.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              card.field2!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.colorTextMuted,
                                fontSize: 11,
                                fontFamily: StringUtils.fontFamilyPara,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: card.type == "business"
                        ? Icons.edit_outlined
                        : Icons.edit_off_outlined,
                    color: card.type == "business"
                        ? AppColors.colorBlueAccent
                        : AppColors.colorTextMuted.withOpacity(0.5),
                    onTap: onEdit,
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent.withOpacity(0.9),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, size: 16, color: color),
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

// ─── Pinned tab bar delegate ─────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08), width: 1),
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
