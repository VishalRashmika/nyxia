class HomeData {
  final LocationData location;
  final WeatherData weather;
  final double? elevation;
  final LightPollution lightPollution;
  final DateTime lastUpdated;

  HomeData({
    required this.location,
    required this.weather,
    this.elevation,
    required this.lightPollution,
    required this.lastUpdated,
  });

  factory HomeData.initial() {
    return HomeData(
      location: LocationData.initial(),
      weather: WeatherData.initial(),
      elevation: null,
      lightPollution: LightPollution.unknown(),
      lastUpdated: DateTime.now(),
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
  });

  factory LocationData.initial() {
    return LocationData(
      latitude: 0.0,
      longitude: 0.0,
      city: null,
      country: null,
    );
  }

  String get coordinates =>
      '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';
}

class WeatherData {
  final double temperature;
  final int humidity;
  final int cloudCover;
  final String description;
  final String? icon;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.cloudCover,
    required this.description,
    this.icon,
  });

  factory WeatherData.initial() {
    return WeatherData(
      temperature: 0.0,
      humidity: 0,
      cloudCover: 0,
      description: 'Unknown',
      icon: null,
    );
  }

  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';
  String get humidityString => '$humidity%';
  String get cloudCoverString => '$cloudCover%';
}

class LightPollution {
  final double? sqm;
  final int bortleScale;
  final String description;

  LightPollution({
    this.sqm,
    required this.bortleScale,
    required this.description,
  });

  factory LightPollution.unknown() {
    return LightPollution(sqm: null, bortleScale: 5, description: 'Unknown');
  }

  factory LightPollution.fromSQM(double sqm) {
    int bortle;
    String description;

    if (sqm >= 21.99) {
      bortle = 1;
      description = 'Excellent dark sky';
    } else if (sqm >= 21.89) {
      bortle = 2;
      description = 'Typical dark sky';
    } else if (sqm >= 21.69) {
      bortle = 3;
      description = 'Rural sky';
    } else if (sqm >= 20.49) {
      bortle = 4;
      description = 'Rural/suburban transition';
    } else if (sqm >= 19.50) {
      bortle = 5;
      description = 'Suburban sky';
    } else if (sqm >= 18.94) {
      bortle = 6;
      description = 'Bright suburban';
    } else if (sqm >= 18.38) {
      bortle = 7;
      description = 'Suburban/urban transition';
    } else if (sqm >= 17.80) {
      bortle = 8;
      description = 'City sky';
    } else {
      bortle = 9;
      description = 'Inner city sky';
    }

    return LightPollution(
      sqm: sqm,
      bortleScale: bortle,
      description: description,
    );
  }

  String get bortleString => 'Bortle $bortleScale';
  String get sqmString =>
      sqm != null ? '${sqm!.toStringAsFixed(2)} mag/arcsec²' : 'N/A';
}
