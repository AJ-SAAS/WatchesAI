import SwiftUI
import FirebaseAuth
import PhotosUI

struct AddWatchView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var brand = ""
    @State private var model = ""
    @State private var year = ""
    @State private var value = ""
    @State private var movement = ""
    @State private var complications = ""
    @State private var style = ""
    @State private var material = ""
    @State private var rarityScore: Double = 5
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    let movements = ["Automatic", "Manual / Hand-wound", "Quartz", "Solar", "Kinetic", "Spring Drive", "Smartwatch", "Hybrid"]
    let complicationsList = ["Chronograph", "Date", "Day-Date", "Moonphase", "GMT", "World Time", "Perpetual Calendar", "Tourbillon", "Power Reserve Indicator", "Alarm", "Skeleton Dial", "Minute Repeater"]
    let styles = ["Dress", "Casual", "Dive", "Racing", "Pilot", "Field", "Military", "Skeleton", "Luxury", "Smartwatch", "Minimalist", "Fashion"]
    let materials = ["Stainless Steel", "Titanium", "Ceramic", "Gold", "Platinum", "Carbon Fiber", "Bronze", "PVD-coated", "Sapphire Crystal", "Leather", "Rubber", "NATO", "Mesh"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Add Photo
                    VStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(width: 120, height: 120)
                                .overlay(Text("Add Photo").font(.caption))
                        }
                        
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Text("Select Image")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .onChange(of: photoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                    
                    // MARK: - Required Info
                    Group {
                        TextField("Brand", text: $brand)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Model", text: $model)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Year", text: $year)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Value ($)", text: $value)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                    
                    // MARK: - Optional Pickers
                    Group {
                        LabeledContent("🕰️ Movement") {
                            Picker("", selection: $movement) {
                                Text("Select Movement").tag("")
                                ForEach(movements, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        LabeledContent("⚙️ Complications") {
                            Picker("", selection: $complications) {
                                Text("Select Complications").tag("")
                                ForEach(complicationsList, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        LabeledContent("🎨 Style") {
                            Picker("", selection: $style) {
                                Text("Select Style").tag("")
                                ForEach(styles, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        LabeledContent("🧱 Material") {
                            Picker("", selection: $material) {
                                Text("Select Material").tag("")
                                ForEach(materials, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("🧬 Rarity Score: \(Int(rarityScore))")
                            Slider(value: $rarityScore, in: 1...10, step: 1)
                        }
                        .padding(.top, 8)
                    }
                    
                    // MARK: - Save Button
                    Button(action: saveWatch) {
                        Text("Save Watch")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brand.isEmpty || model.isEmpty || year.isEmpty || value.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(brand.isEmpty || model.isEmpty || year.isEmpty || value.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Add Watch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveWatch() {
        guard let yearInt = Int(year) else {
            errorMessage = "Please enter a valid year."
            showErrorAlert = true
            return
        }
        guard let valueDouble = Double(value) else {
            errorMessage = "Please enter a valid value."
            showErrorAlert = true
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated. Please try again."
            showErrorAlert = true
            return
        }
        
        var newWatch = Watch(
            id: UUID().uuidString,
            brand: brand,
            model: model,
            year: yearInt,
            value: valueDouble,
            imageURL: nil,
            movement: movement.isEmpty ? nil : movement,
            complications: complications.isEmpty ? nil : complications,
            style: style.isEmpty ? nil : style,
            material: material.isEmpty ? nil : material,
            rarityScore: rarityScore
        )
        
        viewModel.addWatch(newWatch, image: selectedImage, forUser: uid)
        dismiss()
    }
}

struct AddWatchView_Previews: PreviewProvider {
    static var previews: some View {
        AddWatchView()
            .environmentObject(WatchViewModel())
    }
}
