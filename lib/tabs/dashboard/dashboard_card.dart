import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({Key? key, required this.info, required this.count, required this.icon}) : super(key: key);

  final String info;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.grey.shade100,
        )
      ]),
      child: Wrap(
        runAlignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                child: Icon(
                  icon,
                  size: 20,
                ),
              ),
              AnimatedFlipCounter(
                duration: const Duration(milliseconds: 500),
                value: count,
                thousandSeparator: ',',
                textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 28),
              )
            ],
          ),
          Text(
            info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
