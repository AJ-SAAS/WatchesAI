import SwiftUI
import PhotosUI

struct AddWatchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LogWatchViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                formView
                imagePickerView
                saveButtonView
                toastView
            }
            .navigationTitle("Add Watch")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
    
    private var formView: some View {
        Form {
            Section(header: Text("Watch Details")) {
                TextField("Brand", text: $viewModel.brand)
                    .accessibilityLabel("Brand")
                TextField("Model", text: $viewModel.model)
                    .accessibilityLabel("Model")
                TextField("Year", text: $viewModel.year)
                    .keyboardType(.numberPad)
                    .accessibilityLabel("Year")
                Picker("Movement", selection: $viewModel.movement) {
                    Text("Select").tag("")
                    ForEach(["Automatic", "Manual", "Quartz"], id: \.self) { movement in
                        Text(movement).tag(movement)
                    }
                }
                .accessibilityLabel("Movement")
                Picker("Material", selection: $viewModel.material) {
                    Text("Select").tag("")
                    ForEach(["Stainless Steel", "Gold", "Titanium", "Ceramic"], id: \.self) { material in
                        Text(material).tag(material)
                    }
                }
                .accessibilityLabel("Material")
                Picker("Style", selection: $viewModel.style) {
                    Text("Select").tag("")
                    ForEach(["Dive", "Dress", "Chronograph", "Pilot"], id: \.self) { style in
                        Text(style).tag(style)
                    }
                }
                .accessibilityLabel("Style")
                Picker("Type", selection: $viewModel.type) {
                    Text("Select").tag("Collection")
                    ForEach(["Collection", "Wishlist"], id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .accessibilityLabel("Type")
                TextField("Complications", text: $viewModel.complications)
                    .accessibilityLabel("Complications")
                TextField("Value ($)", text: $viewModel.value)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Value")
            }
        }
    }
    
    private var imagePickerView: some View {
        PhotosPicker(
            selection: $viewModel.imagePickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack {
                Image(systemName: "photo")
                Text(viewModel.image == nil ? "Select Photo" : "Change Photo")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .onChange(of: viewModel.imagePickerItem) { _ in
            viewModel.loadImage()
        }
        .accessibilityLabel("Select Watch Photo")
    }
    
    private var saveButtonView: some View {
        Button(action: {
            viewModel.saveWatch { result in
                switch result {
                case .success:
                    dismiss()
                case .failure:
                    // Toast handled in viewModel
                    break
                }
            }
        }) {
            Text(viewModel.isLoading ? "Saving..." : "Save Watch")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormValid && !viewModel.isLoading ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .padding()
        .accessibilityLabel("Save Watch")
    }
    
    private var toastView: some View {
        Group {
            if let message = viewModel.toastMessage {
                Text(message)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            viewModel.toastMessage = nil
                        }
                    }
            }
        }
        .zIndex(2)
    }
}

struct AddWatchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddWatchView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            AddWatchView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
