# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1]

### Fixed
- Fixed screenshot URLs to use correct branch name (master)

## [1.1.0]

### Added
- **Web Demo**: Live web version of the Network Ninja example app
- **GitHub Pages Integration**: Simple docs folder setup for web demo hosting
- **Web Demo Scripts**: Local testing scripts for web version (Windows/Linux/Mac)
- **Enhanced Documentation**: Updated README with web demo links and instructions

### Features
- **Live Web Demo**: Try Network Ninja directly in your browser at https://bluematterin.github.io/network_ninja/
- **Cross-platform Web Support**: Full Flutter web compatibility
- **Simple Setup**: Standard GitHub Pages with docs folder
- **Local Testing**: Easy local web demo testing with provided scripts

### Technical Details
- Built web demo using Flutter web build system
- Standard GitHub Pages deployment via docs folder
- Web-optimized UI components and interactions
- Responsive design for various screen sizes

## [1.0.3]

### Changed
- Removed dates from changelog entries for cleaner format
- Simplified version history presentation

## [1.0.2]

### Fixed
- Fixed async gap issues in network log details screen by adding context.mounted checks
- Fixed join_return_with_assignment issues in network ninja controller
- Fixed prefer_expression_function_bodies issues where appropriate
- Fixed prefer_const_constructors issues in UI components
- Fixed avoid_print issues in test files
- Fixed prefer_interpolation_to_compose_strings issues
- Fixed redundant argument values in test files
- Fixed test failures related to copyWith method behavior
- Improved code formatting and linting compliance

### Changed
- Enhanced error handling and context safety
- Improved test coverage and reliability
- Updated CHANGELOG.md to only include released versions

## [1.0.1]

### Fixed
- Fixed async gap issues in network log details screen
- Fixed linting issues and improved code quality
- Fixed test failures and improved test coverage
- Fixed repository URL consistency in pubspec.yaml

### Changed
- Improved code formatting and linting compliance
- Enhanced error handling and context safety

## [1.0.0]

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
