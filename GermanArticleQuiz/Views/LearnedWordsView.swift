import SwiftUI

struct LearnedWordsView: View {
    @EnvironmentObject private var quizViewModel: QuizViewModel
    @State private var searchText = ""
    @State private var selectedDifficulty: DifficultyLevel?
    
    private var filteredWords: [Word] {
        var words = quizViewModel.learnedWords
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            words = words.filter { $0.difficulty == difficulty }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            words = words.filter {
                $0.germanWord.localizedCaseInsensitiveContains(searchText) ||
                $0.englishMeaning.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by difficulty
        return words.sorted { $0.difficulty.sortOrder < $1.difficulty.sortOrder }
    }
    
    var body: some View {
        VStack {
            // Search and Filter Controls
            HStack {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search words...", text: $searchText)
                }
                .padding(8)
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                
                // Difficulty Filter
                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("All Levels").tag(Optional<DifficultyLevel>.none)
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        Text(level.description).tag(Optional(level))
                    }
                }
                .frame(width: 150)
            }
            .padding()
            
            if filteredWords.isEmpty {
                emptyStateView
            } else {
                wordsList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty ? "No learned words yet" : "No matching words found")
                .font(.headline)
            
            Text(searchText.isEmpty ? "Complete some quizzes to start building your vocabulary!" : "Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var wordsList: some View {
        List {
            ForEach(filteredWords) { word in
                WordRow(word: word)
            }
        }
        .listStyle(.inset)
    }
}

struct WordRow: View {
    let word: Word
    
    var body: some View {
        HStack {
            // Article and German Word
            HStack(spacing: 8) {
                Text(word.article.rawValue)
                    .font(.headline)
                    .foregroundColor(Color(hex: word.article.color))
                Text(word.germanWord)
                    .font(.headline)
            }
            .frame(width: 200, alignment: .leading)
            
            Divider()
            
            // English Meaning
            Text(word.englishMeaning)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Difficulty Level
            Text(word.difficulty.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct LearnedWordsView_Previews: PreviewProvider {
    static var previews: some View {
        LearnedWordsView()
            .environmentObject(QuizViewModel())
    }
}
