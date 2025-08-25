# Network Ninja Web Demo

This directory contains the web version of the Network Ninja example app, deployed to GitHub Pages.

## What's Here

- **index.html** - Main entry point for the Flutter web app
- **main.dart.js** - Compiled Flutter application
- **assets/** - Application assets and resources
- **canvaskit/** - Flutter web rendering engine files

## Access

Visit: https://bluematterin.github.io/network_ninja/

## Development

This web demo is automatically built and deployed via GitHub Actions when changes are pushed to the main branch.

To build locally:
```bash
cd example
flutter build web --release
```

The built files will be in `example/build/web/` and can be served with any static web server.
