import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MeasureViewModel()
    @State private var showingCalibration = false
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Text("ForceScale")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
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
                VStack(spacing: 10) {
                    Text(String(format: "%.1f", viewModel.currentWeight))
                        .font(.system(size: 80, weight: .thin, design: .monospaced))
                    Text("GRAMS")
                        .font(.caption)
                        .kerning(4)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.primary.opacity(0.05))
                )
                
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
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { viewModel.resetTare() }) {
                        Text("RESET")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Disclaimer
                Text("EXPERIMENTAL MEASUREMENT\nNOT FOR PROFESSIONAL USE")
                    .font(.system(size: 10, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .frame(width: 350, height: 500)
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
                .fill(isValid ? Color.green : Color.yellow)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
