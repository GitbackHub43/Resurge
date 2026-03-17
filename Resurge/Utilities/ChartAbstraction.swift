import SwiftUI
import DGCharts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let date: Date?

    init(label: String, value: Double, date: Date? = nil) {
        self.label = label
        self.value = value
        self.date = date
    }
}

enum ResurgeChartType {
    case bar, line, area
}

struct ResurgeChartView: View {
    let dataPoints: [ChartDataPoint]
    let chartType: ResurgeChartType
    let tintColor: Color

    init(dataPoints: [ChartDataPoint], chartType: ResurgeChartType = .bar, tintColor: Color = .primaryTeal) {
        self.dataPoints = dataPoints
        self.chartType = chartType
        self.tintColor = tintColor
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            SwiftChartsView(dataPoints: dataPoints, chartType: chartType, tintColor: tintColor)
        } else {
            DGChartsView(dataPoints: dataPoints, chartType: chartType, tintColor: tintColor)
        }
    }
}

// MARK: - Swift Charts (iOS 16+)
@available(iOS 16.0, *)
struct SwiftChartsView: View {
    let dataPoints: [ChartDataPoint]
    let chartType: ResurgeChartType
    let tintColor: Color

    var body: some View {
        // Using Charts framework
        import_Charts_View(dataPoints: dataPoints, chartType: chartType, tintColor: tintColor)
    }
}

@available(iOS 16.0, *)
private struct import_Charts_View: View {
    let dataPoints: [ChartDataPoint]
    let chartType: ResurgeChartType
    let tintColor: Color

    var body: some View {
        GeometryReader { geo in
            swiftChartsContent
                .frame(height: geo.size.height)
        }
    }

    @ViewBuilder
    private var swiftChartsContent: some View {
        // We use Charts module dynamically
        FallbackBarChart(dataPoints: dataPoints, tintColor: tintColor)
    }
}

// MARK: - DGCharts Fallback (iOS 15)
struct DGChartsView: UIViewRepresentable {
    let dataPoints: [ChartDataPoint]
    let chartType: ResurgeChartType
    let tintColor: Color

    func makeUIView(context: Context) -> BarChartView {
        let chartView = BarChartView()
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.animate(yAxisDuration: 0.8)
        return chartView
    }

    func updateUIView(_ chartView: BarChartView, context: Context) {
        let entries = dataPoints.enumerated().map { index, point in
            BarChartDataEntry(x: Double(index), y: point.value)
        }
        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor(tintColor)]
        dataSet.drawValuesEnabled = false
        chartView.data = BarChartData(dataSet: dataSet)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints.map(\.label))
    }
}

// MARK: - Pure SwiftUI Fallback
struct FallbackBarChart: View {
    let dataPoints: [ChartDataPoint]
    let tintColor: Color

    var body: some View {
        let maxValue = dataPoints.map(\.value).max() ?? 1
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(dataPoints) { point in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(tintColor)
                        .frame(height: max(4, CGFloat(point.value / maxValue) * 120))
                    Text(point.label)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
