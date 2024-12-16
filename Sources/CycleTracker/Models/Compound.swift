import Foundation

struct Compound: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: CompoundType
    var halfLife: Double // in hours
    var concentration: Double // mg/mL
    var recommendedDosage: ClosedRange<Double>? // mg per week
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: CompoundType,
        halfLife: Double,
        concentration: Double,
        recommendedDosage: ClosedRange<Double>? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.halfLife = halfLife
        self.concentration = concentration
        self.recommendedDosage = recommendedDosage
        self.notes = notes
    }
    
    // Helper method to calculate remaining active compound at a given time
    func calculateRemainingAmount(initialAmount: Double, hoursElapsed: Double) -> Double {
        // Using the half-life formula: A(t) = A₀ * (1/2)^(t/t₁/₂)
        // Where:
        // A(t) = Amount remaining after time t
        // A₀ = Initial amount
        // t = Time elapsed
        // t₁/₂ = Half-life
        
        let halfLifePeriods = hoursElapsed / halfLife
        return initialAmount * pow(0.5, halfLifePeriods)
    }
}

// Extension to provide some common compound presets
extension Compound {
    static let commonCompounds: [Compound] = [
        Compound(
            name: "Testosterone Enanthate",
            type: .testosterone,
            halfLife: 168, // 7 days
            concentration: 250,
            recommendedDosage: 300...600
        ),
        Compound(
            name: "Testosterone Cypionate",
            type: .testosterone,
            halfLife: 192, // 8 days
            concentration: 200,
            recommendedDosage: 300...600
        ),
        Compound(
            name: "Nandrolone Decanoate",
            type: .nandrolone,
            halfLife: 360, // 15 days
            concentration: 200,
            recommendedDosage: 200...400
        ),
        // Add more common compounds as needed
    ]
}
