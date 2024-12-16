import Foundation
import Combine

@MainActor
class CycleLogViewModel: ObservableObject {
    @Published private(set) var cycles: [CycleLog] = []
    @Published private(set) var activeCycle: CycleLog?
    @Published var selectedCompounds: [Compound] = Compound.commonCompounds
    @Published var error: String?
    
    // MARK: - Cycle Management
    
    func startNewCycle(name: String, startDate: Date = Date()) {
        // End current cycle if exists
        if let index = cycles.firstIndex(where: { $0.isActive }) {
            cycles[index].endCycle()
        }
        
        let newCycle = CycleLog(name: name, startDate: startDate)
        cycles.append(newCycle)
        activeCycle = newCycle
        saveCycles()
    }
    
    func endCurrentCycle() {
        guard let index = cycles.firstIndex(where: { $0.isActive }) else { return }
        cycles[index].endCycle()
        activeCycle = nil
        saveCycles()
    }
    
    // MARK: - Administration Management
    
    func logAdministration(
        compound: Compound,
        dosage: Double,
        site: InjectionSite,
        date: Date = Date(),
        notes: String? = nil
    ) {
        guard var cycle = activeCycle else {
            error = "No active cycle found. Please start a new cycle first."
            return
        }
        
        let administration = Administration(
            date: date,
            compound: compound,
            dosage: dosage,
            site: site,
            notes: notes
        )
        
        cycle.addAdministration(administration)
        
        if let index = cycles.firstIndex(where: { $0.id == cycle.id }) {
            cycles[index] = cycle
            activeCycle = cycle
            saveCycles()
        }
    }
    
    func removeAdministration(id: UUID) {
        guard var cycle = activeCycle else { return }
        cycle.removeAdministration(id: id)
        
        if let index = cycles.firstIndex(where: { $0.id == cycle.id }) {
            cycles[index] = cycle
            activeCycle = cycle
            saveCycles()
        }
    }
    
    // MARK: - Analysis
    
    func calculateCurrentSerumLevels() -> [Compound: Double] {
        guard let cycle = activeCycle else { return [:] }
        return cycle.calculateTotalSerumLevels(at: Date())
    }
    
    func weeklyAverages() -> [Compound: Double] {
        guard let cycle = activeCycle else { return [:] }
        return cycle.weeklyAverageByCompound()
    }
    
    func siteRotationAnalysis() -> [(InjectionSite, Double)] {
        guard let cycle = activeCycle else { return [] }
        return cycle.siteRotationAnalysis()
    }
    
    // MARK: - Persistence
    
    private func saveCycles() {
        do {
            let data = try JSONEncoder().encode(cycles)
            try data.write(to: getCyclesFileURL())
        } catch {
            self.error = "Failed to save cycles: \(error.localizedDescription)"
        }
    }
    
    private func loadCycles() {
        do {
            let data = try Data(contentsOf: getCyclesFileURL())
            cycles = try JSONDecoder().decode([CycleLog].self, from: data)
            activeCycle = cycles.first(where: { $0.isActive })
        } catch {
            // If file doesn't exist or is corrupted, start fresh
            cycles = []
            activeCycle = nil
        }
    }
    
    private func getCyclesFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentsDirectory.appendingPathComponent("cycles.json")
    }
    
    // MARK: - Initialization
    
    init() {
        loadCycles()
    }
}

// MARK: - Helper Extensions

extension CycleLogViewModel {
    func getRecommendedSite() -> InjectionSite {
        guard let cycle = activeCycle,
              !cycle.administrations.isEmpty else {
            return .gluteus // Default to gluteus if no history
        }
        
        // Get site usage frequencies
        let siteUsage = cycle.siteRotationAnalysis()
        
        // Find least used site
        return InjectionSite.allCases
            .min { a, b in
                let aUsage = siteUsage.first { $0.0 == a }?.1 ?? 0
                let bUsage = siteUsage.first { $0.0 == b }?.1 ?? 0
                return aUsage < bUsage
            } ?? .gluteus
    }
    
    func validateDosage(_ dosage: Double, for compound: Compound) -> Bool {
        guard let range = compound.recommendedDosage else { return true }
        return range.contains(dosage)
    }
}
