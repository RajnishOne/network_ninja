# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Search functionality in network logs list
- Export options (cURL, JSON, share)
- Click-to-copy functionality on details page
- Professional package structure and documentation

### Changed
- Renamed package from `network_ninja_lib` to `network_ninja`
- Improved UI animations and performance
- Enhanced error handling and request matching

### Fixed
- Request/response matching issues
- Memory leaks in stream subscriptions
- UI responsiveness during high-frequency polling

## [1.0.0] - 2024-08-24

### Added
- Initial release of Network Ninja
- Floating bubble UI for network monitoring
- Real-time network request/response logging
- Automatic Dio interceptor integration
- Network logs screen with filtering
- Network details screen with comprehensive information
- Search and filter functionality
- Export options (cURL, JSON, share)
- Privacy-focused automatic data redaction
- Performance-optimized animations
- Material Design UI components

### Features
- **Floating Bubble UI**: Draggable, collapsible bubble for quick access
- **Real-time Monitoring**: Automatic capture of all Dio requests
- **Search & Filter**: Find specific requests by endpoint, method, or status
- **Detailed Views**: Comprehensive request and response information
- **Export Options**: Copy as cURL, JSON, or share logs
- **Security**: Automatic redaction of sensitive headers
- **Performance**: Optimized for high-frequency API polling

### Technical Details
- Built with Flutter 3.10+
- Compatible with Dio 5.4.0+
- MIT License
- Comprehensive test coverage
- Professional documentation
