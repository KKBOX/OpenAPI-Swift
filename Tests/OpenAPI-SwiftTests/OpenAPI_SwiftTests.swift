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

	func validate(track: KKTrackInfo) {
		XCTAssertNotNil(track)
		XCTAssertTrue(track.ID.count > 0)
		XCTAssertTrue(track.name.count > 0)
		XCTAssertTrue(track.duration > 0)
		XCTAssertNotNil(track.url)
		XCTAssertTrue(track.trackOrderInAlbum > 0)
//		XCTAssertTrue(track.territoriesThatAvailanbleAt.count > 0)
//		XCTAssertTrue(track.territoriesThatAvailanbleAt.contains(KKTerritoryCode.taiwan.rawValue as NSNumber))
		if let album = track.album {
			self.validate(album: album)
		}
	}

	func validate(album: KKAlbumInfo) {
		XCTAssertNotNil(album)
		XCTAssertTrue(album.ID.count > 0)
		XCTAssertTrue(album.name.count > 0)
		XCTAssertNotNil(album.url)
		XCTAssertTrue(album.images.count == 3)
		//		XCTAssertTrue(album.releaseDate.count > 0)
		//		XCTAssertTrue(album.territoriesThatAvailanbleAt.count > 0, "\(album.albumName)")
		//		XCTAssertTrue(album.territoriesThatAvailanbleAt.contains(KKTerritoryCode.taiwan.rawValue as NSNumber))
		self.validate(artist: album.artist!)
	}

	func validate(artist: KKArtistInfo) {
		XCTAssertNotNil(artist)
		XCTAssertTrue(artist.ID.count > 0)
		XCTAssertTrue(artist.name.count > 0)
		XCTAssertNotNil(artist.url)
		XCTAssertTrue(artist.images.count == 2)
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
				self.validate(track: track)
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
				self.validate(album: album)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchTracksInAlbum() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchTracksInAlbum")
		_ = try? self.API.fetch(tracksInAlbum: "WpTPGzNLeutVFHcFq6") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let tracks):
				XCTAssertNotNil(tracks.tracks)
				XCTAssertTrue(tracks.tracks.count > 0)
				for track in tracks.tracks {
					self.validate(track: track)
				}
				XCTAssertNotNil(tracks.paging)
				XCTAssertNotNil(tracks.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchArtist() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchArtist")
		_ = try? self.API.fetch(artist: "8q3_xzjl89Yakn_7GB") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let artist):
				self.validate(artist: artist)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchAlbumsOfArtist() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchAlbumsOfArtist")
		_ = try? self.API.fetch(albumsBelongToArtist: "8q3_xzjl89Yakn_7GB") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let albums):
				XCTAssertNotNil(albums.albums)
				XCTAssertTrue(albums.albums.count > 0)
				for album in albums.albums {
					self.validate(album: album)
				}
				XCTAssertNotNil(albums.paging)
				XCTAssertNotNil(albums.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchTopTracksOfArtist() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchTopTracksOfArtist")
		_ = try? self.API.fetch(topTracksOfArtist: "8q3_xzjl89Yakn_7GB") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let tracks):
				XCTAssertNotNil(tracks.tracks)
				XCTAssertTrue(tracks.tracks.count > 0)
				for track in tracks.tracks {
					self.validate(track: track)
				}
				XCTAssertNotNil(tracks.paging)
				XCTAssertNotNil(tracks.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

    static var allTests = [
        ("testFetchCredential", testFetchCredential),
    ]
}
