import 'package:flutter/material.dart';

import 'package:beariscope/models/pits_scouting_models.dart';
import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/pages/pits_scouting/pits_scouting_widgets.dart';
import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:libkoala/providers/user_profile_provider.dart';

class PitsScoutingTeamCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
        ScoutingDocument? existingDoc;
        if (scouted) {
          final eventKey = ref.read(currentEventProvider);
          final allDocs = ref.read(scoutingDataProvider).asData?.value ?? [];
          final pitsDocs =
              allDocs
                  .where(
                    (doc) =>
                        doc.meta?['type'] == 'pits' &&
                        doc.meta?['event'] == eventKey &&
                        (doc.data['teamNumber'] as num?)?.toInt() == teamNumber,
                  )
                  .toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          existingDoc = pitsDocs.firstOrNull;
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PitsScoutingFormPage(
                  teamNumber: teamNumber,
                  teamName: teamName,
                  scouted: scouted,
                  initialDoc: existingDoc,
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

class PitsScoutingFormPage extends ConsumerStatefulWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;
  final ScoutingDocument? initialDoc;

  const PitsScoutingFormPage({
    super.key,
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
    this.initialDoc,
  });

  @override
  ConsumerState<PitsScoutingFormPage> createState() =>
      _PitsScoutingFormPageState();
}

class _PitsFormData {
  // Bot
  String motorType;
  String drivetrainType;
  String swerveBrand;
  String wheelType;
  // Climb
  String climbMethod;
  Set<String> climbType;
  Set<String> climbLevel;
  double climbConsistency;
  // Auto
  String autoClimb;
  Set<String> fuelCollectionLocation;
  String pathwayPreference;
  String trenchCapability;
  // Outtake
  String shooter;
  String collectorType;
  double accuracy;
  Set<String> mobileShooting;
  Set<String> rangeFromField;
  // Indexer
  String indexerType;
  String powered;

  _PitsFormData({
    this.motorType = 'X60',
    this.drivetrainType = 'Swerve',
    this.swerveBrand = 'REV',
    this.wheelType = 'Colson',
    this.climbMethod = 'Rotation',
    Set<String>? climbType,
    Set<String>? climbLevel,
    this.climbConsistency = 0.0,
    this.autoClimb = 'Climb',
    Set<String>? fuelCollectionLocation,
    this.pathwayPreference = 'Bump',
    this.trenchCapability = 'Trench Capable',
    this.shooter = 'Turret',
    this.collectorType = '4 Bar',
    this.accuracy = 0.0,
    Set<String>? mobileShooting,
    Set<String>? rangeFromField,
    this.indexerType = 'Dye Rotor',
    this.powered = 'Powered',
  }) : climbType = climbType ?? {},
       climbLevel = climbLevel ?? {},
       fuelCollectionLocation = fuelCollectionLocation ?? {},
       mobileShooting = mobileShooting ?? {},
       rangeFromField = rangeFromField ?? {};

  factory _PitsFormData.fromDoc(Map<String, dynamic> d) {
    String str(String key, String fallback) {
      final v = d[key];
      return (v is String && v.isNotEmpty) ? v : fallback;
    }

    Set<String> strSet(String key) =>
        Set<String>.from(((d[key] as List?) ?? []).map((e) => e.toString()));

    double dbl(String key, double fallback) =>
        (d[key] as num?)?.toDouble() ?? fallback;

    return _PitsFormData(
      motorType: str('motorType', 'X60'),
      drivetrainType: str('drivetrainType', 'Swerve'),
      swerveBrand: str('swerveBrand', 'REV'),
      wheelType: str('wheelType', 'Colson'),
      climbMethod: str('climbMethod', 'Rotation'),
      climbType: strSet('climbType'),
      climbLevel: strSet('climbLevel'),
      climbConsistency: dbl('climbConsistency', 0.0),
      autoClimb: str('autoClimb', 'Climb'),
      fuelCollectionLocation: strSet('fuelCollectionLocation'),
      pathwayPreference: str('pathwayPreference', 'Bump'),
      trenchCapability: str('trenchCapability', 'Trench Capable'),
      shooter: str('shooter', 'Turret'),
      collectorType: str('collectorType', '4 Bar'),
      accuracy: dbl('averageAccuracy', 0.0),
      mobileShooting: strSet('moveWhileShooting'),
      rangeFromField: strSet('rangeFromField'),
      indexerType: str('indexerType', 'Dye Rotor'),
      powered: str('powered', 'Powered'),
    );
  }
}

class _PitsScoutingFormPageState extends ConsumerState<PitsScoutingFormPage> {
  // Text fields kept as TECs (cursor / IME management).
  final TextEditingController _hopperSizeTEC = TextEditingController();
  final TextEditingController _swerveGRTEC = TextEditingController();
  final TextEditingController _chassisLengthTEC = TextEditingController();
  final TextEditingController _chassisWidthTEC = TextEditingController();
  final TextEditingController _chassisHeightTEC = TextEditingController();
  final TextEditingController _horizontalExtensionTEC = TextEditingController();
  final TextEditingController _verticalExtensionTEC = TextEditingController();
  final TextEditingController _botWeightTEC = TextEditingController();
  final TextEditingController _shooterNumberTEC = TextEditingController();
  final TextEditingController _fuelOuttakeRateTEC = TextEditingController();
  final TextEditingController _notesTEC = TextEditingController();

  // All choice-based fields in one object.
  late _PitsFormData _f;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDoc?.data;
    if (d != null) {
      _f = _PitsFormData.fromDoc(d);
      _hopperSizeTEC.text = (d['hopperSize'] as num?)?.toInt().toString() ?? '';
      _swerveGRTEC.text = (d['swerveGearRatio'] as String?) ?? '';
      _chassisLengthTEC.text = (d['chassisLength'] as num?)?.toString() ?? '';
      _chassisWidthTEC.text = (d['chassisWidth'] as num?)?.toString() ?? '';
      _chassisHeightTEC.text = (d['chassisHeight'] as num?)?.toString() ?? '';
      _horizontalExtensionTEC.text =
          (d['horizontalExtensionLimit'] as num?)?.toString() ?? '';
      _verticalExtensionTEC.text =
          (d['verticalExtensionLimit'] as num?)?.toString() ?? '';
      _botWeightTEC.text = (d['weight'] as num?)?.toString() ?? '';
      _shooterNumberTEC.text =
          (d['shooterNumber'] as num?)?.toInt().toString() ?? '';
      _fuelOuttakeRateTEC.text =
          (d['fuelOuttakeRate'] as num?)?.toString() ?? '';
      _notesTEC.text = (d['notes'] as String?) ?? '';
    } else {
      _f = _PitsFormData();
    }
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
    _shooterNumberTEC.dispose();
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
                  initialValue: _f.motorType,
                  onChanged: (value) => _f.motorType = value ?? _f.motorType,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['Swerve', 'Tank', 'Mecanum'],
                  label: 'Drivetrain Type',
                  initialValue: _f.drivetrainType,
                  onChanged:
                      (value) => _f.drivetrainType = value ?? _f.drivetrainType,
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
                  initialValue: _f.swerveBrand,
                  onChanged:
                      (value) => _f.swerveBrand = value ?? _f.swerveBrand,
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
                  initialValue: _f.wheelType,
                  onChanged: (value) => _f.wheelType = value ?? _f.wheelType,
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
                child: DropdownButtonOneChoice(
                  options: ['Rotation', 'Elevator', 'Arm', 'No Climb', 'Other'],
                  initialValue: _f.climbMethod,
                  onChanged:
                      (value) => _f.climbMethod = value ?? _f.climbMethod,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: [
                    'Pivot',
                    'Telescoping',
                    'Elevator/Monkey Bar',
                    'Buzzer Beater',
                  ],
                  label: 'Climb Type',
                  variable: _f.climbType,
                  onSelectionChanged: (value) => _f.climbType = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Level 1', 'Level 2', 'Level 3'],
                  variable: _f.climbLevel,
                  onSelectionChanged: (value) => _f.climbLevel = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: SegmentedSlider(
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: 'Climb Consistency out of 10',
                  initialValue: _f.climbConsistency,
                  onChanged: (value) => _f.climbConsistency = value,
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
                  initialValue: _f.autoClimb,
                  onChanged: (value) => _f.autoClimb = value ?? _f.autoClimb,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Outpost', 'Depot', 'Neutral Zone'],
                  label: 'Fuel Collection Location',
                  variable: _f.fuelCollectionLocation,
                  onSelectionChanged:
                      (value) => _f.fuelCollectionLocation = value,
                ),
              ),
              // Pathing Here, will replace Pathway Preference and Trench Capability
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['Bump', 'Trench'],
                  label: 'Pathway Preference',
                  initialValue: _f.pathwayPreference,
                  onChanged:
                      (value) =>
                          _f.pathwayPreference = value ?? _f.pathwayPreference,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: RadioButton(
                  options: ['Trench Capable', 'Trench Incapable'],
                  height: 96,
                  initialValue: _f.trenchCapability,
                  onChanged:
                      (value) =>
                          _f.trenchCapability = value ?? _f.trenchCapability,
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
                child: DropdownButtonOneChoice(
                  options: [
                    'Turret',
                    'Adjustable Hood',
                    'Drum',
                    'Stationary',
                    'Other',
                  ],
                  label: 'Shooter',
                  initialValue: _f.shooter,
                  onChanged: (value) => _f.shooter = value ?? _f.shooter,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: NumberTextField(
                  labelText: 'Number of Shooters',
                  controller: _shooterNumberTEC,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['4 Bar', 'Linear', 'Pivot'],
                  label: 'Collector Type',
                  initialValue: _f.collectorType,
                  onChanged:
                      (value) => _f.collectorType = value ?? _f.collectorType,
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
                  initialValue: _f.accuracy,
                  onChanged: (value) => _f.accuracy = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Mobile Shooting', 'Stationary Shooting'],
                  label: 'Move while Shooting?',
                  variable: _f.mobileShooting,
                  onSelectionChanged: (value) => _f.mobileShooting = value,
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
                  variable: _f.rangeFromField,
                  onSelectionChanged: (value) => _f.rangeFromField = value,
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
                  initialValue: _f.indexerType,
                  onChanged:
                      (value) => _f.indexerType = value ?? _f.indexerType,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: RadioButton(
                  options: ['Powered', 'Not Powered'],
                  height: 96,
                  initialValue: _f.powered,
                  onChanged: (value) => _f.powered = value ?? _f.powered,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextField(
                  controller: _notesTEC,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(labelText: 'Additional Comments'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: FilledButton(
                  onPressed: () async {
                    final submission = PitsScoutingSubmission(
                      teamName: widget.teamName,
                      teamNumber: widget.teamNumber,
                      hopperSize: int.tryParse(_hopperSizeTEC.text),
                      motorType: _f.motorType,
                      drivetrainType: _f.drivetrainType,
                      swerveBrand: _f.swerveBrand,
                      swerveGearRatio: _swerveGRTEC.text,
                      wheelType: _f.wheelType,
                      chassisLength: double.tryParse(_chassisLengthTEC.text),
                      chassisWidth: double.tryParse(_chassisWidthTEC.text),
                      chassisHeight: double.tryParse(_chassisHeightTEC.text),
                      horizontalExtensionLimit: double.tryParse(
                        _horizontalExtensionTEC.text,
                      ),
                      verticalExtensionLimit: double.tryParse(
                        _verticalExtensionTEC.text,
                      ),
                      weight: double.tryParse(_botWeightTEC.text),
                      climbMethod: _f.climbMethod,
                      climbType: _f.climbType,
                      climbLevel: _f.climbLevel,
                      climbConsistency: _f.climbConsistency,
                      autoClimb: _f.autoClimb,
                      fuelCollectionLocation: _f.fuelCollectionLocation,
                      pathwayPreference: _f.pathwayPreference,
                      trenchCapability: _f.trenchCapability,
                      shooter: _f.shooter,
                      shooterNumber: int.tryParse(_shooterNumberTEC.text),
                      collectorType: _f.collectorType,
                      fuelOuttakeRate: double.tryParse(
                        _fuelOuttakeRateTEC.text,
                      ),
                      averageAccuracy: _f.accuracy,
                      moveWhileShooting: _f.mobileShooting,
                      rangeFromField: _f.rangeFromField,
                      indexerType: _f.indexerType,
                      powered: _f.powered,
                      notes: _notesTEC.text,
                    );

                    final entry = submission.toIngestEntry(
                      eventKey: currentEventKey,
                      scoutedBy: scoutedBy,
                      existingId: widget.initialDoc?.id,
                    );
                    try {
                      await ref
                          .read(honeycombClientProvider)
                          .post(
                            '/scout/ingest',
                            data: {
                              "entries": [entry],
                            },
                          );
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit: $e')),
                        );
                      }
                    }
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
