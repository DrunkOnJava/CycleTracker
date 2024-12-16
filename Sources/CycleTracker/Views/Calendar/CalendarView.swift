import SwiftUI

struct CalendarView: View {
    @ObservedObject var cycleLogVM: CycleLogViewModel
    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var administrationsByDate: [Date: [Administration]] {
        guard let cycle = cycleLogVM.activeCycle else { return [:] }
        return Dictionary(grouping: cycle.administrations) { administration in
            calendar.startOfDay(for: administration.date)
        }
    }
    
    var body: some View {
        NavigationView {
            if cycleLogVM.activeCycle == nil {
                noCycleView
            } else {
                VStack(spacing: 0) {
                    calendarHeader
                    weekdayHeader
                    calendarGrid
                    
                    if let selectedDayAdministrations = administrationsByDate[calendar.startOfDay(for: selectedDate)] {
                        administrationsList(selectedDayAdministrations)
                    } else {
                        noAdministrationsView
                    }
                }
                .navigationTitle("Calendar")
            }
        }
    }
    
    private var noCycleView: some View {
        VStack(spacing: 20) {
            Text("No Active Cycle")
                .font(.headline)
            
            Text("Start a new cycle to view administrations calendar")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start New Cycle") {
                // Show new cycle sheet
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            
            Text(dateFormatter.string(from: selectedDate))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    showingDatePicker = true
                }
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .sheet(isPresented: $showingDatePicker) {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .presentationDetents([.medium])
        }
    }
    
    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarGrid: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        let firstDayOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: selectedDate)
        )!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = firstWeekday - 1
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(0..<offsetDays, id: \.self) { _ in
                Color.clear
                    .aspectRatio(1, contentMode: .fill)
            }
            
            ForEach(1...daysInMonth, id: \.self) { day in
                let date = calendar.date(
                    byAdding: .day,
                    value: day - 1,
                    to: firstDayOfMonth
                )!
                
                CalendarDayView(
                    day: day,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    hasAdministrations: administrationsByDate[calendar.startOfDay(for: date)] != nil
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding()
    }
    
    private func administrationsList(_ administrations: [Administration]) -> some View {
        List {
            ForEach(administrations) { administration in
                AdministrationRow(administration: administration)
            }
        }
    }
    
    private var noAdministrationsView: some View {
        VStack(spacing: 10) {
            Text("No Administrations")
                .font(.headline)
            Text("No administrations logged for this date")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(
            byAdding: .month,
            value: -1,
            to: selectedDate
        ) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(
            byAdding: .month,
            value: 1,
            to: selectedDate
        ) {
            selectedDate = newDate
        }
    }
}

struct CalendarDayView: View {
    let day: Int
    let isSelected: Bool
    let hasAdministrations: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.clear)
            
            Text("\(day)")
                .foregroundColor(isSelected ? .white : .primary)
            
            if hasAdministrations && !isSelected {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
                    .offset(y: 12)
            }
        }
        .aspectRatio(1, contentMode: .fill)
    }
}

#Preview {
    CalendarView(cycleLogVM: CycleLogViewModel())
}
