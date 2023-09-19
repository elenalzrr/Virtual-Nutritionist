import SwiftUICharts
import SwiftUI

struct ProgressChart: View {
    var demoData: [Double] = []
    var body: some View {
        VStack {
            let chartStyle = ChartStyle(backgroundColor: Color(red: 0.792, green: 0.941, blue: 0.973),
                accentColor: Color(red: 0.886, green: 0.639, blue: 0.702),
                secondGradientColor: Color(red: 0/255, green: 119/255, blue: 182/255),
                textColor: Color(red: 0.886, green: 0.639, blue: 0.702),
                legendTextColor: Color(red: 0.886, green: 0.639, blue: 0.702),
                dropShadowColor: Color(red: 0.886, green: 0.639, blue: 0.702) )
            LineView(data: demoData, title: "",style: chartStyle)
                .padding()
                .position(x:170,y:20)
        }
        
        
    }
}

struct ProgressChart_Previews: PreviewProvider {
    static var previews: some View {
        ProgressChart()
    }
}
