import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/resources/app_colors.dart';
import '../../../core/resources/app_values.dart';

class TrailerWidget extends StatefulWidget {
  final String trailerUrl;

  const TrailerWidget({
    super.key,
    required this.trailerUrl,
  });

  @override
  State<TrailerWidget> createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    String videoUrl = widget.trailerUrl;
    if (videoUrl.isEmpty || videoUrl == '') {
      videoUrl = 'https://www.youtube.com/watch?v=d9MyW72ELq0';
      print('Using static fallback video URL: $videoUrl');
    }
    
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    
    if (videoId != null && videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          hideControls: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
        ),
      )..addListener(() {
          if (_isPlayerReady && mounted) {
            setState(() {});
          }
        });
    } else {
      _controller = YoutubePlayerController(
        initialVideoId: 'd9MyW72ELq0',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          hideControls: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
        ),
      )..addListener(() {
          if (_isPlayerReady && mounted) {
            setState(() {});
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
            vertical: AppPadding.p12,
          ),
          child: Text(
            'Trailer',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.s12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.s12),
            child: YoutubePlayerBuilder(
              onExitFullScreen: () {},
              player: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.primary,
                  handleColor: AppColors.primary,
                ),
                onReady: () {
                  _isPlayerReady = true;
                },
                onEnded: (data) {},
              ),
              builder: (context, player) => player,
            ),
          ),
        ),
        const SizedBox(height: AppSize.s16),
      ],
    );
  }
}
