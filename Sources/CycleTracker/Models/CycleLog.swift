import Foundation

struct CycleLog: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var administrations: [Administration]
    var notes: String?
    var name: String
    
    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date = Date(),
        endDate: Date? = nil,
        administrations: [Administration] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.administrations = administrations
        self.notes = notes
    }
    
    // Computed Properties
    var isActive: Bool {
        endDate == nil
    }
    
    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }
    
    var durationInWeeks: Int {
        Int(ceil(duration / (7 * 24 * 3600)))
    }
    
    // Analysis Methods
    func totalDosageByCompound() -> [Compound: Double] {
        Dictionary(
            grouping: administrations,
            by: { $0.compound }
        ).mapValues { administrations in
            administrations.reduce(0) { $0 + $1.dosage }
        }
    }
    
    func weeklyAverageByCompound() -> [Compound: Double] {
        let weeks = Double(durationInWeeks)
        guard weeks > 0 else { return [:] }
        
        return totalDosageByCompound().mapValues { $0 / weeks }
    }
    
    func siteRotationAnalysis() -> [(InjectionSite, Double)] {
        let siteCount = administrations.reduce(into: [:]) { counts, administration in
            counts[administration.site, default: 0] += 1
        }
        
        let total = Double(administrations.count)
        return siteCount.map { site, count in
            (site, Double(count) / total * 100)
        }.sorted { $0.1 > $1.1 }
    }
    
    func calculateTotalSerumLevels(at date: Date) -> [Compound: Double] {
        Dictionary(
            grouping: administrations,
            by: { $0.compound }
        ).mapValues { administrations in
            administrations.reduce(0) { total, administration in
                total + administration.remainingAmount(at: date)
            }
        }
    }
    
    // Helper Methods
    mutating func addAdministration(_ administration: Administration) {
        administrations.append(administration)
        administrations.sort { $0.date < $1.date }
    }
    
    mutating func removeAdministration(id: UUID) {
        administrations.removeAll { $0.id == id }
    }
    
    mutating func endCycle() {
        endDate = Date()
    }
}

// Extension for managing multiple cycles
extension Array where Element == CycleLog {
    var activeCycle: CycleLog? {
        self.first { $0.isActive }
    }
    
    func cycleHistory(for compound: Compound) -> [(date: Date, amount: Double)] {
        self.flatMap { cycle in
            cycle.administrations
                .filter { $0.compound.id == compound.id }
                .map { (date: $0.date, amount: $0.dosage) }
        }.sorted { $0.date < $1.date }
    }
    
    func averageCycleDuration() -> TimeInterval? {
        let completedCycles = self.filter { $0.endDate != nil }
        guard !completedCycles.isEmpty else { return nil }
        
        let totalDuration = completedCycles.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(completedCycles.count)
    }
}
