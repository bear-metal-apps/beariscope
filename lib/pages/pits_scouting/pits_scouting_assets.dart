import 'package:flutter/material.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_widgets.dart';
import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

class PitsScoutingTeamCard extends StatelessWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;
  final ValueChanged<bool> onScoutedChanged;

  const PitsScoutingTeamCard({
    super.key,
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
    required this.onScoutedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BeariscopeCard(
      title: teamName,
      subtitle: '$teamNumber',
      trailing: Text(
        scouted ? 'Scouted' : 'Not Scouted',
        style: TextStyle(
          color: scouted ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => _ScoutingSubmitPage(
                  teamNumber: teamNumber,
                  teamName: teamName,
                  scouted: scouted,
                ),
          ),
        );

        if (result != null && result == true) {
          onScoutedChanged(true);
        }
      },
    );
  }
}

class _ScoutingSubmitPage extends ConsumerStatefulWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;

  const _ScoutingSubmitPage({
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
  });

  @override
  ConsumerState<_ScoutingSubmitPage> createState() =>
      _ScoutingSubmitPageState();
}

class _ScoutingSubmitPageState extends ConsumerState<_ScoutingSubmitPage> {
  final pitsDataProvider = getListDataProvider(endpoint: '/scout/ingest');

  final TextEditingController _hopperSizeTEC = TextEditingController();
  String _motorType = '';
  String _drivetrainType = '';
  String _swerveBrand = '';
  final TextEditingController _swerveGRTEC = TextEditingController();
  String _wheelType = '';
  final TextEditingController _chassisLengthTEC = TextEditingController();
  final TextEditingController _chassisWidthTEC = TextEditingController();
  final TextEditingController _chassisHeightTEC = TextEditingController();
  final TextEditingController _horizontalExtensionTEC = TextEditingController();
  final TextEditingController _verticalExtensionTEC = TextEditingController();
  final TextEditingController _botWeightTEC = TextEditingController();
  String _climbMethod = '';
  Set<String> _climbType = <String>{};
  Set<String> _climbLevel = <String>{};
  double _climbConsistency = 0;
  String _autoClimb = '';
  Set<String> _fuelCollectionLocation = <String>{};
  Set<String> _playingStyle = <String>{};
  String _trenchCapability = '';
  String _pathwayPreference = '';
  String _shooter = '';
  String _collectorType = '';
  final TextEditingController _fuelOuttakeRateTEC = TextEditingController();
  double _accuracy = 0;
  Set<String> _mobileShooting = <String>{};
  Set<String> _rangeFromField = <String>{};
  String _indexerType = '';
  String _powered = '';
  String _jackArm = '';
  final TextEditingController _notesTEC = TextEditingController();

