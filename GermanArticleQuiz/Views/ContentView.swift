import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var quizViewModel: QuizViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }
                .tag(0)
            
            LearnedWordsView()
                .tabItem {
                    Label("Learned Words", systemImage: "book.fill")
                }
                .tag(1)
        }
        .frame(minWidth: 600, minHeight: 400)
        .overlay(loadingOverlay)
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if quizViewModel.isLoading {
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(QuizViewModel())
    }
}

// MARK: - Supporting Views
struct QuizView: View {
    @EnvironmentObject private var quizViewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Quiz Mode Toggle
            Picker("Quiz Mode", selection: $quizViewModel.quizMode) {
                ForEach(QuizMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Score Display
            HStack {
                Text("Score: \(quizViewModel.score)")
                    .font(.headline)
                Text("Total Questions: \(quizViewModel.totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Question Area
            if let currentWord = quizViewModel.currentWord {
                Group {
                    if quizViewModel.quizMode == .englishToGerman {
                        EnglishToGermanQuiz(word: currentWord)
                    } else {
                        GermanToEnglishQuiz(word: currentWord)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.windowBackgroundColor))
                    .shadow(radius: 5))
            }
            
            Spacer()
            
            // Reset Button
            Button(action: quizViewModel.resetQuiz) {
                Text("Reset Quiz")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .padding()
        }
        .padding()
    }
}

struct EnglishToGermanQuiz: View {
    let word: Word
    @EnvironmentObject private var quizViewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Question
            Text("What's the German word for:")
                .font(.headline)
            
            Text(word.englishMeaning)
                .font(.title)
                .bold()
            
            // Answer Options
            HStack(spacing: 20) {
                ForEach(Article.allCases, id: \.self) { article in
                    ArticleButton(
                        article: article,
                        germanWord: word.germanWord,
                        isCorrect: quizViewModel.isShowingAnswer ? (article == word.article) : nil,
                        action: { quizViewModel.checkAnswer(selectedArticle: article) }
                    )
                }
            }
        }
    }
}

struct GermanToEnglishQuiz: View {
    let word: Word
    @EnvironmentObject private var quizViewModel: QuizViewModel
    @State private var userAnswer = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Question
            Text("What's the English word for:")
                .font(.headline)
            
            Text("\(word.article.rawValue) \(word.germanWord)")
                .font(.title)
                .bold()
            
            // Answer Input
            TextField("Type the English translation", text: $userAnswer)
                .textFieldStyle(.roundedBorder)
                .disabled(quizViewModel.isShowingAnswer)
            
            // Submit Button
            Button("Submit") {
                quizViewModel.checkAnswer(englishMeaning: userAnswer)
                userAnswer = ""
            }
            .disabled(userAnswer.isEmpty || quizViewModel.isShowingAnswer)
            
            // Show correct answer when needed
            if quizViewModel.isShowingAnswer {
                Text("Correct answer: \(word.englishMeaning)")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
    }
}

struct ArticleButton: View {
    let article: Article
    let germanWord: String
    let isCorrect: Bool?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(article.rawValue)
                    .font(.headline)
                Text(germanWord)
                    .font(.body)
            }
            .frame(width: 120, height: 80)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isCorrect != nil)
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return Color(hex: article.color)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
