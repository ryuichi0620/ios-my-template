import Foundation

struct ArticleContent: Sendable {
    let url: URL
    let title: String
    let bodyText: String
    let domain: String

    init(url: URL, title: String, bodyText: String) {
        self.url = url
        self.title = title
        self.bodyText = bodyText
        self.domain = url.host() ?? ""
    }
}
