# German Article Quiz

A macOS application for learning German articles through an interactive quiz game. Practice your German article knowledge with two quiz modes and track your progress with a learned words list.

## Features

- Two Quiz Modes:
  - English to German: Translate English words and select the correct German article
  - German to English: Translate German words with their articles to English
- Extensive Word Database:
  - 10,000+ German words with articles and English translations
  - Words categorized by difficulty level (beginner, intermediate, advanced)
- Progress Tracking:
  - Track learned words
  - Filter and search through your learned vocabulary
- Modern macOS Interface:
  - Clean, native SwiftUI design
  - Smooth animations and transitions
  - Dark mode support

## Requirements

- macOS 12.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/GermanArticleQuiz.git
cd GermanArticleQuiz
```

2. Install dependencies using Swift Package Manager:
```bash
swift package resolve
```

3. Open the project in Xcode:
```bash
xed .
```

4. Build and run the application (⌘R)

## Usage

1. Launch the application
2. Choose your preferred quiz mode using the toggle at the top
3. For English to German mode:
   - Read the English word
   - Select the correct German article (der, die, das) and word combination
4. For German to English mode:
   - Read the German word with its article
   - Type in the English translation
5. View your learned words by clicking the "Learned Words" tab
   - Search through your learned vocabulary
   - Filter words by difficulty level

## Technical Details

- Built with SwiftUI for modern macOS UI
- Uses SQLite for local word storage
- Implements web scraping for word database population
- Follows MVVM architecture pattern

## Dependencies

- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) - SQLite database management
- [SwiftSoup](https://github.com/scinfu/SwiftSoup) - HTML parsing for web scraping

## Project Structure

```
GermanArticleQuiz/
├── App/
│   └── GermanArticleQuizApp.swift
├── Models/
│   └── Word.swift
├── Views/
│   ├── ContentView.swift
│   ├── QuizView.swift
│   └── LearnedWordsView.swift
├── ViewModels/
│   └── QuizViewModel.swift
├── Services/
│   ├── DatabaseService.swift
│   └── WebScraperService.swift
└── Utils/
    └── Constants.swift
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Word data sourced from:
  - [verbformen.com](https://www.verbformen.com/)
  - [leo.org](https://www.leo.org/german-english/)
