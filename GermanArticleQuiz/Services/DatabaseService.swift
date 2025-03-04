import Foundation
import SQLite

class DatabaseService {
    static let shared = DatabaseService()
    
    private var db: Connection?
    
    // Tables
    private let words = Table("words")
    
    // Columns
    private let id = Expression<String>("id")
    private let germanWord = Expression<String>("german_word")
    private let article = Expression<String>("article")
    private let englishMeaning = Expression<String>("english_meaning")
    private let difficulty = Expression<String>("difficulty")
    private let learned = Expression<Bool>("learned")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .applicationSupportDirectory, .userDomainMask, true
            ).first!
            
            // Create app directory if it doesn't exist
            try FileManager.default.createDirectory(
                atPath: path,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            let dbPath = "\(path)/german_quiz.sqlite3"
            db = try Connection(dbPath)
            
            try createTables()
        } catch {
            print("Database setup failed: \(error)")
        }
    }
    
    private func createTables() throws {
        try db?.run(words.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(germanWord)
            table.column(article)
            table.column(englishMeaning)
            table.column(difficulty)
            table.column(learned)
        })
    }
    
    // MARK: - Public Methods
    
    func saveWords(_ words: [Word]) throws {
        guard let db = db else { throw DatabaseError.notConnected }
        
        try db.transaction {
            for word in words {
                let insert = self.words.insert(
                    self.id <- word.id.uuidString,
                    self.germanWord <- word.germanWord,
                    self.article <- word.article.rawValue,
                    self.englishMeaning <- word.englishMeaning,
                    self.difficulty <- word.difficulty.rawValue,
                    self.learned <- word.learned
                )
                try db.run(insert)
            }
        }
    }
    
    func getAllWords() throws -> [Word] {
        guard let db = db else { throw DatabaseError.notConnected }
        
        var result: [Word] = []
        
        for row in try db.prepare(words) {
            if let article = Article(rawValue: row[self.article]),
               let difficulty = DifficultyLevel(rawValue: row[self.difficulty]) {
                let word = Word(
                    id: UUID(uuidString: row[id])!,
                    germanWord: row[germanWord],
                    article: article,
                    englishMeaning: row[englishMeaning],
                    difficulty: difficulty,
                    learned: row[learned]
                )
                result.append(word)
            }
        }
        
        return result
    }
    
    func updateWordLearnedStatus(id: UUID, learned: Bool) throws {
        guard let db = db else { throw DatabaseError.notConnected }
        
        let word = words.filter(self.id == id.uuidString)
        try db.run(word.update(self.learned <- learned))
    }
    
    func getLearnedWords() throws -> [Word] {
        guard let db = db else { throw DatabaseError.notConnected }
        
        var result: [Word] = []
        let query = words.filter(learned == true)
        
        for row in try db.prepare(query) {
            if let article = Article(rawValue: row[self.article]),
               let difficulty = DifficultyLevel(rawValue: row[self.difficulty]) {
                let word = Word(
                    id: UUID(uuidString: row[id])!,
                    germanWord: row[germanWord],
                    article: article,
                    englishMeaning: row[englishMeaning],
                    difficulty: difficulty,
                    learned: row[learned]
                )
                result.append(word)
            }
        }
        
        return result
    }
    
    func clearDatabase() throws {
        guard let db = db else { throw DatabaseError.notConnected }
        try db.run(words.delete())
    }
}

enum DatabaseError: Error {
    case notConnected
    case insertFailed
    case fetchFailed
    case updateFailed
}
