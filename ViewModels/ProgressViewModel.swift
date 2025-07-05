private func yearChartDataWithNumbers() -> [DailyDuration] {
    let calendar = Calendar.current
    let start = yearStart(for: currentPage)
    let yearComponent = calendar.component(.year, from: start)
    var monthDurations: [Double?] = Array(repeating: nil, count: 12)
    for m in allMeasurements {
        if calendar.component(.year, from: m.date) == yearComponent {
            let month = calendar.component(.month, from: m.date) - 1
            print("Measurement: \(m.date), month index: \(month), duration: \(m.durationSeconds)")
            if month >= 0 && month < 12 {
                monthDurations[month] = max(monthDurations[month] ?? 0, m.durationSeconds)
            }
        }
    }
    return (0..<12).map { i in DailyDuration(day: "\(i+1)", duration: monthDurations[i]) }
} 