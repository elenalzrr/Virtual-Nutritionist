import SwiftUI
import SwiftUICharts

struct CaloriesView: View {
    var dataDemo: [(String,Double)] = []
    var body: some View {
        let chartStyle = ChartStyle(backgroundColor: Color(red: 0.792, green: 0.941, blue: 0.973),
            accentColor: Color(red: 0.886, green: 0.639, blue: 0.702),
            secondGradientColor: Color(red: 0/255, green: 119/255, blue: 182/255),
            textColor: Color(red: 0.886, green: 0.639, blue: 0.702),
            legendTextColor: Color(red: 0.886, green: 0.639, blue: 0.702),
            dropShadowColor: Color(red: 0.886, green: 0.639, blue: 0.702) )
        BarChartView(data: ChartData(values: dataDemo), title: "", style: chartStyle)
        
    }
}

struct CaloriesView_Previews: PreviewProvider {
    static var previews: some View {
        CaloriesView()
    }
}
