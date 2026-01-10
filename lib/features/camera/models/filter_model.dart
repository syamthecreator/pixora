import 'package:pixora/core/constants/app_filters.dart';

class FilterModel {
  final String key;
  final String name;
  final String image;

  FilterModel({required this.key, required this.name, required this.image});
}

class FilterModelList {
  static List<FilterModel> filters = [
    FilterModel(
      key: "CINEMATIC",
      name: "Cinematic",
      image: AppFilters.cinematic,
    ),
    FilterModel(key: "WARM_GLOW", name: "Warm Glow", image: AppFilters.vintage),
    FilterModel(key: "URBAN_POP", name: "Urban Pop", image: AppFilters.natural),
    FilterModel(
      key: "SOFT_FILM",
      name: "Soft Film",
      image: AppFilters.cinematic,
    ),
    FilterModel(key: "VIVID_POP", name: "Vivid Pop", image: AppFilters.moody),
  ];
}
