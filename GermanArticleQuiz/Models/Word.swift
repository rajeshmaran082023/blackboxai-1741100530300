import Foundation

struct Word: Identifiable, Codable, Hashable {
    let id: UUID
    let germanWord: String
    let article: Article
    let englishMeaning: String
    let difficulty: DifficultyLevel
    var learned: Bool
    
    init(id: UUID = UUID(), germanWord: String, article: Article, englishMeaning: String, difficulty: DifficultyLevel, learned: Bool = false) {
        self.id = id
        self.germanWord = germanWord
        self.article = article
        self.englishMeaning = englishMeaning
        self.difficulty = difficulty
        self.learned = learned
    }
}

enum Article: String, Codable, CaseIterable {
    case der
    case die
    case das
    
    var color: String {
        switch self {
        case .der:
            return "#4A90E2" // Blue
        case .die:
            return "#E24A4A" // Red
        case .das:
            return "#50E24A" // Green
        }
    }
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    
    var description: String {
        rawValue.capitalized
    }
    
    var sortOrder: Int {
        switch self {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        }
    }
}

enum QuizMode: String, CaseIterable {
    case englishToGerman = "English → German"
    case germanToEnglish = "German → English"
}
