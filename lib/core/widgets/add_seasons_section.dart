import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_input.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';
import 'package:movie_nest/features/media/data/models/season.dart';

class AddSeasonsSection extends ConsumerStatefulWidget {
  const AddSeasonsSection({
    super.key,
    required this.mediaId,
    required this.onSeasonsChanged,
    required this.seasons,
  });
  final String mediaId;
  final List<Season> seasons;
  final Function(List<SeasonDto>) onSeasonsChanged;

  @override
  ConsumerState<AddSeasonsSection> createState() => _AddSeasonsSectionState();
}

class _AddSeasonsSectionState extends ConsumerState<AddSeasonsSection> {
  final _dtos = <SeasonDto>[];
  final _seasonByNumber = <int, Season>{};
  final _controllerByNumber = <int, TextEditingController>{};

  int seasonCountWithoutSpecial = 0;
  int episodeCountWithoutSpecial = 0;
  int specialEpisodes = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.seasons.length; i++) {
      final season = widget.seasons[i];
      if (season.number != 0) {
        seasonCountWithoutSpecial++;
        episodeCountWithoutSpecial += season.episodeCount;
      } else {
        specialEpisodes += season.episodeCount;
      }
      _seasonByNumber[season.number] = season;
      _controllerByNumber[season.number] = TextEditingController(
        text: season.episodeCount.toString(),
      );
      _dtos.add(
        SeasonDto(
          number: season.number,
          media: widget.mediaId,
          fieldsVersion: season.fieldsVersion ?? {},
        ),
      );
    }
    widget.onSeasonsChanged(_dtos);
  }

  @override
  void dispose() {
    for (final controller in _controllerByNumber.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isSmallScreen => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(_isSmallScreen ? 10 : 20),
      decoration: BoxDecoration(
        color: theme.backC,
        border: Border.all(color: theme.borderC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Flex(
            spacing: 5,
            crossAxisAlignment: _isSmallScreen
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            direction: _isSmallScreen ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: _isSmallScreen ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seasons'.toUpperCase(),
                      style: theme.bold.copyWith(letterSpacing: 2.5),
                    ),
                    Text(
                      '$seasonCountWithoutSpecial Seasons $episodeCountWithoutSpecial Episodes',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.secSmallBold,
                    ),
                    if (specialEpisodes > 0)
                      Text(
                        '$specialEpisodes Special Episodes',
                        style: theme.secSmallBold,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: _isSmallScreen
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                spacing: 5,
                children: [
                  NestButton(
                    onTap: () {
                      _dtos.add(
                        SeasonDto(
                          number: ++seasonCountWithoutSpecial,
                          media: widget.mediaId,
                          episodeCount: 1,
                          fieldsVersion: {},
                        ),
                      );
                      _controllerByNumber[seasonCountWithoutSpecial] =
                          TextEditingController(text: '1');
                      widget.onSeasonsChanged(_dtos);
                      setState(() {});
                    },
                    icon: Icons.add,
                    text: 'Add Season',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  if (specialEpisodes <= 0)
                    NestButton(
                      onTap: () {
                        specialEpisodes++;
                        _dtos.insert(
                          0,
                          SeasonDto(
                            number: 0,
                            media: widget.mediaId,
                            episodeCount: 1,
                            fieldsVersion: {},
                          ),
                        );
                        _controllerByNumber[0] = TextEditingController(
                          text: '1',
                        );
                        widget.onSeasonsChanged(_dtos);
                        setState(() {});
                      },
                      icon: Icons.add,
                      text: 'Add Special Season',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._dtos.map(_seasonEditWidget),
        ],
      ),
    );
  }

  Widget _seasonEditWidget(SeasonDto dto) {
    final theme = ref.watch(themeProvider).value!;
    return Container(
      padding: _isSmallScreen
          ? const EdgeInsets.all(5)
          : const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.secBackC,
        borderRadius: BorderRadius.circular(_isSmallScreen ? 6 : 999),
      ),
      child: Flex(
        direction: _isSmallScreen ? Axis.vertical : Axis.horizontal,
        children: [
          Row(
            children: [
              Text(
                'Season ${dto.number}'.toUpperCase(),
                style: theme.secSmallBold,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  removeSeason(dto);
                },
                icon: Icon(Icons.close, color: theme.errorC),
              ),
            ],
          ),
          Expanded(
            flex: _isSmallScreen ? 0 : 1,
            child: NestInput(
              showNumberButtons: true,
              label: 'Episodes',
              isNumber: true,
              min: 1,
              onChanged: (value) {
                final old =
                    dto.episodeCount ??
                    _seasonByNumber[dto.number]?.episodeCount ??
                    0;
                dto.episodeCount =
                    double.tryParse(value)?.toInt() ?? dto.episodeCount;
                if (dto.number != 0) {
                  episodeCountWithoutSpecial += (dto.episodeCount ?? 0) - old;
                } else {
                  specialEpisodes = dto.episodeCount ?? specialEpisodes;
                }
                widget.onSeasonsChanged(_dtos);
                setState(() {});
              },
              controller: _controllerByNumber[dto.number]!,
            ),
          ),
        ],
      ),
    );
  }

  void removeSeason(SeasonDto dto) {
    _dtos.remove(dto);
    if (dto.number == 0) {
      specialEpisodes = 0;
    } else {
      episodeCountWithoutSpecial -=
          dto.episodeCount ?? _seasonByNumber[dto.number]?.episodeCount ?? 0;
      seasonCountWithoutSpecial--;
      for (var i = 0; i < _dtos.length; i++) {
        if (_dtos[i].number > dto.number) {
          if (_seasonByNumber.containsKey(_dtos[i].number)) {
            _dtos[i].number--;
            _seasonByNumber[_dtos[i].number] =
                _seasonByNumber[_dtos[i].number + 1]!.copyWithDto(_dtos[i]);
            _dtos[i] = _seasonByNumber[_dtos[i].number]!.toDto();
            _controllerByNumber[_dtos[i].number] = TextEditingController(
              text: _dtos[i].episodeCount.toString(),
            );
          } else {
            _dtos[i].number--;
          }
        }
      }
    }
    widget.onSeasonsChanged(_dtos);
    setState(() {});
  }
}
