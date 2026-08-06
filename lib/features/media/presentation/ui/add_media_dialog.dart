import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/add_seasons_section.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_date_picker.dart';
import 'package:movie_nest/core/widgets/nest_drop_down.dart';
import 'package:movie_nest/core/widgets/nest_input.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:uuid/uuid.dart';

class AddMediaDialog extends ConsumerStatefulWidget {
  const AddMediaDialog({super.key, this.media});
  final Media? media;

  @override
  ConsumerState<AddMediaDialog> createState() => _AddMediaDialogState();
}

class _AddMediaDialogState extends ConsumerState<AddMediaDialog> {
  late final MediaDto _dto;
  late final TextEditingController _titleController;
  late final TextEditingController _originalTitleController;
  late final TextEditingController _tmdbIdController;
  late final TextEditingController _tagController;
  late final TextEditingController _ratingController;
  late final TextEditingController _runtimeController;
  late final TextEditingController _genresController;
  late final TextEditingController _descriptionController;
  late final ValueNotifier<bool> _isTv;
  late final ValueNotifier<String> _status;

  @override
  void initState() {
    _dto = MediaDto(
      id: widget.media?.id ?? const Uuid().v4(),
      seasonsDto: [],
      fieldsVersion: widget.media?.fieldsVersion ?? {},
    );
    _titleController = TextEditingController(text: widget.media?.title);
    _originalTitleController = TextEditingController(
      text: widget.media?.originalTitle,
    );
    _tmdbIdController = TextEditingController(text: widget.media?.tmdbId);
    _tagController = TextEditingController(text: widget.media?.tag);
    _ratingController = TextEditingController(
      text: widget.media?.rating.toString(),
    );
    _runtimeController = TextEditingController(
      text: widget.media?.runTime.toString(),
    );
    _genresController = TextEditingController(
      text: widget.media?.genres.join(', '),
    );
    _descriptionController = TextEditingController(
      text: widget.media?.description,
    );
    _isTv = ValueNotifier<bool>((_dto.type ?? widget.media?.type) == 'tv');
    _status = ValueNotifier<String>(
      (_dto.status ?? widget.media?.status) ?? 'Released',
    );

    super.initState();
  }

  bool get _isEditing => widget.media != null;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return AlertDialog(
      backgroundColor: theme.secBackC,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.borderC, width: 1),
      ),
      title: Text(
        _isEditing ? 'Edit Media' : 'Add Media',
        style: theme.bigBold,
      ),
      content: SizedBox(
        height: 300,
        width: 600,
        child: CustomScrollView(
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width > 800
                    ? 300
                    : 600,
                mainAxisSpacing: 10,
                mainAxisExtent: 80,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildListDelegate([
                NestInput(
                  label: 'Title',
                  isTitle: true,
                  onChanged: (value) {
                    _dto.title = value;
                  },
                  controller: _titleController,
                ),
                NestInput(
                  label: 'Original Title',
                  isTitle: true,
                  controller: _originalTitleController,
                  onChanged: (value) {
                    _dto.originalTitle = value;
                  },
                ),
                NestInput(
                  label: 'TMDB ID',
                  isTitle: true,
                  controller: _tmdbIdController,
                  onChanged: (value) {
                    _dto.tmdbId = value;
                  },
                ),
                NestInput(
                  label: 'Tag',
                  isTitle: true,
                  controller: _tagController,
                  onChanged: (value) {
                    _dto.tag = value;
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _isTv,
                  builder: (context, value, child) {
                    return NestDropDown(
                      options: const [
                        NestDropDownOption(value: 'movie', label: 'Movie'),
                        NestDropDownOption(value: 'tv', label: 'TV Show'),
                      ],
                      selected: value ? 'tv' : 'movie',
                      onChanged: (value) {
                        _dto.type = value;
                        _isTv.value = value == 'tv';
                      },
                      title: 'Type',
                    );
                  },
                ),
                // TODO default value
                ValueListenableBuilder(
                  valueListenable: _status,
                  builder: (context, value, child) {
                    return NestDropDown(
                      options: const [
                        NestDropDownOption(
                          value: 'Released',
                          label: 'Released',
                        ),
                        NestDropDownOption(
                          value: 'Returning Series',
                          label: 'Returning Series',
                        ),
                        NestDropDownOption(
                          value: 'Canceled',
                          label: 'Canceled',
                        ),
                        NestDropDownOption(value: 'Ended', label: 'Ended'),
                      ],
                      selected: value,
                      onChanged: (value) {
                        _dto.status = value;
                        _status.value = value;
                      },
                      title: 'Status',
                    );
                  },
                ),
                NestInput(
                  label: 'Rating',
                  isTitle: true,
                  keyboardType: TextInputType.number,
                  controller: _ratingController,
                  isNumber: true,
                  min: 0,
                  max: 10,
                  onChanged: (value) {
                    _dto.rating = double.tryParse(value) ?? _dto.rating;
                  },
                ),
                NestInput(
                  label: 'Episode runtime (in minutes)',
                  isTitle: true,
                  keyboardType: TextInputType.number,
                  controller: _runtimeController,
                  isNumber: true,
                  min: 0,
                  onChanged: (value) {
                    _dto.runTime = int.tryParse(value) ?? _dto.runTime;
                  },
                ),
                NestDatePicker(
                  label: 'Release Date',
                  onDateSelected: (date) {
                    _dto.date = date.toUtc();
                  },
                  value: _dto.date ?? widget.media?.date,
                ),
                NestDatePicker(
                  label: 'Date Ended',
                  onDateSelected: (date) {
                    _dto.end = date.toUtc();
                  },
                  value: _dto.end ?? widget.media?.end,
                ),
                NestDatePicker(
                  label: 'Previous Episode',
                  onDateSelected: (date) {
                    _dto.lastAirDate = date.toUtc();
                  },
                  value: _dto.lastAirDate ?? widget.media?.lastAirDate,
                ),
                NestDatePicker(
                  label: 'Next Episode',
                  onDateSelected: (date) {
                    _dto.nextAirDate = date.toUtc();
                  },
                  value: _dto.nextAirDate ?? widget.media?.nextAirDate,
                ),
              ]),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  spacing: 10,
                  children: [
                    NestInput(
                      label: 'Genres',
                      isTitle: true,
                      controller: _genresController,
                      onChanged: (value) {
                        _dto.genres = value
                            .split(', ')
                            .where((e) => e.isNotEmpty)
                            .map((e) => e.trim())
                            .toList();
                      },
                    ),
                    NestInput(
                      label: 'Description',
                      minLines: 1,
                      maxLines: null,
                      radius: 30,
                      isTitle: true,
                      controller: _descriptionController,
                      onChanged: (value) {
                        _dto.description = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: _isTv,
                builder: (context, value, child) {
                  if (value) {
                    return AddSeasonsSection(
                      mediaId: _dto.id,
                      seasons: widget.media?.seasons ?? [],
                      onSeasonsChanged: (List<SeasonDto> seasons) {
                        _dto.seasonsDto = seasons;
                        for (var season in seasons) {
                          print('checking season ${season.number}');
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.mainC),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        NestButton(
          onTap: () {
            Navigator.of(context).pop(_dto);
          },
          backC: theme.mainC,
          textC: theme.textC,
          text: 'Save',
          icon: Icons.save_outlined,
        ),
      ],
    );
  }
}
