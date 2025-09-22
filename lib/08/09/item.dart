import 'package:flutter/material.dart';

class SpecialColumnItem {
  final String url;
  final String title;
  final int articleCount;
  final int attentionCount;

  SpecialColumnItem({
    required this.url,
    required this.title,
    required this.articleCount,
    required this.attentionCount,
  });
}

class SpecialColumn extends StatelessWidget {
  final SpecialColumnItem item;

  const SpecialColumn({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildTitle(), _buildFoot()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item.title,
          style: const TextStyle(fontSize: 16, color: Color(0xff2F3032)),
        ),
        const Icon(Icons.more_horiz, size: 20, color: Color(0xff8D8D8D)),
      ],
    );
  }

  Widget _buildFoot() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        Text(
          '${item.articleCount} articles',
          style: const TextStyle(
            fontSize: 12,
            height: 1,
            color: Color(0xff86909c),
          ),
        ),
        Container(
          width: 2,
          height: 2,
          decoration: const BoxDecoration(
            color: Color(0xff86909c),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          '${item.attentionCount} followers',
          style: const TextStyle(
            fontSize: 12,
            height: 1,
            color: Color(0xff86909c),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          item.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}
