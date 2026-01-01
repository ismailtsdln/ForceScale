# ForceScale

### *Precision Weight Estimation via macOS Force Touch*

ForceScale is a sophisticated macOS-native platform designed to estimate the weight of objects using raw pressure data from the Force Touch trackpad. By leveraging low-level sensor input and advanced calibration models, ForceScale bridges the gap between hardware sensors and user-centric measurement interfaces.

---

> [!CAUTION]
> **EXPERIMENTAL HARDWARE INTERFACE**
> ForceScale is an experimental research project and **not** a certified measurement device. Weight estimations are mathematical approximations based on trackpad deflection. Accuracy is influenced by several factors, including surface material, object conductivity, and environmental temperature. **Do not use for critical or medical measurements.**

---

## 🚀 Key Features

* **Low-Level Sensor Fusion**: Direct interface with `MultitouchSupport.framework` to access high-fidelity, per-contact pressure data.
* **Intelligent Calibration**: Multi-point linear regression engine allowing users to map raw sensor values to real-world mass (grams).
* **Dual-Interface Architecture**:
  * **ForceScale UI**: A premium SwiftUI application with real-time visualization, stability detection, and a guided calibration wizard.
  * **ForceScale CLI**: A high-performance command-line tool built on `Swift ArgumentParser` for headless operations and automation.
* **Signal Processing**: Integrated data smoothing (rolling average) and stability analysis (standard deviation) to minimize sensor noise.
* **Persistence Layer**: Local profile management for persistent calibration data across sessions.

## 🏗 System Architecture

ForceScale is architected with a strict separation of concerns through a modular target system:

* **`ForceScaleCore`**: The logical backbone, containing the `PressureReader`, `CalibrationEngine`, and `WeightEstimator`. It utilizes dynamic library loading (`dlopen`/`dlsym`) for framework compatibility.
* **`ForceScaleCLI`**: A robust wrapper for the core logic, providing an intuitive command-line interface.
* **`ForceScaleUI`**: A modern, reactive interface that consumes core logic via a dedicated `ObservableObject` view model layer.

## 🛠 Installation & Deployment

### Prerequisites

* **Hardware**: MacBook (2015+) or Magic Trackpad 2 with Force Touch support.
* **Software**: macOS 13.0 (Ventura) or later.
* **Tools**: Xcode 15.0+ or Swift 5.9 toolchain.

### Building from Source

To build the project and install the CLI tool:

```bash
# Clone the repository
git clone https://github.com/ismailtsdln/ForceScale.git
cd ForceScale

# Build the CLI in release mode
swift build -c release

# Install to local bin
cp .build/release/forcescale /usr/local/bin/forcescale
```

### Running the GUI Application

1. Open `ForceScale.xcodeproj` (or the folder in Xcode).
2. Select the `ForceScaleUI` target.
3. **Critical**: Ensure `App Sandboxing` is disabled in the **Signing & Capabilities** tab to allow the application to access private frameworks.
4. Press `Cmd + R` to Build and Run.

## 💻 Command Line Interface (CLI)

#### Calibration

Record a known mass to the calibration profile:

```bash
forcescale calibrate --weight 100
```

#### Real-Time Measurement

Initiate a live measurement session with visual pressure feedback:

```bash
forcescale measure --live
```

#### Data Management

Export the current calibration profile in machine-readable format:

```bash
forcescale export --format json
```

## 🎨 User Interface (GUI)

The GUI provides a premium, technical aesthetic designed for clarity and ease of use:

1. **Measurement Dashboard**: Displays clear mass estimates with visual stability indicators.
2. **Calibration Wizard**: A guided experience for adding multiple calibration points (e.g., 0g, 50g, 100g, 200g) for maximum linear accuracy.
3. **Live Pressure Monitoring**: Real-time bar graph visualizing the raw sensor input across all contact points.
4. **Tare Functionality**: Zero the scale instantly to account for container mass.

## 📐 Mathematical Model

ForceScale utilizes a **Linear Regression** model ($y = mx + b$) to transform raw pressure values (unitless) into estimated mass (grams). The `CalibrationEngine` calculates the slope ($m$) and intercept ($b$) based on user-provided data points, ensuring the model adapts to the specific mechanical characteristics of the host trackpad.

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

*Developed with ❤️ by [Ismail Tasdelen](https://github.com/ismailtasdelen)*
