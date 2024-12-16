import Foundation
import Combine
import Charts
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published private(set) var serumLevels: [Compound: Double] = [:]
    @Published private(set) var weeklyAverages: [Compound: Double] = [:]
    @Published private(set) var siteDistribution: [(InjectionSite, Double)] = []
    @Published private(set) var recentAdministrations: [Administration] = []
    @Published var selectedTimeRange: TimeRange = .week
    
    private var cycleLogVM: CycleLogViewModel
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    enum TimeRange {
        case day, week, month, all
        
        var days: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            case .all: return Int.max
            }
        }
    }
    
    init(cycleLogVM: CycleLogViewModel) {
        self.cycleLogVM = cycleLogVM
        setupBindings()
        startPeriodicUpdates()
    }
    
    private func setupBindings() {
        // Update dashboard when active cycle changes
        cycleLogVM.$activeCycle
            .sink { [weak self] _ in
                self?.updateDashboard()
            }
            .store(in: &cancellables)
    }
    
    private func startPeriodicUpdates() {
        // Update serum levels every hour
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateSerumLevels()
        }
    }
    
    func updateDashboard() {
        updateSerumLevels()
        updateWeeklyAverages()
        updateSiteDistribution()
        updateRecentAdministrations()
    }
    
    private func updateSerumLevels() {
        serumLevels = cycleLogVM.calculateCurrentSerumLevels()
    }
    
    private func updateWeeklyAverages() {
        weeklyAverages = cycleLogVM.weeklyAverages()
    }
    
    private func updateSiteDistribution() {
        siteDistribution = cycleLogVM.siteRotationAnalysis()
    }
    
    private func updateRecentAdministrations() {
        guard let cycle = cycleLogVM.activeCycle else {
            recentAdministrations = []
            return
        }
        
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -selectedTimeRange.days,
            to: Date()
        ) ?? Date()
        
        recentAdministrations = cycle.administrations
            .filter { $0.date >= cutoffDate }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Chart Data Generation
    
    func generateSerumLevelChartData() -> [(Date, [Compound: Double])] {
        guard let cycle = cycleLogVM.activeCycle else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(
            byAdding: .day,
            value: -selectedTimeRange.days,
            to: now
        ) ?? now
        
        // Generate data points for every 6 hours
        var dataPoints: [(Date, [Compound: Double])] = []
        var currentDate = startDate
        
        while currentDate <= now {
            let levels = cycle.calculateTotalSerumLevels(at: currentDate)
            dataPoints.append((currentDate, levels))
            
            currentDate = calendar.date(
                byAdding: .hour,
                value: 6,
                to: currentDate
            ) ?? currentDate
        }
        
        return dataPoints
    }
    
    func generateSiteDistributionChartData() -> [(InjectionSite, Double)] {
        siteDistribution
    }
    
    func generateWeeklyAveragesChartData() -> [(Compound, Double)] {
        weeklyAverages.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    // MARK: - Statistics
    
    func getMostUsedSite() -> InjectionSite? {
        siteDistribution.first?.0
    }
    
    func getHighestWeeklyDosage() -> (Compound, Double)? {
        weeklyAverages.max { $0.value < $1.value }
            .map { ($0.key, $0.value) }
    }
    
    func getTotalAdministrations() -> Int {
        recentAdministrations.count
    }
    
    func getAverageDailyAdministrations() -> Double {
        guard !recentAdministrations.isEmpty else { return 0 }
        return Double(recentAdministrations.count) / Double(selectedTimeRange.days)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}
