import 'package:libkoala/providers/api_provider.dart';

final teamsProvider = getListDataProvider(
  endpoint: '/teams?year=2024',   // <-- use a year that actually has data
  forceRefresh: true,
);


