import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatBar extends StatelessWidget {
  final String label;
  final DateTime? previousTime;
  final DateTime? nextTime;
  final Color colorMin;
  final Color colorMax;
  final double value;
  final double maxValue;

  const StatBar(
      {super.key,
      required this.label,
      required this.colorMin,
      required this.colorMax,
      required this.value,
      required this.maxValue,
      this.previousTime,
      this.nextTime});

  @override
  Widget build(BuildContext context) {
    var hasTimes = nextTime != null || previousTime != null;
    var formattedNextTime =
        nextTime != null ? DateFormat("HH:mm").format(nextTime!) : "";
    var formattedPreviousTime =
        previousTime != null ? DateFormat("HH:mm").format(previousTime!) : "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTimes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedPreviousTime,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 10)),
              Expanded(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              if (nextTime != null)
                Text(formattedNextTime,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 10))
              else
                Text("+1 day",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 10))
            ],
          )
        else
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / maxValue,
            color: Color.lerp(colorMin, colorMax, value / maxValue),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
