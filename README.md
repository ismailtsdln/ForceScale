# ForceScale

ForceScale is a macOS-native project that estimates object weight using Force Touch trackpad pressure data. It includes both a Graphical User Interface (GUI) and a Command-Line Interface (CLI).

> [!WARNING]
> **Experimental Tool**: ForceScale is an experimental project and is not a certified measurement device. Weight estimations are approximations and can be affected by surface material, object conductivity, and temperature. Use for entertainment and educational purposes only.

## Features

- **Raw Pressure Reading**: Accesses low-level Force Touch data via `MultitouchSupport`.
- **User-Driven Calibration**: Support for linear regression-based calibration with known weights.
- **Dual Interface**: Use the SwiftUI app for a visual experience or the CLI for automation.
- **Shared Core**: Both interfaces use the same logic layer for consistency.

## Installation & Build

### Prerequisites

- macOS 13.0 or later
- Xcode 15+
- A MacBook or Trackpad with Force Touch support

### Building the CLI

```bash
swift build -c release
cp .build/release/forcescale /usr/local/bin/forcescale
```

### Running the App

To run the SwiftUI app, open the project in Xcode and run the `ForceScaleUI` target. Ensure that App Sandboxing is disabled in the project's Capabilities.

## CLI Usage

### Calibration

Place a known weight (e.g., 100g) on the trackpad:

```bash
forcescale calibrate --weight 100
```

### Measurement

```bash
forcescale measure
```

To see live updates:

```bash
forcescale measure --live
```

### Export Data

```bash
forcescale export --format json
```

## GUI Usage

1. **Launch**: Open ForceScale.app.
2. **Calibrate**: Click the settings icon to open the Calibration Wizard. Add at least two points (e.g., empty trackpad = 0g, and a known weight).
3. **Measure**: The main screen shows real-time estimated weight.
4. **Tare**: Click "TARE" to zero the scale with a container on it.

## Technical Details

ForceScale uses the private `MultitouchSupport.framework` to read raw pressure values from each contact point on the trackpad. It uses a simple linear regression model ($y = mx + b$) to map these pressure values to grams.

## License

MIT
