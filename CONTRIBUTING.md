# Contributing to Network Ninja

Thank you for your interest in contributing to Network Ninja! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, please include:

- **Clear and descriptive title**
- **Detailed description** of the problem
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Environment details** (Flutter version, OS, device)
- **Code samples** if applicable
- **Screenshots** if UI-related

### Suggesting Enhancements

We welcome feature requests! When suggesting enhancements:

- **Describe the feature** in detail
- **Explain the use case** and benefits
- **Provide examples** of how it would work
- **Consider implementation** complexity

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** following the coding standards
4. **Add tests** for new functionality
5. **Update documentation** if needed
6. **Run tests**: `flutter test`
7. **Check code quality**: `flutter analyze`
8. **Commit your changes**: Use conventional commit messages
9. **Push to your branch**: `git push origin feature/amazing-feature`
10. **Create a Pull Request**

## 📋 Development Setup

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Git

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/network_ninja.git
   cd network_ninja
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Check code quality**:
   ```bash
   flutter analyze
   ```

5. **Run the example app**:
   ```bash
   cd example
   flutter run
   ```

## 📝 Coding Standards

### Dart/Flutter Standards

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use [flutter_lints](https://pub.dev/packages/flutter_lints) for linting
- Write meaningful commit messages using [Conventional Commits](https://www.conventionalcommits.org/)

### Code Style

- **Indentation**: 2 spaces
- **Line length**: 80 characters maximum
- **Naming**: Use descriptive names for variables, functions, and classes
- **Documentation**: Add documentation comments for public APIs
- **Tests**: Write tests for all new functionality

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(ui): add search functionality to network logs
fix(interceptor): resolve request/response matching issue
docs(readme): update installation instructions
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/network_ninja_controller_test.dart
```

### Writing Tests

- Write tests for all public APIs
- Use descriptive test names
- Test both success and error scenarios
- Mock external dependencies
- Test edge cases and boundary conditions

### Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  group('NetworkNinjaController', () {
    test('should add interceptor to Dio instance', () {
      // Arrange
      final dio = Dio();
      
      // Act
      NetworkNinjaController.addInterceptor(dio);
      
      // Assert
      expect(dio.interceptors, isNotEmpty);
    });
  });
}
```

## 📚 Documentation

### Code Documentation

- Add documentation comments for all public APIs
- Use proper Dart documentation format
- Include examples in documentation
- Keep documentation up to date

### README Updates

- Update README.md for new features
- Add usage examples
- Update installation instructions if needed
- Keep feature list current

## 🔄 Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Code analysis passes
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] Version is bumped in pubspec.yaml
- [ ] Example app works correctly
- [ ] README.md is current

## 🐛 Issue Templates

### Bug Report Template

```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Flutter version:
- Dart version:
- OS:
- Device:

## Additional Information
Any other relevant information
```

### Feature Request Template

```markdown
## Feature Description
Brief description of the feature

## Use Case
Why this feature would be useful

## Proposed Implementation
How this feature could be implemented

## Additional Information
Any other relevant information
```

## 📞 Getting Help

If you need help with contributing:

- **GitHub Issues**: Create an issue for questions
- **Discussions**: Use GitHub Discussions for general questions
- **Documentation**: Check the README and API documentation

## 🙏 Recognition

Contributors will be recognized in:

- **README.md** contributors section
- **CHANGELOG.md** for significant contributions
- **GitHub** contributors page

Thank you for contributing to Network Ninja! 🥷
