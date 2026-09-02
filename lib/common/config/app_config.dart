/// App configuration for different environments
enum Environment { local, dev, staging, production }

/// Environment configuration class
/// Contains all environment-specific URLs, API keys, and settings
/// Note: Do NOT hardcode URLs elsewhere in the code. Always use this configuration.
class AppConfig {
  static Environment _environment = Environment.dev;
  static Env? _currentEnv;

  static Env? get currentEnv => _currentEnv;

  /// Set the current environment
  static void setEnvironment(Environment env) {
    _environment = env;
    _currentEnv = _getEnvConfig(env);
  }

  /// Get environment configuration
  static Env _getEnvConfig(Environment env) {
    switch (env) {
      case Environment.local:
        return EnvValue.local;
      case Environment.dev:
        return EnvValue.development;
      case Environment.staging:
        return EnvValue.staging;
      case Environment.production:
        return EnvValue.production;
    }
  }

  static Environment get environment => _environment;
  static bool get isDev => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  static String get baseUrl =>
      _currentEnv?.baseUrl ?? EnvValue.development.baseUrl;

  static String get socketUrl =>
      _currentEnv?.socketUrl ?? EnvValue.development.socketUrl;

  static String get webSecretKey =>
      _currentEnv?.webSecretKey ?? EnvValue.development.webSecretKey;

  static String get appName =>
      _currentEnv?.appName ?? 'Data Portal Survey';

  static String get appVersion => _currentEnv?.appVersion ?? '1.0.0';

  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
  static Duration get sendTimeout => const Duration(seconds: 30);

  static bool get enableLogging {
    switch (_environment) {
      case Environment.local:
      case Environment.dev:
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static bool get enableDetailedLogging => enableLogging;
}

class Env {
  final String baseUrl;
  final String socketUrl;
  final String webSecretKey;
  final String appName;
  final String appVersion;

  Env({
    required this.baseUrl,
    required this.socketUrl,
    required this.webSecretKey,
    this.appName = 'Data Portal Survey',
    this.appVersion = '1.0.0',
  });
}

class EnvValue {
  static final Env local = Env(
    baseUrl: '',
    socketUrl: '',
    webSecretKey: 'YourDevSecretKey',
    appName: 'Data Portal Survey Dev',
    appVersion: '1.0.0-dev',
  );

  static final Env development = Env(
    baseUrl: 'https://backend.provincedataportal.cliffbyte.com/api',
    socketUrl: '',
    webSecretKey: 'YourDevSecretKey',
    appName: 'Data Portal Survey Dev',
    appVersion: '1.0.0-dev',
  );

  static final Env staging = Env(
    baseUrl: 'https://backend.provincedataportal.cliffbyte.com/api',
    socketUrl: '',
    webSecretKey: 'YourStagingSecretKey',
    appName: 'Data Portal Survey Staging',
    appVersion: '1.0.0-staging',
  );

  static final Env production = Env(
    baseUrl: 'https://backend.provincedataportal.cliffbyte.com/api',
    socketUrl: '',
    webSecretKey: 'YourProductionSecretKey',
    appName: 'Data Portal Survey',
    appVersion: '1.0.0',
  );
}
