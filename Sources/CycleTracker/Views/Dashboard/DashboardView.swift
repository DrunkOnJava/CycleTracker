import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @ObservedObject var cycleLogVM: CycleLogViewModel
    
    init(cycleLogVM: CycleLogViewModel) {
        self.cycleLogVM = cycleLogVM
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(cycleLogVM: cycleLogVM))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    timeRangeSelector
                    
                    if let activeCycle = cycleLogVM.activeCycle {
                        activeCycleCard(activeCycle)
                        serumLevelsChart
                        weeklyAveragesChart
                        siteDistributionChart
                        recentAdministrationsList
                    } else {
                        noCycleView
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.updateDashboard() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            Text("24h").tag(DashboardViewModel.TimeRange.day)
            Text("Week").tag(DashboardViewModel.TimeRange.week)
            Text("Month").tag(DashboardViewModel.TimeRange.month)
            Text("All").tag(DashboardViewModel.TimeRange.all)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private func activeCycleCard(_ cycle: CycleLog) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(cycle.name)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Started")
                    Text(cycle.startDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Duration")
                    Text("\(cycle.durationInWeeks) weeks")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var serumLevelsChart: some View {
        ChartCard(title: "Serum Levels") {
            Chart(viewModel.generateSerumLevelChartData(), id: \.0) { dataPoint in
                ForEach(Array(dataPoint.1.keys), id: \.id) { compound in
                    LineMark(
                        x: .value("Date", dataPoint.0),
                        y: .value("Level", dataPoint.1[compound] ?? 0)
                    )
                    .foregroundStyle(by: .value("Compound", compound.name))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .frame(height: 200)
        }
    }
    
    private var weeklyAveragesChart: some View {
        ChartCard(title: "Weekly Averages") {
            Chart(viewModel.generateWeeklyAveragesChartData(), id: \.0.id) { data in
                BarMark(
                    x: .value("Compound", data.0.name),
                    y: .value("Average", data.1)
                )
                .foregroundStyle(by: .value("Compound", data.0.name))
            }
            .frame(height: 200)
        }
    }
    
    private var siteDistributionChart: some View {
        ChartCard(title: "Injection Site Distribution") {
            Chart(viewModel.generateSiteDistributionChartData(), id: \.0) { data in
                SectorMark(
                    angle: .value("Percentage", data.1),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.0
                )
                .foregroundStyle(by: .value("Site", data.0.rawValue))
            }
            .frame(height: 200)
        }
    }
    
    private var recentAdministrationsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Administrations")
                .font(.headline)
            
            ForEach(viewModel.recentAdministrations) { administration in
                AdministrationRow(administration: administration)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var noCycleView: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("No Active Cycle")
                .font(.title2)
            
            Text("Start a new cycle to begin tracking")
                .foregroundColor(.secondary)
            
            Button("Start New Cycle") {
                // Show new cycle sheet
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct AdministrationRow: View {
    let administration: Administration
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(administration.compound.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(administration.dosage, specifier: "%.1f")mg at \(administration.site.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(administration.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    DashboardView(cycleLogVM: CycleLogViewModel())
}
