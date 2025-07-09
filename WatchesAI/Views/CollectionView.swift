import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.watches) { watch in
                    WatchCardView(watch: watch)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Collection")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct WatchCardView: View {
    let watch: Watch
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Image (Left)
            Group {
                if let imageURL = watch.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        Group {
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text("Loading...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            case .failure:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text("Image Failed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    )
                            @unknown default:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text("No Image")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    )
                            }
                        }
                        .accessibilityLabel("Watch Image")
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("No Image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        )
                        .accessibilityLabel("Watch Image")
                }
            }
            
            // Details (Right)
            VStack(alignment: .leading, spacing: 8) {
                Text("\(watch.brand) \(watch.model)")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("Year: \(watch.year)")
                    .font(.system(.subheadline, design: .default, weight: .regular))
                    .foregroundColor(.secondary)
                
                Text("Value: $\(watch.value, specifier: "%.2f")")
                    .font(.system(.subheadline, design: .default, weight: .regular))
                    .foregroundColor(.secondary)
                
                if let style = watch.style {
                    Text("Style: \(style)")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                if let movement = watch.movement {
                    Text("Movement: \(movement)")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                if let complications = watch.complications {
                    Text("Complications: \(complications)")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                if let material = watch.material {
                    Text("Material: \(material)")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                if let rarity = watch.rarityScore {
                    Text("Rarity: \(Int(rarity))")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                """
                Watch: \(watch.brand) \(watch.model), Year: \(watch.year), Value: $\(watch.value, specifier: "%.2f")\(watch.style.map { ", Style: \($0)" } ?? "")\(watch.movement.map { ", Movement: \($0)" } ?? "")\(watch.complications.map { ", Complications: \($0)" } ?? "")\(watch.material.map { ", Material: \($0)" } ?? "")\(watch.rarityScore.map { ", Rarity: \(Int($0))" } ?? "")
                """
            )
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
            .environmentObject(WatchViewModel())
    }
}
