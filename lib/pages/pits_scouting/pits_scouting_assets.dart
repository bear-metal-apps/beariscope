import 'package:flutter/material.dart';

import 'package:beariscope/pages/pits_scouting/pits_scouting_widgets.dart';
import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:libkoala/providers/user_profile_provider.dart';

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
  final TextEditingController _hopperSizeTEC = TextEditingController();
  late String _motorType;
  late String _drivetrainType;
  late String _swerveBrand;
  final TextEditingController _swerveGRTEC = TextEditingController();
  late String _wheelType;
  final TextEditingController _chassisLengthTEC = TextEditingController();
  final TextEditingController _chassisWidthTEC = TextEditingController();
  final TextEditingController _chassisHeightTEC = TextEditingController();
  final TextEditingController _horizontalExtensionTEC = TextEditingController();
  final TextEditingController _verticalExtensionTEC = TextEditingController();
  final TextEditingController _botWeightTEC = TextEditingController();
  late String _climbMethod;
  late Set<String> _climbType;
  late Set<String> _climbLevel;
  late double _climbConsistency;
  late String _autoClimb;
  late Set<String> _fuelCollectionLocation;
  late Set<String> _playingStyle;
  late String _trenchCapability;
  late String _pathwayPreference;
  late String _shooter;
  late String _collectorType;
  final TextEditingController _fuelOuttakeRateTEC = TextEditingController();
  late double _accuracy;
  late Set<String> _mobileShooting;
  late Set<String> _rangeFromField;
  late String _indexerType;
  late String _powered;
  final TextEditingController _notesTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _motorType = '';
    _drivetrainType = '';
    _swerveBrand = '';
    _wheelType = '';
    _climbMethod = '';
    _climbType = <String>{};
    _climbLevel = <String>{};
    _climbConsistency = 0.0;
    _autoClimb = '';
    _fuelCollectionLocation = <String>{};
    _pathwayPreference = '';
    _playingStyle = <String>{};
    _trenchCapability = '';
    _shooter = '';
    _collectorType = '';
    _accuracy = 0.0;
    _mobileShooting = <String>{};
    _rangeFromField = <String>{};
    _indexerType = '';
    _powered = '';
  }

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
    final currentEventKey = ref.watch(currentEventProvider);
    final userInfo = ref.watch(userInfoProvider).asData?.value;
    final scoutedBy = userInfo?.name?.trim() ?? 'Unknown User';

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
                  options: ['Colson', 'Pneumatic', 'Spike', 'Billet', 'Other'],
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
                  options: ['Rotation', 'Elevator', 'Arm', 'No Climb', 'Other'],
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
                    final Map<String, Object?> entry = {
                      "meta": {
                        "type": 'pits',
                        "version": 1,
                        "season": 2026,
                        "event": currentEventKey,
                        "scoutedBy": scoutedBy,
                      },
                      "teamName": widget.teamName,
                      "teamNumber": widget.teamNumber,
                      "hopperSize": int.tryParse(_hopperSizeTEC.text),
                      "motorType": _motorType,
                      "drivetrainType": _drivetrainType,
                      "swerveBrand": _swerveBrand,
                      "swerveGearRatio": _swerveGRTEC.text,
                      "wheelType": _wheelType,
                      "chassisLength": double.tryParse(_chassisLengthTEC.text),
                      "chassisWidth": double.tryParse(_chassisWidthTEC.text),
                      "chassisHeight": double.tryParse(_chassisHeightTEC.text),
                      "horizontalExtensionLimit": double.tryParse(
                        _horizontalExtensionTEC.text,
                      ),
                      "verticalExtensionLimit": double.tryParse(
                        _verticalExtensionTEC.text,
                      ),
                      "weight": double.tryParse(_botWeightTEC.text),
                      "climbMethod": _climbMethod,
                      "climbType": _climbType.toList(),
                      "climbLevel": _climbLevel.toList(),
                      "climbConsistency": _climbConsistency,
                      "autoClimb": _autoClimb,
                      "fuelCollectionLocation":
                          _fuelCollectionLocation.toList(),
                      "pathwayPreference": _pathwayPreference,
                      "playingStyle": _playingStyle.toList(),
                      "trenchCapability": _trenchCapability,
                      "shooter": _shooter,
                      "collectorType": _collectorType,
                      "fuelOuttakeRate": double.tryParse(
                        _fuelOuttakeRateTEC.text,
                      ),
                      "averageAccuracy": _accuracy,
                      "moveWhileShooting": _mobileShooting.toList(),
                      "rangeFromField": _rangeFromField.toList(),
                      "indexerType": _indexerType,
                      "powered": _powered,
                      "notes": _notesTEC.text,
                    };
                    ref
                        .read(honeycombClientProvider)
                        .post(
                          '/scout/ingest',
                          data: {
                            "entries": [entry],
                          },
                        );
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
  }
}
