import 'package:beariscope/pages/pits_scouting/pits_scouting_widgets.dart';
import 'package:flutter/material.dart';
import 'package:beariscope/components/beariscope_card.dart';

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
                (context) => _ScoutingPage(
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

class _ScoutingPage extends StatefulWidget {
  final String teamName;
  final int teamNumber;
  final bool scouted;

  const _ScoutingPage({
    required this.teamName,
    required this.teamNumber,
    required this.scouted,
  });

  @override
  State<_ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends State<_ScoutingPage> {
  final TextEditingController notesTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                child: NumberTextField(labelText: 'Hopper Size'),
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['Swerve', 'Tank', 'Mecanum'],
                  label: 'Drivetrain Type',
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: NumberTextField(
                  labelText: 'Swerve Gear Ratio (If none, type 0)',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['Colson', 'Pneumatic', 'Spike', 'Billet', 'Other'],
                  label: 'Wheel Type',
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
                      child: NumberTextField(labelText: 'Chassis Length'),
                    ),
                    Expanded(child: SizedBox(height: 10)),
                    Expanded(
                      flex: 3,
                      child: NumberTextField(labelText: 'Chassis Width'),
                    ),
                    Expanded(child: SizedBox(height: 10)),
                    Expanded(
                      flex: 3,
                      child: NumberTextField(labelText: 'Chassis Height'),
                    ),
                    SizedBox(width: 30, height: 10),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: NumberTextField(labelText: 'Weight (lbs)'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Horizontal Extension', 'Vertical Extension'],
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Buzzer Beater', 'Level 1', 'Level 3', 'Flip'],
                  label: 'Climb Type',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Level 1', 'Level 2', 'Level 3'],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: SegmentedSlider(
                  min: 1,
                  max: 10,
                  divisions: 10,
                  label: 'Climb Consistency out of 10',
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
                child: RadioButton(options: ['Climb', 'No Climb'], height: 96),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Outpost', 'Depot', 'Neutral Zone'],
                  label: 'Fuel Collection Location',
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Passing', 'Cycling', 'Shooting', 'Defense'],
                  label: 'Playing Style',
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['Turret', 'Adjustable Hood', 'Other'],
                  initialValue: '',
                  label: 'Shooter',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: DropdownButtonOneChoice(
                  options: ['4 Bar', 'Linear', 'Pivot'],
                  label: 'Collector Type',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: NumberTextField(labelText: 'Fuel Outtake Rate/sec'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: SegmentedSlider(
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: 'Average Accuracy %',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MultipleChoice(
                  options: ['Mobile Shooting', 'Stationary Shooting'],
                  label: 'Move while Shooting?',
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: RadioButton(options: ['Powered', 'Not Powered']),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: RadioButton(
                  options: ['Jack Arm', 'No Jack Arm'],
                  height: 96,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextField(
                  controller: notesTEC,
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
