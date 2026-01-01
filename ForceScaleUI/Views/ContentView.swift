import SwiftUI
import ForceScaleCore

struct ContentView: View {
    @StateObject private var viewModel = MeasureViewModel()
    @State private var showingCalibration = false
    
    private var isSensorAvailable: Bool {
        return MultitouchBridge.isAvailable
    }
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ForceScale")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        if !isSensorAvailable {
                            Text("Sensor not found")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()
                    Button(action: { showingCalibration = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help("Calibration")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Main Weight Display
                VStack(spacing: 15) {
                    Text(String(format: "%.1f", viewModel.currentWeight))
                        .font(.system(size: 80, weight: .thin, design: .monospaced))
                        .foregroundColor(viewModel.isStable ? .primary : .primary.opacity(0.8))
                        .scaleEffect(viewModel.isStable ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isStable)
                    
                    Text("GRAMS")
                        .font(.caption)
                        .kerning(4)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.primary.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(viewModel.isStable ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
                        )
                )
                
                // Pressure Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Pressure")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.3f", viewModel.currentPressure))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.primary.opacity(0.1))
                                .frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * min(CGFloat(viewModel.currentPressure), 1.0), height: 4)
                                .animation(.interactiveSpring(), value: viewModel.currentPressure)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal)
                
                // Stability & Status
                HStack {
                    StatusIndicator(isValid: viewModel.isCalibrated, label: "Calibrated")
                    Spacer()
                    StatusIndicator(isValid: viewModel.isStable, label: "Stable")
                }
                .padding(.horizontal)
                
                // Controls
                HStack(spacing: 20) {
                    Button(action: { viewModel.tare() }) {
                        Text("TARE")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { viewModel.resetTare() }) {
                        Text("RESET")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Disclaimer
                Text("EXPERIMENTAL MEASUREMENT\nNOT FOR PROFESSIONAL USE")
                    .font(.system(size: 10, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary.opacity(0.4))
                    .padding(.bottom, 10)
            }
            .padding()
        }
        .frame(width: 350, height: 550)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(isPresented: $showingCalibration) {
            CalibrationView(viewModel: viewModel)
        }
    }
}

struct StatusIndicator: View {
    let isValid: Bool
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isValid ? Color.green : Color.yellow.opacity(0.5))
                .frame(width: 6, height: 6)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary.opacity(0.8))
        }
    }
}
