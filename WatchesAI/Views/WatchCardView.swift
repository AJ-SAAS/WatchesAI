// Views/WatchCardView.swift
import SwiftUI

struct WatchCardView: View {
    let card: Watch
    let onSwipe: ((SwipeDirection) -> Void)?
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                VStack(spacing: 8) {
                    watchImageView(geometry: geometry)
                    VStack(alignment: .center, spacing: 8) {
                        Text("\(card.brand) \(card.model)")
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text("Year: \(card.year)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Value: $\(card.value, specifier: "%.2f")")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Type: \(card.type)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Complications: \(card.complications)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Style: \(card.style)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Movement: \(card.movement)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Material: \(card.material)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding()
            }
            .frame(maxWidth: geometry.size.width > 600 ? 400 : 320, maxHeight: geometry.size.width > 600 ? 400 : 450)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                        rotation = Double(value.translation.width / 25)
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > 150 {
                            let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
                            withAnimation(.spring()) {
                                offset = CGSize(width: value.translation.width > 0 ? 1000 : -1000, height: 0)
                                rotation = value.translation.width > 0 ? 30 : -30
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.onSwipe?(direction)
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                                rotation = 0
                            }
                        }
                    }
            )
            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                """
                Watch: \(card.brand) \(card.model), Year: \(card.year), Value: $\(card.value, specifier: "%.2f"), Type: \(card.type), Complications: \(card.complications), Style: \(card.style), Movement: \(card.movement), Material: \(card.material)
                """
            )
        }
    }
    
    private func watchImageView(geometry: GeometryProxy) -> some View {
        Group {
            if let imageURL = card.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: imageWidth(geometry: geometry), height: imageHeight(geometry: geometry))
                            .overlay(Text("Loading...").font(.caption))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageWidth(geometry: geometry), height: imageHeight(geometry: geometry))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: imageWidth(geometry: geometry), height: imageHeight(geometry: geometry))
                            .overlay(Text("Image Failed").font(.caption))
                    @unknown default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: imageWidth(geometry: geometry), height: imageHeight(geometry: geometry))
                            .overlay(Text("No Image").font(.caption))
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: imageWidth(geometry: geometry), height: imageHeight(geometry: geometry))
                    .overlay(Text("No Image").font(.caption))
            }
        }
        .accessibilityLabel("Watch Image")
    }
    
    private func imageWidth(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width > 600 ? 200 : 280
    }
    
    private func imageHeight(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width > 600 ? 200 : 280
    }
}

struct WatchCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WatchCardView(
                card: Watch(
                    id: UUID().uuidString,
                    brand: "Rolex",
                    model: "Submariner",
                    year: "2023",
                    movement: "Automatic",
                    material: "Stainless Steel",
                    style: "Dive",
                    value: 15000,
                    type: "Collection",
                    complications: "Date",
                    imageURL: "https://example.com/rolex.jpg"
                ),
                onSwipe: { _ in }
            )
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
            WatchCardView(
                card: Watch(
                    id: UUID().uuidString,
                    brand: "Rolex",
                    model: "Submariner",
                    year: "2023",
                    movement: "Automatic",
                    material: "Stainless Steel",
                    style: "Dive",
                    value: 15000,
                    type: "Collection",
                    complications: "Date",
                    imageURL: "https://example.com/rolex.jpg"
                ),
                onSwipe: { _ in }
            )
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewDisplayName("iPad Pro")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
