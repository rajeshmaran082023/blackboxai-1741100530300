import Foundation
import SwiftSoup

class WebScraperService {
    static let shared = WebScraperService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchWords() async throws -> [Word] {
        // Fetch words from both sources
        async let verbformenWords = fetchFromVerbformen()
        async let leoWords = fetchFromLeo()
        
        // Combine and deduplicate results
        let words = try await verbformenWords + leoWords
        return Array(Set(words))
    }
    
    // MARK: - Private Methods
    
    private func fetchFromVerbformen() async throws -> [Word] {
        var words: [Word] = []
        
        // Base URL for verbformen.com
        let baseUrl = "https://www.verbformen.com/declension/nouns/"
        
        // Fetch the main page
        let html = try await fetchHtml(from: baseUrl)
        let doc = try SwiftSoup.parse(html)
        
        // Extract word links
        let wordLinks = try doc.select("a[href*=/declension/nouns/]")
        
        // Process each word (limit to avoid overwhelming the server)
        for link in wordLinks.prefix(50) {
            let wordUrl = try link.attr("href")
            if let word = try? await parseVerbformenWord(url: wordUrl) {
                words.append(word)
            }
        }
        
        return words
    }
    
    private func parseVerbformenWord(url: String) async throws -> Word? {
        let html = try await fetchHtml(from: url)
        let doc = try SwiftSoup.parse(html)
        
        // Extract German word and article
        guard let titleElement = try doc.select("h1").first(),
              let titleText = try? titleElement.text(),
              let (article, germanWord) = extractArticleAndWord(from: titleText) else {
            return nil
        }
        
        // Extract English translation
        guard let translationElement = try doc.select(".translation").first(),
              let englishMeaning = try? translationElement.text() else {
            return nil
        }
        
        // Determine difficulty based on word frequency
        let difficulty = determineDifficulty(from: doc)
        
        return Word(
            germanWord: germanWord,
            article: article,
            englishMeaning: englishMeaning,
            difficulty: difficulty
        )
    }
    
    private func fetchFromLeo() async throws -> [Word] {
        var words: [Word] = []
        
        // Base URL for leo.org
        let baseUrl = "https://dict.leo.org/german-english/"
        
        // Fetch common words page
        let html = try await fetchHtml(from: baseUrl)
        let doc = try SwiftSoup.parse(html)
        
        // Extract word entries
        let entries = try doc.select(".section-entry")
        
        // Process each entry
        for entry in entries.prefix(50) {
            if let word = try? await parseLeoWord(entry: entry) {
                words.append(word)
            }
        }
        
        return words
    }
    
    private func parseLeoWord(entry: Element) async throws -> Word? {
        // Extract German word and article
        guard let germanElement = try entry.select(".german-term").first(),
              let germanText = try? germanElement.text(),
              let (article, germanWord) = extractArticleAndWord(from: germanText) else {
            return nil
        }
        
        // Extract English translation
        guard let englishElement = try entry.select(".english-term").first(),
              let englishMeaning = try? englishElement.text() else {
            return nil
        }
        
        // Determine difficulty based on word frequency or usage indicators
        let difficulty = determineDifficulty(from: entry)
        
        return Word(
            germanWord: germanWord,
            article: article,
            englishMeaning: englishMeaning,
            difficulty: difficulty
        )
    }
    
    // MARK: - Helper Methods
    
    private func fetchHtml(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw ScraperError.invalidUrl
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScraperError.invalidData
        }
        
        return html
    }
    
    private func extractArticleAndWord(from text: String) -> (Article, String)? {
        let components = text.split(separator: " ")
        guard components.count >= 2 else { return nil }
        
        let articleText = components[0].lowercased()
        guard let article = Article(rawValue: articleText) else { return nil }
        
        let word = components[1...].joined(separator: " ")
        return (article, word)
    }
    
    private func determineDifficulty(from element: Element) -> DifficultyLevel {
        // This is a simplified implementation
        // In a real app, you would use more sophisticated criteria
        do {
            let frequencyClass = try element.attr("data-frequency-class")
            switch frequencyClass {
            case "1", "2", "3":
                return .beginner
            case "4", "5", "6":
                return .intermediate
            default:
                return .advanced
            }
        } catch {
            // Default to intermediate if frequency information is not available
            return .intermediate
        }
    }
    
    private func determineDifficulty(from doc: Document) -> DifficultyLevel {
        // This is a simplified implementation
        // In a real app, you would use more sophisticated criteria
        do {
            let frequencyElement = try doc.select(".frequency-indicator").first()
            let frequencyText = try frequencyElement?.text() ?? ""
            
            if frequencyText.contains("Common") {
                return .beginner
            } else if frequencyText.contains("Regular") {
                return .intermediate
            } else {
                return .advanced
            }
        } catch {
            // Default to intermediate if frequency information is not available
            return .intermediate
        }
    }
}

enum ScraperError: Error {
    case invalidUrl
    case invalidData
    case parsingError
}
