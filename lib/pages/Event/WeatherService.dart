import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  WeatherWidget({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display weather description
            Text(
              'Weather: ${weatherData['description'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                // Display the weather icon if available
                if (weatherData['icon'] != null)
                  Image.network(
                    'https://www.weatherbit.io/static/img/icons/${weatherData['icon']}.png',
                    width: 50,
                    height: 50,
                  ),
                SizedBox(width: 8),
                // Display temperature
                Text(
                  'Temperature: ${weatherData['temp'] ?? 'N/A'}°C',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Display humidity and wind speed
            Text(
              'Humidity: ${weatherData['rh'] ?? 'N/A'}%',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              'Wind Speed: ${weatherData['wind_spd'] ?? 'N/A'} m/s',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
