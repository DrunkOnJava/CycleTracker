import SwiftUI
import Combine

// Import our models
struct SettingsView: View {
    @ObservedObject var cycleLogVM: CycleLogViewModel
    @State private var showingNewCompoundSheet = false
    @State private var showingDeleteAlert = false
    @State private var compoundToDelete: Compound?
    @AppStorage("useBiometrics") private var useBiometrics = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                cycleSection
                compoundsSection
                notificationsSection
                securitySection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }
    
    private var cycleSection: some View {
        Section(header: Text("Current Cycle")) {
            if let activeCycle = cycleLogVM.activeCycle {
                VStack(alignment: .leading) {
                    Text(activeCycle.name)
                        .font(.headline)
                    Text("Started \(activeCycle.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("End Cycle", role: .destructive) {
                    cycleLogVM.endCurrentCycle()
                }
            } else {
                Button("Start New Cycle") {
                    // Show new cycle sheet
                }
            }
        }
    }
    
    private var compoundsSection: some View {
        Section(header: Text("Compounds")) {
            ForEach(cycleLogVM.selectedCompounds) { compound in
                CompoundRow(compound: compound)
                    .swipeActions {
                        Button(role: .destructive) {
                            compoundToDelete = compound
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            
            Button(action: { showingNewCompoundSheet = true }) {
                Label("Add Compound", systemImage: "plus")
            }
        }
        .alert("Delete Compound", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let compound = compoundToDelete {
                    // Remove compound
                    compoundToDelete = nil
                }
            }
        } message: {
            if let compound = compoundToDelete {
                Text("Are you sure you want to delete \(compound.name)?")
            }
        }
        .sheet(isPresented: $showingNewCompoundSheet) {
            CompoundFormView(cycleLogVM: cycleLogVM)
        }
    }
    
    private var notificationsSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
            
            if notificationsEnabled {
                NavigationLink("Notification Settings") {
                    NotificationSettingsView()
                }
            }
        }
    }
    
    private var securitySection: some View {
        Section(header: Text("Security")) {
            Toggle("Use Face ID / Touch ID", isOn: $useBiometrics)
            
            NavigationLink("Privacy Policy") {
                PrivacyPolicyView()
            }
            
            NavigationLink("Data & Backup") {
                DataBackupView()
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundColor(.secondary)
            }
            
            NavigationLink("Help & Support") {
                HelpSupportView()
            }
            
            Link("Rate on App Store", destination: URL(string: "https://apps.apple.com")!)
        }
    }
}

struct CompoundRow: View {
    let compound: Compound
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(compound.name)
                .font(.headline)
            
            HStack {
                Text("\(compound.concentration) mg/ml")
                Text("•")
                Text("Half-life: \(Int(compound.halfLife))h")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CompoundFormView: View {
    @ObservedObject var cycleLogVM: CycleLogViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type = CompoundType.testosterone
    @State private var concentration = ""
    @State private var halfLife = ""
    @State private var minDosage = ""
    @State private var maxDosage = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(CompoundType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    HStack {
                        TextField("Concentration", text: $concentration)
                            .keyboardType(.decimalPad)
                        Text("mg/ml")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Half Life", text: $halfLife)
                            .keyboardType(.decimalPad)
                        Text("hours")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Recommended Dosage")) {
                    HStack {
                        TextField("Minimum", text: $minDosage)
                            .keyboardType(.decimalPad)
                        Text("mg")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Maximum", text: $maxDosage)
                            .keyboardType(.decimalPad)
                        Text("mg")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Compound")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveCompound()
                }
                .disabled(name.isEmpty || concentration.isEmpty || halfLife.isEmpty)
            )
        }
    }
    
    private func saveCompound() {
        guard let concentrationValue = Double(concentration),
              let halfLifeValue = Double(halfLife) else {
            return
        }
        
        let minDosageValue = Double(minDosage)
        let maxDosageValue = Double(maxDosage)
        
        let compound = Compound(
            name: name,
            type: type,
            halfLife: halfLifeValue,
            concentration: concentrationValue,
            recommendedDosage: minDosageValue != nil && maxDosageValue != nil
                ? minDosageValue!...maxDosageValue!
                : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        // Add compound to selected compounds
        // cycleLogVM.addCompound(compound)
        
        dismiss()
    }
}

// Placeholder Views
struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy")
    }
}

struct DataBackupView: View {
    var body: some View {
        Text("Data & Backup")
    }
}

struct HelpSupportView: View {
    var body: some View {
        Text("Help & Support")
    }
}

#Preview {
    SettingsView(cycleLogVM: CycleLogViewModel())
}
