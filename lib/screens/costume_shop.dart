import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/pet.dart';
import '../models/user.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/plush_button.dart';

class CostumeShop extends StatelessWidget {
  const CostumeShop({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<UserProgress>();

    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, progress),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: CostumeInfo.all.length,
                itemBuilder: (context, index) {
                  return _CostumeCard(costume: CostumeInfo.all[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProgress progress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _PlushIconButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: CatWiseTheme.plushShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: CatWiseTheme.candyPink, size: 24),
                const SizedBox(width: 6),
                Text(
                  '${progress.totalCandies}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CatWiseTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlushIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PlushIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: CatWiseTheme.plushShadow,
        ),
        child: Icon(icon, size: 24, color: CatWiseTheme.textSecondary),
      ),
    );
  }
}

class _CostumeCard extends StatefulWidget {
  final CostumeInfo costume;

  const _CostumeCard({required this.costume});

  @override
  State<_CostumeCard> createState() => _CostumeCardState();
}

class _CostumeCardState extends State<_CostumeCard> {
  @override
  Widget build(BuildContext context) {
    final progress = context.watch<UserProgress>();
    final isOwned = progress.ownedCostumes.contains(widget.costume.id);
    final isActive = progress.activeCostume == widget.costume.id;
    final canBuy = !isOwned && progress.totalCandies >= widget.costume.price;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? CatWiseTheme.warmHoney.withOpacity(0.3)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(CatWiseTheme.plushRadius),
        boxShadow: CatWiseTheme.plushShadow,
        border: isActive
            ? Border.all(color: CatWiseTheme.warmHoney, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CatAvatar(
            mood: CatMood.happy,
            size: 80,
            costumeId: widget.costume.id,
          ),
          const SizedBox(height: 8),
          Text(
            widget.costume.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CatWiseTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: CatWiseTheme.successGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Надето',
                style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          else if (isOwned)
            _ShopButton(
              label: 'Надеть',
              color: CatWiseTheme.warmHoney,
              onTap: () {
                progress.activeCostume = widget.costume.id;
                progress.notifyListeners();
                progress.save();
              },
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded, color: CatWiseTheme.candyPink, size: 16),
                    const SizedBox(width: 4),
                    Text('${widget.costume.price}', style: const TextStyle(fontSize: 13, color: CatWiseTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                _ShopButton(
                  label: 'Купить',
                  color: canBuy ? CatWiseTheme.successGreen : CatWiseTheme.textSecondary.withOpacity(0.3),
                  onTap: canBuy
                      ? () {
                          progress.buyCostume(widget.costume.id);
                        }
                      : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ShopButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ShopButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
