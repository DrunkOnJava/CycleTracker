import Foundation

struct Administration: Identifiable, Codable {
    let id: UUID
    var date: Date
    var compound: Compound
    var dosage: Double // in mg
    var site: InjectionSite
    var notes: String?
    
    // Calculated volume based on compound concentration
    var volumeML: Double {
        return dosage / compound.concentration
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        compound: Compound,
        dosage: Double,
        site: InjectionSite,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.compound = compound
        self.dosage = dosage
        self.site = site
        self.notes = notes
    }
    
    // Calculate the remaining active amount at a given date
    func remainingAmount(at date: Date) -> Double {
        let hoursElapsed = date.timeIntervalSince(self.date) / 3600
        return compound.calculateRemainingAmount(
            initialAmount: dosage,
            hoursElapsed: hoursElapsed
        )
    }
}

// Extension for grouping and analysis methods
extension Array where Element == Administration {
    // Group administrations by compound
    func groupedByCompound() -> [Compound: [Administration]] {
        Dictionary(grouping: self) { $0.compound }
    }
    
    // Calculate total dosage for a specific compound within a date range
    func totalDosage(
        for compound: Compound,
        from startDate: Date,
        to endDate: Date
    ) -> Double {
        self.filter { administration in
            administration.compound.id == compound.id &&
            administration.date >= startDate &&
            administration.date <= endDate
        }.reduce(0) { $0 + $1.dosage }
    }
    
    // Calculate weekly average dosage for a compound
    func weeklyAverageDosage(
        for compound: Compound,
        from startDate: Date,
        to endDate: Date
    ) -> Double {
        let totalDays = Calendar.current.dateComponents(
            [.day],
            from: startDate,
            to: endDate
        ).day ?? 0
        
        let weeks = Double(totalDays) / 7.0
        guard weeks > 0 else { return 0 }
        
        let totalDosage = self.totalDosage(
            for: compound,
            from: startDate,
            to: endDate
        )
        
        return totalDosage / weeks
    }
    
    // Get most frequently used injection sites
    func mostFrequentSites() -> [(site: InjectionSite, count: Int)] {
        let siteCount = self.reduce(into: [:]) { counts, administration in
            counts[administration.site, default: 0] += 1
        }
        
        return siteCount.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    // Calculate total active amount at a specific date
    func totalActiveAmount(at date: Date) -> Double {
        self.reduce(0) { total, administration in
            total + administration.remainingAmount(at: date)
        }
    }
}
