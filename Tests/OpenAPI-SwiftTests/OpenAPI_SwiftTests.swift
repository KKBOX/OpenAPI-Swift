import XCTest
@testable import OpenAPI_Swift

class OpenAPI_SwiftTests: XCTestCase {
	var API: KKBOXOpenAPI!

	override func setUp() {
		super.setUp()
		self.API = KKBOXOpenAPI(clientID: "5fd35360d795498b6ac424fc9cb38fe7", secret: "8bb68d0d1c2b483794ee1a978c9d0b5d")
	}

	func testFetchWithInvalidCredential() {
		self.API = KKBOXOpenAPI(clientID: "121321223123123", secret: "1231231321213")
		let exp = self.expectation(description: "testFetchWithInvalidCredential")
		_ = try? self.API.fetchAccessTokenByClientCredential {result in
			exp.fulfill()
			switch  result {
			case .error(let error):
				XCTAssertTrue(error.localizedDescription == "invalid_client", "\(error.localizedDescription)")
			case .success(_):
				XCTFail("It is not possible.")
				break
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

    func testFetchCredential() {
		let exp = self.expectation(description: "testFetchCredential")
		_ = try? self.API.fetchAccessTokenByClientCredential {result in
			exp.fulfill()
			switch  result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let response):
				XCTAssertTrue(response.accessToken.count > 0)
				XCTAssertTrue(response.expiresIn > 0)
				XCTAssertTrue(response.tokenType?.count ?? 0 > 0)
				break
			}
		}
		self.wait(for: [exp], timeout: 3)
    }

    func testFetchTrack() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchTrack")
		_ = try? self.API.fetch(track: "4kxvr3wPWkaL9_y3o_") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let track):
				XCTAssertTrue(track.ID.count > 0)
				XCTAssertTrue(track.name.count > 0)
				XCTAssertNotNil(track.album)
				XCTAssertTrue(track.trackOrderInAlbum > 0)
				XCTAssertTrue(track.duration > 0)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchAlbum() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchAlbum")
		_ = try? self.API.fetch(album: "WpTPGzNLeutVFHcFq6") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let album):
				XCTAssertTrue(album.ID.count > 0)
				XCTAssertTrue(album.name.count > 0)
				XCTAssertNotNil(album.artist)
				XCTAssertTrue(album.images.count > 0)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

    static var allTests = [
        ("testFetchCredential", testFetchCredential),
    ]
}
