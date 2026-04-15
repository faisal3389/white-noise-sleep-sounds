import SwiftUI

struct MixCardView: View {
    let mix: SoundMix
    let isActive: Bool
    let onPlay: () -> Void
    let onEdit: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image area with 2-column grid
            ZStack(alignment: .topTrailing) {
                imageGrid
                    .aspectRatio(16/9, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isHovered ? Color.black.opacity(0.4) : .clear)
                    )
                    .overlay {
                        if isHovered {
                            Button(action: onPlay) {
                                Circle()
                                    .fill(Color.appAccent.opacity(0.9))
                                    .frame(width: 56, height: 56)
                                    .overlay {
                                        Image(systemName: "play.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.onPrimary)
                                    }
                            }
                        }
                    }

                // Edit button
                Button(action: onEdit) {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                }
                .padding(8)
            }
            .onTapGesture {
                onPlay()
            }
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = pressing
                }
            }, perform: {})

            // Text content
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(mix.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.onSurface)
                        .lineLimit(1)

                    Text(mix.componentNames)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.onSurfaceVariant)
                        .lineLimit(1)
                }

                Spacer()

                if isActive {
                    Text("ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Color.appAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appAccent.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var imageGrid: some View {
        GeometryReader { geo in
            let images = mix.components.prefix(4).compactMap { $0.sound?.backgroundImage }
            let columns = min(images.count, 2)
            let rows = images.count > 2 ? 2 : 1

            if images.isEmpty {
                Rectangle()
                    .fill(Color.surfaceContainerHigh)
            } else if images.count == 1 {
                Image(images[0])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            } else {
                let spacing: CGFloat = 2
                let cellW = (geo.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
                let cellH = (geo.size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)

                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { col in
                                let idx = row * columns + col
                                if idx < images.count {
                                    Image(images[idx])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: cellW, height: cellH)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.surfaceContainerHigh)
                                        .frame(width: cellW, height: cellH)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
