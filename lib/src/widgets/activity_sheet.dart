import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:activity_tracker/src/models/activity.dart';
import 'package:activity_tracker/src/screens/booking_screen.dart';

class ActivityDetailsSheet extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsSheet({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            Expanded(
              child: _buildContent(context),
            ),
            _buildStickyFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCloseButton(context),
            _buildHeaderImage(),
            const SizedBox(height: 20),
            _buildTitleSection(context),
            const SizedBox(height: 16),
            _buildMetaInfoSection(context),
            const SizedBox(height: 24),
            _buildDescriptionSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: () => Navigator.pop(context),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: CupertinoColors.systemGrey5,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.xmark,
            size: 18,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        activity.imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: CupertinoColors.systemGrey5,
            child: const Center(
              child: CupertinoActivityIndicator(radius: 14),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: CupertinoColors.systemGrey5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(CupertinoIcons.photo,
                  size: 40, color: CupertinoColors.systemGrey),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Image not available',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          activity.category.toString().split('.').last,
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSection(context),
        const SizedBox(height: 16),
        _buildAgeRangeSection(context),
        const SizedBox(height: 16),
        _buildPriceSection(context),
        const SizedBox(height: 16),
        _buildDurationSection(context),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: CupertinoColors.systemYellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.star_fill,
                  size: 16, color: CupertinoColors.systemYellow),
              const SizedBox(width: 6),
              Text(
                activity.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${activity.reviewCount} reviews',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeRangeSection(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.person_2, size: 16),
        const SizedBox(width: 8),
        Text(
          'Ages ${activity.ageRange.minAge}-${activity.ageRange.maxAge}',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.money_dollar_circle, size: 16),
        const SizedBox(width: 8),
        Text(
          '${activity.price.basePrice} ETB',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        if (activity.price.discountPrice != null) ...[
          const SizedBox(width: 8),
          Text(
            '${activity.price.discountPrice} ETB',
            style: const TextStyle(
              color: CupertinoColors.systemGreen,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationSection(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.clock, size: 16),
        const SizedBox(width: 8),
        Text(
          '${activity.duration.inHours} hour${activity.duration.inHours > 1 ? 's' : ''}',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          activity.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(vertical: 16),
          pressedOpacity: 0.7,
          child: const Text(
            'Book Now',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => BookingScreen(activity: activity),
              ),
            );
          },
        ),
      ),
    );
  }
}
