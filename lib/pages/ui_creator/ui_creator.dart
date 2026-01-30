import 'package:flutter/material.dart';

class UICreatorPage extends StatefulWidget {
  const UICreatorPage({super.key});

  @override
  State<UICreatorPage> createState() => _UiCreatorState();
}

class _UiCreatorState extends State<UICreatorPage> {
  double pointSize = 90.0;
  int maxRows = 10;
  int maxCols = 10;
  double widgetWidth = 50.0;
  double widgetHeight = 50.0;

  Set<String> occupiedPoints = {};
  List<DroppedWidget> homeWidgets = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DragTarget<String>(
        onAcceptWithDetails: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          final Offset dropPosition = details.offset;

          // Subtract half the widget size to "center" the snap to your finger
          double adjustedX = dropPosition.dx - (widgetWidth / 2);
          double adjustedY = dropPosition.dy - (widgetHeight / 2);

          int ptX = (adjustedX / pointSize).round();
          int ptY = (adjustedY / pointSize).round();
          bool isWithinBounds = ptX >= 0 && ptX < maxCols && ptY >= 0 && ptY < maxRows;
          String pointKey = "$ptX,$ptY";
          if (isWithinBounds && !occupiedPoints.contains(pointKey)) {
            setState(() {
              occupiedPoints.add(pointKey);
              homeWidgets.add(
                DroppedWidget(
                  label: details.data,
                  position: Offset(ptX * pointSize, ptY * pointSize),
                ),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Space already taken or out of bounds!")),
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: homeWidgets.map((droppedWidget) {
              return Positioned(
                left: droppedWidget.position.dx,
                top: droppedWidget.position.dy,
                child: Chip(label: Text(droppedWidget.label)),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(color: Colors.white54, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDraggableWidget("Button"),
            _buildDraggableWidget("Slider"),
            _buildDraggableWidget("Switch"),
            _buildDraggableWidget("TextField"),
          ],
        ),
      ),
    );
  }
}

Widget _buildDraggableWidget(String label) {
  return Draggable<String>(
    data: label,
    feedback: Material(
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.blue,
        child: Text(label),
      ),
    ),
    childWhenDragging: Opacity(opacity: 0.5, child: Chip(label: Text(label))),
    child: Chip(label: Text(label)),
  );
}

class DroppedWidget {
  String label;
  Offset position;

  DroppedWidget({required this.label, required this.position});
}
