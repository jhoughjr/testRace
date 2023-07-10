@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }

      func testGetExistingTodo() async throws {
        let app = Application(.testing)
        do {
            defer { app.shutdown() }
            try await configure(app)
            try await app.autoMigrate()
            
            let todo = Todo(title: UUID().uuidString)
            try await todo.create(on: app.db)
            
            try app.test(.GET, "todos") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertContent(Array<Todo>.self, res) { content in
                    XCTAssert(content.contains { $0.id == todo.id! })
                }
            }
        } catch {
            app.logger.report(error: error)
            throw error
        }
    }
}
