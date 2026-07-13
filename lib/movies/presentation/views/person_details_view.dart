import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/section_listview_card.dart';
import '../../../core/presentation/components/section_title.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../core/domain/entities/media.dart';
import '../../domain/entities/person_details.dart';
import '../controllers/person_details_bloc/person_details_bloc.dart';
import '../controllers/person_details_bloc/person_details_event.dart';
import '../controllers/person_details_bloc/person_details_state.dart';

class PersonDetailsView extends StatelessWidget {
  final int personId;

  const PersonDetailsView({
    super.key,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PersonDetailsBloc>()..add(GetPersonDetailsEvent(personId)),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(
              top: AppPadding.p12,
              left: AppPadding.p16,
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(AppPadding.p8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.iconContainerColor,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.secondaryText,
                  size: AppSize.s20,
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<PersonDetailsBloc, PersonDetailsState>(
          builder: (context, state) {
            switch (state.status) {
              case RequestStatus.loading:
                return const LoadingIndicator();
              case RequestStatus.loaded:
                return PersonDetailsWidget(personDetails: state.personDetails!);
              case RequestStatus.error:
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context
                        .read<PersonDetailsBloc>()
                        .add(GetPersonDetailsEvent(personId));
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class PersonDetailsWidget extends StatelessWidget {
  const PersonDetailsWidget({
    required this.personDetails,
    super.key,
  });

  final PersonDetails personDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and basic info
          Stack(
            children: [
              // Background image with gradient
              ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.5, 0.7, 1.0],
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                blendMode: BlendMode.dstIn,
                child: ImageWithShimmer(
                  imageUrl: personDetails.imageUrl,
                  width: double.infinity,
                  height: AppSize.s400,
                ),
              ),
              // Content overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppPadding.p16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personDetails.name,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSize.s8),
                      Text(
                        personDetails.gender,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Personal Information
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSize.s16),
                if (personDetails.birthday != null)
                  _buildInfoRow(
                    'Birthday',
                    personDetails.birthday!,
                    textTheme,
                  ),
                if (personDetails.deathday != null)
                  _buildInfoRow(
                    'Deathday',
                    personDetails.deathday!,
                    textTheme,
                  ),
                if (personDetails.country != null)
                  _buildInfoRow(
                    'Country',
                    personDetails.country!,
                    textTheme,
                  ),
              ],
            ),
          ),

          // Known For
          if (personDetails.castCredits.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Known For'),
                SizedBox(
                  height: AppSize.s240,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: personDetails.castCredits.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSize.s10),
                    itemBuilder: (context, index) {
                      final credit = personDetails.castCredits[index];
                      return SectionListViewCard(
                        media: Media(
                          tmdbID: credit.showId,
                          title: credit.showName,
                          posterUrl: credit.showImageUrl ?? '',
                          backdropUrl: '',
                          overview: credit.characterName ?? '',
                          voteAverage: 0,
                          releaseDate: '',
                          isMovie: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSize.s16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSize.s16),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
