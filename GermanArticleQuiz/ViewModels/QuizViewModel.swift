import Foundation
import Combine

class QuizViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var currentWord: Word?
    @Published var quizMode: QuizMode = .englishToGerman
    @Published var isShowingAnswer = false
    @Published var score = 0
    @Published var totalQuestions = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var learnedWords: [Word] = []
    
    // Private properties
    private var words: [Word] = []
    private var currentIndex = 0
    private var cancellables = Set<AnyCancellable>()
    
    // Timer for showing correct answer
    private var answerTimer: Timer?
    
    init() {
        Task {
            await loadWords()
        }
    }
    
    // MARK: - Public Methods
    
    func toggleQuizMode() {
        quizMode = quizMode == .englishToGerman ? .germanToEnglish : .englishToGerman
        loadNextWord()
    }
    
    func checkAnswer(selectedArticle: Article) {
        guard let currentWord = currentWord else { return }
        
        let isCorrect = selectedArticle == currentWord.article
        if isCorrect {
            score += 1
            markWordAsLearned(currentWord)
        }
        
        showCorrectAnswer {
            self.loadNextWord()
        }
    }
    
    func checkAnswer(englishMeaning: String) {
        guard let currentWord = currentWord else { return }
        
        let isCorrect = englishMeaning.lowercased() == currentWord.englishMeaning.lowercased()
        if isCorrect {
            score += 1
            markWordAsLearned(currentWord)
        }
        
        showCorrectAnswer {
            self.loadNextWord()
        }
    }
    
    func resetQuiz() {
        score = 0
        totalQuestions = 0
        currentIndex = 0
        shuffleWords()
        loadNextWord()
    }
    
    // MARK: - Private Methods
    
    private func loadWords() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // First try to load from database
            words = try DatabaseService.shared.getAllWords()
            
            // If database is empty, fetch from web
            if words.isEmpty {
                words = try await WebScraperService.shared.fetchWords()
                try DatabaseService.shared.saveWords(words)
            }
            
            // Load learned words
            learnedWords = try DatabaseService.shared.getLearnedWords()
            
            await MainActor.run {
                shuffleWords()
                loadNextWord()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load words: \(error.localizedDescription)"
                // Load sample data as fallback
                words = [
                    Word(germanWord: "Katze", article: .die, englishMeaning: "cat", difficulty: .beginner),
                    Word(germanWord: "Hund", article: .der, englishMeaning: "dog", difficulty: .beginner),
                    Word(germanWord: "Haus", article: .das, englishMeaning: "house", difficulty: .beginner)
                ]
                shuffleWords()
                loadNextWord()
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func shuffleWords() {
        words.shuffle()
    }
    
    private func loadNextWord() {
        if currentIndex >= words.count {
            currentIndex = 0
            shuffleWords()
        }
        
        currentWord = words[currentIndex]
        currentIndex += 1
        totalQuestions += 1
    }
    
    private func showCorrectAnswer(completion: @escaping () -> Void) {
        isShowingAnswer = true
        
        // Cancel any existing timer
        answerTimer?.invalidate()
        
        // Show correct answer for 1.5 seconds
        answerTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.isShowingAnswer = false
            completion()
        }
    }
    
    private func markWordAsLearned(_ word: Word) {
        if let index = words.firstIndex(where: { $0.id == word.id }) {
            words[index].learned = true
            
            // Update learned words list
            if !learnedWords.contains(where: { $0.id == word.id }) {
                learnedWords.append(words[index])
            }
            
            // Update database
            Task {
                do {
                    try await DatabaseService.shared.updateWordLearnedStatus(id: word.id, learned: true)
                } catch {
                    print("Failed to update word status: \(error)")
                }
            }
        }
    }
    
    deinit {
        answerTimer?.invalidate()
    }
}
