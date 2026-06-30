import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/weather_window_marker.dart';

class WeatherWindowPanel extends StatelessWidget {
  const WeatherWindowPanel({required this.weatherMarker, super.key});

  final WeatherWindowMarker weatherMarker;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LedgePalette.pineShadow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_queue_rounded,
                color: LedgePalette.lichenGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Weather window',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: LedgePalette.chalkWhite,
                ),
              ),
              const Spacer(),
              Text(
                '${weatherMarker.airTemperatureCelsius} C',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: LedgePalette.lichenGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _WeatherReading(label: 'Sky', value: weatherMarker.skyLedger),
          _WeatherReading(label: 'Wind', value: weatherMarker.windThread),
          _WeatherReading(
            label: 'Friction',
            value: weatherMarker.frictionPromise,
          ),
          _WeatherReading(label: 'Pack', value: weatherMarker.packingNudge),
        ],
      ),
    );
  }
}

class _WeatherReading extends StatelessWidget {
  const _WeatherReading({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: LedgePalette.fogLine),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: LedgePalette.chalkWhite),
            ),
          ),
        ],
      ),
    );
  }
}
