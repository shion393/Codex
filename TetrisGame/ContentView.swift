import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    private let boardSpacing: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(
                (geometry.size.width - 32) / CGFloat(gameState.columns + 6),
                (geometry.size.height - 32) / CGFloat(gameState.rows + 4)
            )

            VStack(spacing: 16) {
                header
                HStack(alignment: .top, spacing: 16) {
                    boardView(cellSize: cellSize)
                    sidePanel(cellSize: cellSize)
                }
                controlPanel
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Score \(gameState.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Level \(gameState.level)")
                    .font(.headline)
                Text("Lines \(gameState.linesCleared)")
                    .font(.headline)
            }
            Spacer()
            VStack(spacing: 8) {
                Button(gameState.isPaused ? "Resume" : "Pause") {
                    gameState.togglePause()
                }
                .buttonStyle(.borderedProminent)
                Button("Restart") {
                    gameState.resetGame()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func boardView(cellSize: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
            VStack(spacing: boardSpacing) {
                ForEach(0..<gameState.rows, id: \.self) { row in
                    HStack(spacing: boardSpacing) {
                        ForEach(0..<gameState.columns, id: \.self) { column in
                            cellView(for: row, column: column)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .padding(8)

            if gameState.isGameOver {
                VStack(spacing: 12) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Button("Play Again") {
                        gameState.resetGame()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func sidePanel(cellSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Next")
                    .font(.headline)
                nextPiecePreview(cellSize: cellSize * 0.75)
            }
            Spacer()
        }
        .frame(width: cellSize * 5)
    }

    private func nextPiecePreview(cellSize: CGFloat) -> some View {
        let previewGrid = Array(repeating: GridItem(.fixed(cellSize), spacing: 4), count: 4)
        return LazyVGrid(columns: previewGrid, spacing: 4) {
            ForEach(0..<4, id: \.self) { row in
                ForEach(0..<4, id: \.self) { column in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(gameState.nextPieceColor(row: row, column: column))
                        .frame(width: cellSize, height: cellSize)
                }
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private var controlPanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button {
                    gameState.moveLeft()
                } label: {
                    Image(systemName: "arrow.left")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)

                Button {
                    gameState.softDrop()
                } label: {
                    Image(systemName: "arrow.down")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    gameState.moveRight()
                } label: {
                    Image(systemName: "arrow.right")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 16) {
                Button("Rotate") {
                    gameState.rotate()
                }
                .buttonStyle(.bordered)

                Button("Hard Drop") {
                    gameState.hardDrop()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func cellView(for row: Int, column: Int) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(gameState.colorForCell(row: row, column: column))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
