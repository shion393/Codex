import SwiftUI

final class GameState: ObservableObject {
    let rows = 20
    let columns = 10

    @Published private(set) var board: [[TetrominoType?]]
    @Published var currentTetromino: Tetromino
    @Published var nextTetromino: TetrominoType
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var linesCleared: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false

    private var timer: Timer?

    init() {
        let emptyRow = Array<TetrominoType?>(repeating: nil, count: columns)
        board = Array(repeating: emptyRow, count: rows)
        currentTetromino = Tetromino(type: .i, rotationIndex: 0, position: Point(row: 0, column: columns / 2 - 2))
        nextTetromino = TetrominoType.random()
        resetGame()
    }

    deinit {
        timer?.invalidate()
    }

    func resetGame() {
        timer?.invalidate()
        isGameOver = false
        isPaused = false
        score = 0
        level = 1
        linesCleared = 0

        let emptyRow = Array<TetrominoType?>(repeating: nil, count: columns)
        board = Array(repeating: emptyRow, count: rows)
        nextTetromino = TetrominoType.random()
        spawnTetromino()
        scheduleTimer()
    }

    func togglePause() {
        guard !isGameOver else { return }
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            scheduleTimer()
        }
    }

    func moveLeft() {
        guard !isPaused, !isGameOver else { return }
        let newPosition = Point(row: currentTetromino.position.row, column: currentTetromino.position.column - 1)
        if isValid(tetromino: currentTetromino, position: newPosition) {
            currentTetromino.position = newPosition
        }
    }

    func moveRight() {
        guard !isPaused, !isGameOver else { return }
        let newPosition = Point(row: currentTetromino.position.row, column: currentTetromino.position.column + 1)
        if isValid(tetromino: currentTetromino, position: newPosition) {
            currentTetromino.position = newPosition
        }
    }

    func softDrop() {
        guard !isPaused, !isGameOver else { return }
        if !moveDown() {
            lockCurrentTetromino()
        }
    }

    func hardDrop() {
        guard !isPaused, !isGameOver else { return }
        while moveDown() { }
        lockCurrentTetromino()
    }

    func rotate() {
        guard !isPaused, !isGameOver else { return }
        let rotated = currentTetromino.rotated()
        if isValid(tetromino: rotated) {
            currentTetromino = rotated
        } else {
            // Wall kick attempt: try shifting left or right by one cell.
            let leftShift = Point(row: rotated.position.row, column: rotated.position.column - 1)
            if isValid(tetromino: rotated, position: leftShift) {
                currentTetromino = Tetromino(type: rotated.type, rotationIndex: rotated.rotationIndex, position: leftShift)
                return
            }
            let rightShift = Point(row: rotated.position.row, column: rotated.position.column + 1)
            if isValid(tetromino: rotated, position: rightShift) {
                currentTetromino = Tetromino(type: rotated.type, rotationIndex: rotated.rotationIndex, position: rightShift)
            }
        }
    }

    func colorForCell(row: Int, column: Int) -> Color {
        if let fixedType = board[row][column] {
            return fixedType.color
        }

        if currentTetromino.blocks().contains(where: { $0.row == row && $0.column == column }) {
            return currentTetromino.type.color.opacity(0.9)
        }

        return Color(.tertiarySystemFill)
    }

    func nextPieceColor(row: Int, column: Int) -> Color {
        let preview = Tetromino(type: nextTetromino, rotationIndex: 0, position: Point(row: 0, column: 0))
        if preview.blocks().contains(where: { $0.row == row && $0.column == column }) {
            return nextTetromino.color
        }
        return Color(.tertiarySystemFill)
    }

    private func moveDown() -> Bool {
        let newPosition = Point(row: currentTetromino.position.row + 1, column: currentTetromino.position.column)
        if isValid(tetromino: currentTetromino, position: newPosition) {
            currentTetromino.position = newPosition
            return true
        }
        return false
    }

    private func spawnTetromino() {
        let spawnColumn = columns / 2 - 2
        currentTetromino = Tetromino(type: nextTetromino, rotationIndex: 0, position: Point(row: -1, column: spawnColumn))
        nextTetromino = TetrominoType.random()
        if !isValid(tetromino: currentTetromino) {
            isGameOver = true
            timer?.invalidate()
        }
    }

    private func lockCurrentTetromino() {
        for block in currentTetromino.blocks() {
            guard block.row >= 0 else {
                isGameOver = true
                timer?.invalidate()
                return
            }
            board[block.row][block.column] = currentTetromino.type
        }
        clearCompletedLines()
        spawnTetromino()
    }

    private func clearCompletedLines() {
        var newBoard: [[TetrominoType?]] = []
        var clearedLines = 0

        for row in board {
            if row.allSatisfy({ $0 != nil }) {
                clearedLines += 1
            } else {
                newBoard.append(row)
            }
        }

        while newBoard.count < rows {
            newBoard.insert(Array(repeating: nil, count: columns), at: 0)
        }

        board = newBoard

        guard clearedLines > 0 else { return }

        linesCleared += clearedLines
        level = 1 + linesCleared / 10

        let lineScores = [0, 40, 100, 300, 1200]
        let gained = lineScores[min(clearedLines, 4)] * level
        score += gained

        scheduleTimer()
    }

    private func isValid(tetromino: Tetromino, position: Point? = nil) -> Bool {
        let testPosition = position ?? tetromino.position
        for block in tetromino.blocks(position: testPosition) {
            if block.column < 0 || block.column >= columns {
                return false
            }
            if block.row >= rows {
                return false
            }
            if block.row >= 0 && board[block.row][block.column] != nil {
                return false
            }
        }
        return true
    }

    private func scheduleTimer() {
        timer?.invalidate()
        guard !isPaused, !isGameOver else { return }
        let interval = max(0.1, 0.8 - Double(level - 1) * 0.05)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            if !self.moveDown() {
                self.lockCurrentTetromino()
            }
        }
    }
}
