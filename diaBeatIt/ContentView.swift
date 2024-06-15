import SwiftUI

struct ContentView: View {
    @State private var hgba1c1: String = ""
    @State private var hgba1c2: String = ""
    @State private var hgba1c3: String = ""
    @State private var hgba1c4: String = ""
    @State private var hgba1c5: String = ""
    @State private var averageRealVariability: String = ""
    @State private var category: String = ""
    @State private var categoryDescription: String = ""
    @State private var imageUrl1: String = ""
    @State private var imageUrl2: String = ""
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Enter HgbA1C Data")) {
                    TextField("HgbA1C #1", text: $hgba1c1)
                        .keyboardType(.decimalPad)
                    TextField("HgbA1C #2", text: $hgba1c2)
                        .keyboardType(.decimalPad)
                    TextField("HgbA1C #3", text: $hgba1c3)
                        .keyboardType(.decimalPad)
                    TextField("HgbA1C #4", text: $hgba1c4)
                        .keyboardType(.decimalPad)
                    TextField("HgbA1C #5", text: $hgba1c5)
                        .keyboardType(.decimalPad)
                }
                
                Button(action: calculateAverageRealVariability) {
                    Text("Calculate Average Real Variability")
                }
            }
            
            if !averageRealVariability.isEmpty {
                Text("Average Real Variability: \(averageRealVariability)")
                    .padding()
                Text("Category: \(category)")
                    .padding()
                Text(categoryDescription)
                    .padding()
                VStack {
                    if let url1 = URL(string: imageUrl1) {
                        AsyncImage(url: url1) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                    }
                    if let url2 = URL(string: imageUrl2) {
                        AsyncImage(url: url2) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                    }
                }
            }
        }
        .padding()
    }
    
    func calculateAverageRealVariability() {
        guard let value1 = Double(hgba1c1), let value2 = Double(hgba1c2), let value3 = Double(hgba1c3), let value4 = Double(hgba1c4), let value5 = Double(hgba1c5) else {
            return
        }
        
        let data = [value1, value2, value3, value4, value5]
        if let variability = calculateAverageRealVariability(data: data) {
            averageRealVariability = String(format: "%.3f", variability)
            determineCategory(for: variability)
        } else {
            averageRealVariability = "Error calculating variability."
        }
    }
    
    func calculateAverageRealVariability(data: [Double]) -> Double? {
        guard data.count == 5 else {
            return nil // Need exactly five data points to calculate variability
        }
        
        let differences = [
            abs(data[1] - data[0]),
            abs(data[2] - data[1]),
            abs(data[3] - data[2]),
            abs(data[4] - data[3])
        ]
        
        let totalVariability = differences.reduce(0, +)
        let averageRealVariability = totalVariability / Double(differences.count)
        
        return averageRealVariability
    }
    
    func determineCategory(for variability: Double) {
        switch variability {
        case ..<0.332:
            category = "Low Risk"
            categoryDescription = "You have a 3.8% risk of a major adverse limb event."
            imageUrl1 = "https://your-s3-bucket-url/category1-image1.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/ToeAmp-B.png"
        case 0.332..<0.522:
            category = "Medium Risk"
            categoryDescription = "You have a 4.6% risk of a major adverse limb event."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/TMA-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/TMA-B.png"
        case 0.522..<0.786:
            category = "High Risk"
            categoryDescription = "You have a 5.8% risk of a major adverse limb event."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/BKA-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/BKA-B.png"
        default:
            category = "Very High Risk"
            categoryDescription = "You have a 7.8% risk of a major adverse limb event."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/AKAAmp-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/AKAAmp-B.png"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
