import XCTest
@testable import MojiOri

final class TextTextureGeneratorTests: XCTestCase {
    func testGenerateTexture() {
        let generator = TextTextureGenerator()
        let result = generator.generateTexture(
            text: "Test",
            font: .systemFont(ofSize: 16),
            textColor: .white,
            backgroundColor: .black,
            canvasSize: CGSize(width: 100, height: 100)
        )
        XCTAssertNotNil(result)
    }

    func testEmptyTextReturnsNil() {
        let generator = TextTextureGenerator()
        let result = generator.generateTexture(
            text: "",
            font: .systemFont(ofSize: 16),
            textColor: .white,
            backgroundColor: .black,
            canvasSize: CGSize(width: 100, height: 100)
        )
        XCTAssertNil(result)
    }
}
