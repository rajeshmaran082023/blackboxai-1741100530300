import SwiftUI

@main
struct GermanArticleQuizApp: App {
    // Initialize app-wide state
    @StateObject private var quizViewModel = QuizViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizViewModel)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // Add menu commands here
            CommandGroup(replacing: .newItem) { }
        }
    }
}
