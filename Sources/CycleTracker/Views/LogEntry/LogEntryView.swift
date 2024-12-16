import SwiftUI
import Combine

// Import our models
struct LogEntryView: View {
    @ObservedObject var cycleLogVM: CycleLogViewModel
    @State private var selectedCompound: Compound?
    @State private var dosage: String = ""
    @State private var selectedSite: InjectionSite = .gluteus
    @State private var notes: String = ""
    @State private var selectedDate = Date()
    @State private var showingCompoundPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var recommendedSite: InjectionSite {
        cycleLogVM.getRecommendedSite()
    }
    
    var body: some View {
        NavigationView {
            Form {
                if cycleLogVM.activeCycle == nil {
                    noCycleSection
                } else {
                    administrationForm
                }
            }
            .navigationTitle("Log Entry")
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var noCycleSection: some View {
        Section {
            VStack(spacing: 20) {
                Text("No Active Cycle")
                    .font(.headline)
                
                Text("Start a new cycle to begin logging administrations")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Start New Cycle") {
                    // Show new cycle sheet
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    private var administrationForm: some View {
        Group {
            compoundSection
            dosageSection
            injectionSiteSection
            dateSection
            notesSection
            
            Section {
                Button(action: logAdministration) {
                    Text("Log Administration")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.accentColor)
                .disabled(selectedCompound == nil || dosage.isEmpty)
            }
        }
    }
    
    private var compoundSection: some View {
        Section(header: Text("Compound")) {
            if let compound = selectedCompound {
                compoundRow(compound)
            }
            
            Button(action: { showingCompoundPicker = true }) {
                if selectedCompound == nil {
                    Text("Select Compound")
                        .foregroundColor(.accentColor)
                } else {
                    Text("Change Compound")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingCompoundPicker) {
            CompoundPickerView(
                selectedCompound: $selectedCompound,
                compounds: cycleLogVM.selectedCompounds
            )
        }
    }
    
    private var dosageSection: some View {
        Section(header: Text("Dosage")) {
            HStack {
                TextField("Dosage", text: $dosage)
                    .keyboardType(.decimalPad)
                Text("mg")
                    .foregroundColor(.secondary)
            }
            
            if let compound = selectedCompound,
               let range = compound.recommendedDosage {
                Text("Recommended: \(range.lowerBound, specifier: "%.1f") - \(range.upperBound, specifier: "%.1f") mg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var injectionSiteSection: some View {
        Section(header: Text("Injection Site")) {
            Picker("Site", selection: $selectedSite) {
                ForEach(InjectionSite.allCases, id: \.self) { site in
                    Text(site.rawValue.capitalized)
                        .tag(site)
                }
            }
            
            Text("Recommended site: \(recommendedSite.rawValue.capitalized)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var dateSection: some View {
        Section(header: Text("Date")) {
            DatePicker(
                "Administration Date",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
    
    private var notesSection: some View {
        Section(header: Text("Notes")) {
            TextEditor(text: $notes)
                .frame(height: 100)
        }
    }
    
    private func compoundRow(_ compound: Compound) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(compound.name)
                .font(.headline)
            
            Text("\(compound.concentration) mg/ml")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func logAdministration() {
        guard let compound = selectedCompound,
              let dosageValue = Double(dosage) else {
            alertMessage = "Please enter a valid dosage"
            showAlert = true
            return
        }
        
        if !cycleLogVM.validateDosage(dosageValue, for: compound) {
            alertMessage = "Dosage is outside recommended range"
            showAlert = true
            return
        }
        
        cycleLogVM.logAdministration(
            compound: compound,
            dosage: dosageValue,
            site: selectedSite,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        // Reset form
        dosage = ""
        notes = ""
        selectedDate = Date()
    }
}

struct CompoundPickerView: View {
    @Binding var selectedCompound: Compound?
    let compounds: [Compound]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(compounds) { compound in
                Button(action: {
                    selectedCompound = compound
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(compound.name)
                                .font(.headline)
                            Text("\(compound.concentration) mg/ml")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCompound?.id == compound.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Select Compound")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

#Preview {
    LogEntryView(cycleLogVM: CycleLogViewModel())
}
