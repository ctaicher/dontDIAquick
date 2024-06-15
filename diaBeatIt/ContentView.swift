import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack {
            Image("logo") // Use your image asset here
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            HStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(0.2 * Double(index))
                        )
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

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
    @State private var imageUrl2: String?
    @State private var navigateToResult: Bool = false
    @State private var isLoading = true
    @FocusState private var focusedField: Field?

        enum Field: Int, CaseIterable {
            case hgba1c1, hgba1c2, hgba1c3, hgba1c4, hgba1c5
        }

    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            isLoading = false
                        }
                    }
            } else {
                NavigationView {
                    VStack {
                        VStack {
                            Text("Ampulert")
                                .font(.system(size: UIFont.preferredFont(forTextStyle: .headline).pointSize * 1.5))
                            Text("Helping you track YOUR RISK OF LOSING A LEG from Diabetes. \nEnter your last five Hemoglobin-A1C blood test results.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .lineLimit(nil)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal) // Optional: add padding for better appearance
                    }
                    .padding(.top) // Optional: add top padding to avoid overlap with navigation bar

                        Form {
                                                    Section(header: Text("Enter Hemoglobin-A1Cs")) {
                                                        TextField("HgbA1C #1", text: $hgba1c1)
                                                            .keyboardType(.decimalPad)
                                                            .focused($focusedField, equals: .hgba1c1)
                                                            .onChange(of: hgba1c1) { newValue in
                                                                if !newValue.isEmpty {
                                                                    focusedField = .hgba1c2
                                                                }
                                                            }
                                                        
                                                        TextField("HgbA1C #2", text: $hgba1c2)
                                                            .keyboardType(.decimalPad)
                                                            .focused($focusedField, equals: .hgba1c2)
                                                            .onChange(of: hgba1c2) { newValue in
                                                                if !newValue.isEmpty {
                                                                    focusedField = .hgba1c3
                                                                }
                                                            }
                                                        
                                                        TextField("HgbA1C #3", text: $hgba1c3)
                                                            .keyboardType(.decimalPad)
                                                            .focused($focusedField, equals: .hgba1c3)
                                                            .onChange(of: hgba1c3) { newValue in
                                                                if !newValue.isEmpty {
                                                                    focusedField = .hgba1c4
                                                                }
                                                            }
                                                        
                                                        TextField("HgbA1C #4", text: $hgba1c4)
                                                            .keyboardType(.decimalPad)
                                                            .focused($focusedField, equals: .hgba1c4)
                                                            .onChange(of: hgba1c4) { newValue in
                                                                if !newValue.isEmpty {
                                                                    focusedField = .hgba1c5
                                                                }
                                                            }
                                                        
                                                        TextField("HgbA1C #5", text: $hgba1c5)
                                                            .keyboardType(.decimalPad)
                                                            .focused($focusedField, equals: .hgba1c5)
                                                            .onChange(of: hgba1c5) { newValue in
                                                                if !newValue.isEmpty {
                                                                    focusedField = nil
                                                                    // Optionally, you can dismiss the keyboard here
                                                                }
                                                            }
                                                    }

                            Button(action: {
                                calculateAverageRealVariability()
                                navigateToResult = true
                            }) {
                                Text("Calculate Risk")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(DefaultButtonStyle())
                            }

                        NavigationLink(
                            destination: ResultView(
                                averageRealVariability: averageRealVariability,
                                category: category,
                                categoryDescription: categoryDescription,
                                imageUrl1: imageUrl1,
                                imageUrl2: imageUrl2
                            ),
                            isActive: $navigateToResult
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        }
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
        case ..<0.15:
            category = "Very Low Risk"
            categoryDescription = "Over the next 4-6 years you have a 2.6% risk of a major adverse limb event like amputation or arterial blood clot requiring surgery."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/NPFeet.png"
            imageUrl2 = nil
        case 0.15..<0.332:
            category = "Low Risk"
            categoryDescription = "Over the next 4-6 years you have a 3.8% risk of a major adverse limb event like amputation or arterial blood clot requiring surgery."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/ToeAmp-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/ToeAmp-B.png"
        case 0.332..<0.522:
            category = "Medium Risk"
            categoryDescription = "Over the next 4-6 years you have a 4.6% risk of a major adverse limb event like amputation or arterial blood clot requiring surgery."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/TMA-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/TMA-B.png"
        case 0.522..<0.786:
            category = "High Risk"
            categoryDescription = "Over the next 4-6 years you have a 5.8% risk of a major adverse limb event like amputation or arterial blood clot requiring surgery."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/BKA-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/BKA-B.png"
        default:
            category = "Very High Risk"
            categoryDescription = "Over the next 4-6 years you have a 7.8% risk of a major adverse limb event like amputation or arterial blood clot requiring surgery."
            imageUrl1 = "https://dontdiaquick.s3.amazonaws.com/AKAAmp-A.png"
            imageUrl2 = "https://dontdiaquick.s3.amazonaws.com/AKAAmp-B.png"
        }
    }
}

struct ResultView: View {
    var averageRealVariability: String
    var category: String
    var categoryDescription: String
    var imageUrl1: String
    var imageUrl2: String?

    var body: some View {
        ScrollView {
            VStack {
                Text("Category: \(category)")
                    .padding()
                Text(categoryDescription)
                    .padding()

                VStack {
                    if let url1 = URL(string: imageUrl1) {
                        AsyncImage(url: url1) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                    }
                    if let imageUrl2 = imageUrl2, let url2 = URL(string: imageUrl2) {
                                            AsyncImage(url: url2) { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: .infinity)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .padding()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Results")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
