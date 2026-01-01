import SwiftUI
import ForceScaleCore

struct CalibrationView: View {
    @ObservedObject var viewModel: MeasureViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var calibrationWeight: String = "100"
    @State private var points: [CalibrationPoint] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Calibration Wizard")
                .font(.headline)
            
            Text("To ensure accuracy, please place objects of known weight on the trackpad and record their values.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(alignment: .leading) {
                Text("Known Weight (grams)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Weight in grams", text: $calibrationWeight)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            Button(action: recordPoint) {
                Text("Record Calibration Point")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Divider()
            
            List {
                ForEach(points, id: \.grams) { point in
                    HStack {
                        Text("\(Int(point.grams))g")
                        Spacer()
                        Text(String(format: "Pressure: %.3f", point.pressure))
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deletePoint)
            }
            .frame(height: 150)
            
            HStack(spacing: 20) {
                Button("Clear All") {
                    points.removeAll()
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Save and Close") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .disabled(points.count < 2)
            }
            .padding()
        }
        .frame(width: 400, height: 500)
        .onAppear {
            loadExisting()
        }
    }
    
    private func recordPoint() {
        guard let grams = Double(calibrationWeight) else { return }
        let point = CalibrationPoint(grams: grams, pressure: viewModel.currentPressure)
        points.append(point)
    }
    
    private func deletePoint(at offsets: IndexSet) {
        points.remove(atOffsets: offsets)
    }
    
    private func loadExisting() {
        if let profile = try? Persistence.loadProfile() {
            points = profile.points
        }
    }
    
    private func save() {
        let profile = CalibrationProfile(deviceIdentifier: "Default", points: points)
        try? Persistence.saveProfile(profile)
        viewModel.loadCalibration()
        dismiss()
    }
}