  @override
  void dispose() {
    _hopperSizeTEC.dispose();
    _swerveGRTEC.dispose();
    _chassisLengthTEC.dispose();
    _chassisWidthTEC.dispose();
    _chassisHeightTEC.dispose();
    _horizontalExtensionTEC.dispose();
    _verticalExtensionTEC.dispose();
    _botWeightTEC.dispose();
    _fuelOuttakeRateTEC.dispose();
    _notesTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pitsDataAsync = ref.watch(pitsDataProvider);
    return pitsDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => Center(
            child: FilledButton(
              onPressed: () => ref.invalidate(pitsDataProvider),
              child: const Text('Retry'),
            ),
          ),
      data: (data) {
        final List<Map<String, dynamic>> allData =
        List<Map<String, dynamic>>.from(data);

        final teamData = allData.where((entry) =>
        entry["Category"] == "Pits" &&
            entry["Team Name"] == widget.teamName &&
            entry["Team Number"] == widget.teamNumber
        ).toList();

        Map<String, dynamic>? latestTeamData;
        if (teamData.isNotEmpty) {
          latestTeamData = teamData.reduce((a, b) =>
          (a["Version"] ?? 0) > (b["Version"] ?? 0) ? a : b);
        }

        if (widget.scouted && latestTeamData != null) {
          _hopperSizeTEC.text =
              latestTeamData["Hopper Size (Max. Fuel Quantity)"]?.toString() ?? '';

          _motorType = latestTeamData["Motor Type"] ?? '';
          _drivetrainType = latestTeamData["Drivetrain Type"] ?? '';
          _swerveBrand = latestTeamData["Swerve Brand"] ?? '';
          _swerveGRTEC.text = latestTeamData["Swerve Gear Ratio"]?.toString() ?? '';
          _wheelType = latestTeamData["Wheel Type"] ?? '';

          _chassisLengthTEC.text =
              latestTeamData["Chassis Length (in)"]?.toString() ?? '';
          _chassisWidthTEC.text =
              latestTeamData["Chassis Width (in)"]?.toString() ?? '';
          _chassisHeightTEC.text =
              latestTeamData["Chassis Height (in)"]?.toString() ?? '';

          _horizontalExtensionTEC.text =
              latestTeamData["Horizontal Extension Limit (in)"]?.toString() ?? '';
          _verticalExtensionTEC.text =
              latestTeamData["Vertical Extension Limit (in)"]?.toString() ?? '';

          _botWeightTEC.text = latestTeamData["Weight (lbs)"]?.toString() ?? '';

          _climbMethod = latestTeamData["Climb Method"] ?? '';
          _climbType = Set<String>.from(latestTeamData["Climb Type"] ?? []);
          _climbLevel = Set<String>.from(latestTeamData["Climb Level"] ?? []);
          _climbConsistency = (latestTeamData["Climb Consistency"] ?? 0).toDouble();

          _autoClimb = latestTeamData["Auto Climb"] ?? '';
          _fuelCollectionLocation =
          Set<String>.from(latestTeamData["Fuel Collection Location"] ?? []);

          _pathwayPreference = latestTeamData["Pathway Preference"] ?? '';
          _playingStyle = Set<String>.from(latestTeamData["Playing Style"] ?? []);

          _trenchCapability = latestTeamData["Trench Capability"] ?? '';
          _shooter = latestTeamData["Shooter"] ?? '';
          _collectorType = latestTeamData["Collector Type"] ?? '';

          _fuelOuttakeRateTEC.text =
              latestTeamData["Fuel Outtake Rate/sec"]?.toString() ?? '';

          _accuracy = (latestTeamData["Average Accuracy %"] ?? 0).toDouble();
          _mobileShooting =
          Set<String>.from(latestTeamData["Move While Shooting"] ?? []);
          _rangeFromField =
          Set<String>.from(latestTeamData["Range From Field"] ?? []);

          _indexerType = latestTeamData["Indexer Type"] ?? '';
          _powered = latestTeamData["Powered"] ?? '';
          _jackArm = latestTeamData["Jack Arm"] ?? '';

          _notesTEC.text = latestTeamData["Additional Comments / Weaknesses"] ?? '';
        }


        return Scaffold(
          appBar: AppBar(
            title: Text('Scouting ${widget.teamNumber}: ${widget.teamName}'),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Text(
                      style: TextStyle(fontSize: 25, fontFamily: 'Xolonium'),
                      'Bot',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    child: NumberTextField(
                      labelText: 'Hopper Size (Max. Fuel Quantity)',
                      controller: _hopperSizeTEC,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: [
                        'X60',
                        'X44',
                        'Neo Vortex',
                        'Neo',
                        'Falcon',
                        'Other',
                      ],
                      label: 'Motor Type',
                      variable: _motorType,
                      onChanged: (value) => _motorType = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: ['Swerve', 'Tank', 'Mecanum'],
                      label: 'Drivetrain Type',
                      variable: _drivetrainType,
                      onChanged: (value) => _drivetrainType = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: [
                        'REV',
                        'WCP',
                        'SCS',
                        'Thrifty Bot',
                        'Andymark',
                        'No Swerve',
                      ],
                      label: 'Swerve Brand',
                      variable: _swerveBrand,
                      onChanged: (value) => _swerveBrand = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: TextField(
                      controller: _swerveGRTEC,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Swerve Gear Ratio (If none, type 0)',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: [
                        'Colson',
                        'Pneumatic',
                        'Spike',
                        'Billet',
                        'Other',
                      ],
                      label: 'Wheel Type',
                      variable: _wheelType,
                      onChanged: (value) => _wheelType = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 30, height: 10),
                        Expanded(
                          flex: 3,
                          child: NumberTextField(
                            labelText: 'Chassis Length (in)',
                            controller: _chassisLengthTEC,
                          ),
                        ),
                        Expanded(child: SizedBox(height: 10)),
                        Expanded(
                          flex: 3,
                          child: NumberTextField(
                            labelText: 'Chassis Width (in)',
                            controller: _chassisWidthTEC,
                          ),
                        ),
                        Expanded(child: SizedBox(height: 10)),
                        Expanded(
                          flex: 3,
                          child: NumberTextField(
                            labelText: 'Chassis Height (in)',
                            controller: _chassisHeightTEC,
                          ),
                        ),
                        SizedBox(width: 30, height: 10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 30, height: 10),
                        Expanded(
                          flex: 3,
                          child: NumberTextField(
                            labelText: 'Horizontal Extension Limit (in)',
                            controller: _horizontalExtensionTEC,
                          ),
                        ),
                        Expanded(child: SizedBox(height: 10)),
                        Expanded(
                          flex: 3,
                          child: NumberTextField(
                            labelText: 'Vertical Extension Limit (in)',
                            controller: _verticalExtensionTEC,
                          ),
                        ),
                        SizedBox(width: 30, height: 10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    child: NumberTextField(
                      labelText: 'Weight (lbs)',
                      controller: _botWeightTEC,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Text(
                      style: TextStyle(fontSize: 25, fontFamily: 'Xolonium'),
                      'Climb',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RadioButton(
                      options: ['Rotation', 'Elevator', 'Arm', 'No Climb'],
                      height: 200,
                      variable: _climbMethod,
                      onChanged: (value) => _climbMethod = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: MultipleChoice(
                      options: ['Buzzer Beater', 'Level 1', 'Level 3', 'Flip'],
                      label: 'Climb Type',
                      variable: _climbType,
                      onSelectionChanged: (value) => _climbType = value,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: MultipleChoice(
                      options: ['Level 1', 'Level 2', 'Level 3'],
                      variable: _climbLevel,
                      onSelectionChanged: (value) => _climbLevel = value,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: SegmentedSlider(
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: 'Climb Consistency out of 10',
                      variable: _climbConsistency,
                      onChanged: (value) => _climbConsistency = value,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Text(
                      style: TextStyle(fontSize: 25, fontFamily: 'Xolonium'),
                      'Auto',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RadioButton(
                      options: ['Climb', 'No Climb'],
                      height: 96,
                      variable: _autoClimb,
                      onChanged: (value) => _autoClimb = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: MultipleChoice(
                      options: ['Outpost', 'Depot', 'Neutral Zone'],
                      label: 'Fuel Collection Location',
                      variable: _fuelCollectionLocation,
                      onSelectionChanged:
                          (value) => _fuelCollectionLocation = value,
                    ),
                  ),

                  // Pathing Here
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Text(
                      style: TextStyle(fontSize: 25, fontFamily: 'Xolonium'),
                      'Gameplay',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: ['Bump', 'Trench'],
                      label: 'Pathway Preference',
                      variable: _pathwayPreference,
                      onChanged: (value) => _pathwayPreference = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: MultipleChoice(
                      options: ['Passing', 'Cycling', 'Shooting', 'Defense'],
                      label: 'Playing Style',
                      variable: _playingStyle,
                      onSelectionChanged: (value) => _playingStyle = value,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Text(
                      style: TextStyle(fontSize: 25, fontFamily: 'Xolonium'),
                      'Outtake',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RadioButton(
                      options: ['Trench Capable', 'Trench Incapable'],
                      height: 96,
                      variable: _trenchCapability,
                      onChanged: (value) => _trenchCapability = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: ['Turret', 'Adjustable Hood', 'Other'],
                      initialValue: '',
                      label: 'Shooter',
                      variable: _shooter,
                      onChanged: (value) => _shooter = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: ['4 Bar', 'Linear', 'Pivot'],
                      label: 'Collector Type',
                      variable: _collectorType,
                      onChanged: (value) => _collectorType = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: NumberTextField(
                      labelText: 'Fuel Outtake Rate/sec',
                      controller: _fuelOuttakeRateTEC,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: SegmentedSlider(
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: 'Average Accuracy %',
                      variable: _accuracy,
                      onChanged: (value) => _accuracy = value,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: MultipleChoice(
                      options: ['Mobile Shooting', 'Stationary Shooting'],
                      label: 'Move while Shooting?',
                      variable: _mobileShooting,
                      onSelectionChanged: (value) => _mobileShooting = value,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: MultipleChoice(
                      options: [
                        'Full Field',
                        'From Depot',
                        'From Trench',
                        'From Outpost',
                        'From Tower',
                      ],
                      label: 'Range from Field',
                      variable: _rangeFromField,
                      onSelectionChanged: (value) => _rangeFromField = value,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Text(
                      style: TextStyle(fontSize: 25, fontFamily: 'Xolonium'),
                      'Indexer',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: DropdownButtonOneChoice(
                      options: [
                        'Dye Rotor',
                        'Spindexer',
                        'Roller Bed',
                        'Belt Bed',
                        'Dual Spindexer',
                        'Other',
                      ],
                      label: 'Indexer Type',
                      variable: _indexerType,
                      onChanged: (value) => _indexerType = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RadioButton(
                      options: ['Powered', 'Not Powered'],
                      height: 96,
                      variable: _powered,
                      onChanged: (value) => _powered = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RadioButton(
                      options: ['Jack Arm', 'No Jack Arm'],
                      height: 96,
                      variable: _jackArm,
                      onChanged: (value) => _jackArm = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: TextField(
                      controller: _notesTEC,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Additional Comments / Weaknesses',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: FilledButton(
                      onPressed: () {
                        final nextVersion =
                            teamData.isEmpty
                                ? 1
                                : (teamData
                                        .map((e) => e["Version"] ?? 0)
                                        .reduce((a, b) => a > b ? a : b) +
                                    1);
                        final List<Map<String, Object?>> pitsData = [
                          {"Category": 'Pits'},
                          {"Version": nextVersion},
                          {"Team Name": widget.teamName},
                          {"Team Number": widget.teamNumber},

                          {
                            "Hopper Size (Max. Fuel Quantity)": int.tryParse(
                              _hopperSizeTEC.text,
                            ),
                          },
                          {"Motor Type": _motorType},
                          {"Drivetrain Type": _drivetrainType},
                          {"Swerve Brand": _swerveBrand},
                          {"Swerve Gear Ratio": _swerveGRTEC.text},
                          {"Wheel Type": _wheelType},
                          {
                            "Chassis Length (in)": double.tryParse(
                              _chassisLengthTEC.text,
                            ),
                          },
                          {
                            "Chassis Width (in)": double.tryParse(
                              _chassisWidthTEC.text,
                            ),
                          },
                          {
                            "Chassis Height (in)": double.tryParse(
                              _chassisHeightTEC.text,
                            ),
                          },
                          {
                            "Horizontal Extension Limit (in)": double.tryParse(
                              _horizontalExtensionTEC.text,
                            ),
                          },
                          {
                            "Vertical Extension Limit (in)": double.tryParse(
                              _verticalExtensionTEC.text,
                            ),
                          },
                          {"Weight (lbs)": double.tryParse(_botWeightTEC.text)},

                          {"Climb Method": _climbMethod},
                          {"Climb Type": _climbType.toList()},
                          {"Climb Level": _climbLevel.toList()},
                          {"Climb Consistency": _climbConsistency},

                          {"Auto Climb": _autoClimb},
                          {
                            "Fuel Collection Location":
                                _fuelCollectionLocation.toList(),
                          },

                          {"Pathway Preference": _pathwayPreference},
                          {"Playing Style": _playingStyle.toList()},

                          {"Trench Capability": _trenchCapability},
                          {"Shooter": _shooter},
                          {"Collector Type": _collectorType},
                          {
                            "Fuel Outtake Rate/sec": double.tryParse(
                              _fuelOuttakeRateTEC.text,
                            ),
                          },
                          {"Average Accuracy %": _accuracy},
                          {"Move While Shooting": _mobileShooting.toList()},
                          {"Range From Field": _rangeFromField.toList()},

                          {"Indexer Type": _indexerType},
                          {"Powered": _powered},
                          {"Jack Arm": _jackArm},
                          {"Additional Comments / Weaknesses": _notesTEC.text},
                        ];
                        ref
                            .read(honeycombClientProvider)
                            .post('/scout/ingest', data: pitsData);
                        dispose();
                        Navigator.pop(context, true);
                      },
                      child: Text(widget.scouted == false ? 'Submit' : 'Edit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
