import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/media_comparator.dart';
import 'package:movie_nest/features/media/presentation/ui/compare_field_widget.dart';

class SyncMediaDialog extends ConsumerStatefulWidget {
  const SyncMediaDialog({
    super.key,
    required this.original,
    required this.fromServer,
  });
  final Media original;
  final Media fromServer;

  @override
  ConsumerState<SyncMediaDialog> createState() => _SyncMediaDialogState();
}

class _SyncMediaDialogState extends ConsumerState<SyncMediaDialog> {
  late MediaDto dto;
  late final MediaComparator comparator;
  int approvedCount = 0;

  @override
  void initState() {
    super.initState();
    comparator = MediaComparator(widget.original, widget.fromServer);
    _setDto();
  }

  @override
  Widget build(BuildContext context) {
    final isScreenSmall = MediaQuery.of(context).size.width < 600;
    final theme = ref.watch(themeProvider).value!;
    return AlertDialog(
      constraints: const BoxConstraints.expand(width: 500),
      actionsPadding: const EdgeInsets.all(15),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.only(top: 16, left: 8, right: 8),
      backgroundColor: theme.secBackC2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.borderC),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYNC', style: theme.mainSmallBold),
          Text('Review Updates', style: theme.bigBold),
          Text(
            '${comparator.changesCount} changes found for "${widget.original.title}"',
            style: theme.secSmall,
          ),
        ],
      ),
      content: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.borderC, width: 1),
                    top: BorderSide(color: theme.borderC, width: 1),
                  ),
                ),
                child: Flex(
                  direction: isScreenSmall ? Axis.vertical : Axis.horizontal,
                  spacing: 5,
                  mainAxisAlignment: isScreenSmall
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: isScreenSmall
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    // Text(
                    //   '0 of ${comparator.changesCount} Approved',
                    //   style: theme.secSmallBold,
                    // ),
                    // if (!isScreenSmall) const Spacer(),
                    Row(
                      spacing: 5,
                      children: [
                        NestButton(
                          onTap: () {
                            _toggleAllAproval(true);
                          },
                          text: 'Accept All',
                          backC: theme.secBackC,
                          textC: theme.textC,
                          borderC: theme.borderC,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          fontSize: 12,
                        ),
                        NestButton(
                          onTap: () {
                            _toggleAllAproval(false);
                          },
                          text: 'Reject All',
                          backC: theme.secBackC,
                          textC: theme.textC,
                          borderC: theme.borderC,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CompareFieldWidget(
                originalField: widget.original.title,
                serverField: widget.fromServer.title,
                dtoField: dto.title,
                name: 'Title',
                isDifferent: comparator.title,
                setField: (field) {
                  dto.title = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.originalTitle,
                serverField: widget.fromServer.originalTitle,
                dtoField: dto.originalTitle,
                name: 'Original Title',
                isDifferent: comparator.originalTitle,
                setField: (field) {
                  dto.originalTitle = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.description,
                serverField: widget.fromServer.description,
                dtoField: dto.description,
                name: 'Description',
                isDifferent: comparator.description,
                setField: (field) {
                  dto.description = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.tag,
                serverField: widget.fromServer.tag,
                dtoField: dto.tag,
                name: 'Tag',
                isDifferent: comparator.tag,
                setField: (field) {
                  dto.tag = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.status,
                serverField: widget.fromServer.status,
                dtoField: dto.status,
                name: 'Status',
                isDifferent: comparator.status,
                setField: (field) {
                  dto.status = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.rating,
                serverField: widget.fromServer.rating,
                dtoField: dto.rating,
                name: 'Rating',
                isDifferent: comparator.rating,
                setField: (field) {
                  dto.rating = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.runTime,
                serverField: widget.fromServer.runTime,
                dtoField: dto.runTime,
                name: 'Run Time',
                isDifferent: comparator.runTime,
                setField: (field) {
                  dto.runTime = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.posterUrl,
                serverField: widget.fromServer.posterUrl,
                dtoField: dto.posterUrl,
                name: 'Poster URL',
                isDifferent: comparator.posterUrl,
                setField: (field) {
                  dto.posterUrl = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.date,
                serverField: widget.fromServer.date,
                dtoField: dto.date,
                fieldToString: _dateToString,
                name: 'Date',
                isDifferent: comparator.date,
                setField: (field) {
                  dto.date = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.end,
                serverField: widget.fromServer.end,
                dtoField: dto.end,
                fieldToString: _dateToString,
                name: 'End',
                isDifferent: comparator.end,
                setField: (field) {
                  dto.end = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.genres,
                serverField: widget.fromServer.genres,
                dtoField: dto.genres,
                fieldToString: (field) => field.join(', '),
                name: 'Genres',
                isDifferent: comparator.genres,
                setField: (field) {
                  dto.genres = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.episodeCount,
                serverField: widget.fromServer.episodeCount,
                dtoField: dto.episodeCount,
                name: 'Episode Count',
                isDifferent: comparator.episodeCount,
                setField: (field) {
                  dto.episodeCount = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.seasonCount,
                serverField: widget.fromServer.seasonCount,
                dtoField: dto.seasonCount,
                name: 'Season Count',
                isDifferent: comparator.seasonCount,
                setField: (field) {
                  dto.seasonCount = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.lastAirDate,
                serverField: widget.fromServer.lastAirDate,
                dtoField: dto.lastAirDate,
                fieldToString: _dateToString,
                name: 'Last Air Date',
                isDifferent: comparator.lastAirDate,
                setField: (field) {
                  dto.lastAirDate = field;
                  setState(() {});
                },
              ),
              CompareFieldWidget(
                originalField: widget.original.nextAirDate,
                serverField: widget.fromServer.nextAirDate,
                dtoField: dto.nextAirDate,
                fieldToString: _dateToString,
                name: 'Next Air Date',
                isDifferent: comparator.nextAirDate,
                setField: (field) {
                  dto.nextAirDate = field;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: theme.mainSmallBold),
        ),
        NestButton(
          onTap: () {
            Navigator.pop(context, dto);
          },
          text: 'Save',
          backC: theme.mainC,
          textC: theme.backC,
        ),
      ],
    );
  }

  String _dateToString(dynamic date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _setDto() {
    dto = MediaDto(
      id: widget.original.id,
      seasonsDto: widget.original.seasons
          .map(
            (s) => SeasonDto(
              number: s.number,
              fieldsVersion: s.fieldsVersion ?? {},
            ),
          )
          .toList(),
      fieldsVersion: widget.original.fieldsVersion ?? {},
    );
  }

  void _toggleAllAproval(bool acceptServer) {
    dto.title = acceptServer ? widget.fromServer.title : widget.original.title;

    dto.originalTitle = acceptServer
        ? widget.fromServer.originalTitle
        : widget.original.originalTitle;

    dto.description = acceptServer
        ? widget.fromServer.description
        : widget.original.description;

    dto.tag = acceptServer ? widget.fromServer.tag : widget.original.tag;

    dto.status = acceptServer
        ? widget.fromServer.status
        : widget.original.status;

    dto.rating = acceptServer
        ? widget.fromServer.rating
        : widget.original.rating;

    dto.runTime = acceptServer
        ? widget.fromServer.runTime
        : widget.original.runTime;

    dto.posterUrl = acceptServer
        ? widget.fromServer.posterUrl
        : widget.original.posterUrl;

    dto.date = acceptServer ? widget.fromServer.date : widget.original.date;

    dto.end = acceptServer ? widget.fromServer.end : widget.original.end;

    dto.genres = acceptServer
        ? widget.fromServer.genres
        : widget.original.genres;

    dto.episodeCount = acceptServer
        ? widget.fromServer.episodeCount
        : widget.original.episodeCount;

    dto.seasonCount = acceptServer
        ? widget.fromServer.seasonCount
        : widget.original.seasonCount;

    dto.lastAirDate = acceptServer
        ? widget.fromServer.lastAirDate
        : widget.original.lastAirDate;

    dto.nextAirDate = acceptServer
        ? widget.fromServer.nextAirDate
        : widget.original.nextAirDate;

    setState(() {});
  }
}
