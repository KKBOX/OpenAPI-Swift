//
// OpenAPI_SwiftTests.swift
//
// Copyright (c) 2018 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

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
		_ = try? self.API.fetchAccessTokenByClientCredential { result in
			exp.fulfill()
			switch result {
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
		_ = try? self.API.fetchAccessTokenByClientCredential { result in
			exp.fulfill()
			switch result {
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

	//MARK: -

	func validate(track: KKTrackInfo) {
		XCTAssertNotNil(track)
		XCTAssertTrue(track.ID.count > 0)
		XCTAssertTrue(track.name.count > 0)
		XCTAssertTrue(track.duration > 0)
		XCTAssertNotNil(track.url)
		XCTAssertTrue(track.trackOrderInAlbum > 0)
		XCTAssertTrue(track.territoriesThatAvailableAt.count > 0)
		XCTAssertTrue(track.territoriesThatAvailableAt.contains(.taiwan))
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
//		XCTAssertTrue(album.releaseDate?.count ?? 0 > 0)
//		XCTAssertTrue(album.territoriesThatAvailanbleAt.count > 0, "\(album.name)")
//		XCTAssertTrue(album.territoriesThatAvailanbleAt.contains(.taiwan))
		self.validate(artist: album.artist!)
	}

	func validate(artist: KKArtistInfo) {
		XCTAssertNotNil(artist)
		XCTAssertTrue(artist.ID.count > 0)
		XCTAssertTrue(artist.name.count > 0)
		XCTAssertNotNil(artist.url)
		XCTAssertTrue(artist.images.count == 2)
	}

	func validate(playlist: KKPlaylistInfo) {
		XCTAssertNotNil(playlist);
		XCTAssertTrue(playlist.ID.count > 0);
		XCTAssertTrue(playlist.title.count > 0);
		XCTAssertNotNil(playlist.url);
	}

	func validate(user: KKUserInfo) {
		XCTAssertTrue(user.ID.count > 0)
		XCTAssertTrue(user.name.count > 0)
		XCTAssertNotNil(user.url)
		XCTAssertNotNil(user.userDescription)
		XCTAssertTrue(user.images.count > 0)
	}

	//MARK: -

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

	func testFetchRelatedArtists() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchRelatedArtists")
		_ = try? self.API.fetch(relatedArtistsOfArtist: "8q3_xzjl89Yakn_7GB") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let artists):
				XCTAssertNotNil(artists.artists)
				XCTAssertTrue(artists.artists.count > 0)
				for artist in artists.artists {
					self.validate(artist: artist)
				}
				XCTAssertNotNil(artists.paging)
				XCTAssertNotNil(artists.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchPlaylist() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchPlaylist")
		_ = try? self.API.fetch(playlist: "OsyceCHOw-NvK5j6Vo") {
			result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let playlist):
				self.validate(playlist: playlist)
				XCTAssertTrue(playlist.tracks?.tracks.count ?? 0 > 0)
				if let tracks = playlist.tracks?.tracks {
					for track in tracks {
						self.validate(track: track)
					}
				}
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchTracksInPlaylist() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchTracksInPlaylist")
		_ = try? self.API.fetch(tracksInPlaylist: "OsyceCHOw-NvK5j6Vo") { result in
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

	func testFetchFeaturedPlaylists() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchFeaturedPlaylists")
		_ = try? self.API.fetchFeaturedPlaylists { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let playlists):
				XCTAssertNotNil(playlists.playlists)
				for playlist in playlists.playlists {
					self.validate(playlist: playlist)
				}
				XCTAssertNotNil(playlists.paging)
				XCTAssertNotNil(playlists.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchNewHitsPlaylists() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchNewHitsPlaylists")
		_ = try? self.API.fetchNewHitsPlaylists { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let playlists):
				XCTAssertNotNil(playlists.playlists)
				for playlist in playlists.playlists {
					self.validate(playlist: playlist)
				}
				XCTAssertNotNil(playlists.paging)
				XCTAssertNotNil(playlists.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchFeaturedPlaylistCategories() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchFeaturedPlaylistCategories")
		_ = try? self.API.fetchFeaturedPlaylistCategories() { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let categories):
				XCTAssertNotNil(categories.categories)
				XCTAssertTrue(categories.categories.count > 0)
				for category in categories.categories {
					XCTAssertTrue(category.ID.count > 0)
					XCTAssertTrue(category.title.count > 0)
					XCTAssertTrue(category.images.count > 0)
				}
				XCTAssertNotNil(categories.paging)
				XCTAssertNotNil(categories.summary)
			}
		}
		self.wait(for: [exp], timeout: 10)
	}

	func testFetchFeaturedPlaylistInCategory() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchFeaturedPlaylistInCategory")
		_ = try? self.API.fetchFeaturedPlaylist(inCategory: "CrBHGk1J1KEsQlPLoz") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let category):
				XCTAssertNotNil(category.playlists?.playlists)
				if let playlists = category.playlists?.playlists {
					for playlist in playlists {
						self.validate(playlist: playlist)
					}
				}
				XCTAssertNotNil(category.playlists?.paging)
				XCTAssertNotNil(category.playlists?.summary)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchMoodStations() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchMoodStations")
		_ = try? self.API.fetchMoodStations() { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let stations):
				XCTAssertNotNil(stations)
				for station in stations.stations {
					XCTAssertNotNil(station)
					XCTAssertTrue(station.ID.count > 0)
					XCTAssertTrue(station.name.count > 0)
					XCTAssertTrue(station.images?.count ?? 0 > 0)
				}
			}

		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchTracksInMoodStation() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchTracksInMoodStation")
		_ = try? self.API.fetch(tracksInMoodStation: "4tmrBI125HMtMlO9OF") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let station):
				XCTAssertNotNil(station)
				XCTAssertTrue(station.ID.count > 0)
				XCTAssertTrue(station.name.count > 0)
				XCTAssertTrue(station.tracks?.tracks.count ?? 0 > 0)
				if let tracks = station.tracks?.tracks {
					for track in tracks {
						self.validate(track: track)
					}
				}
			}

		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchGenreStations() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchGenreStations")
		_ = try? self.API.fetchGenreStations() { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let stations):
				XCTAssertNotNil(stations)
				for station in stations.stations {
					XCTAssertNotNil(station)
					XCTAssertTrue(station.ID.count > 0)
					XCTAssertTrue(station.name.count > 0)
				}
			}

		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchTracksInGenreStation() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchTracksInGenreStation")
		_ = try? self.API.fetch(tracksInGenreStation: "9ZAb9rkyd3JFDBC0wF") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let station):
				XCTAssertNotNil(station)
				XCTAssertTrue(station.ID.count > 0)
				XCTAssertTrue(station.name.count > 0)
				XCTAssertTrue(station.tracks?.tracks.count ?? 0 > 0)
				if let tracks = station.tracks?.tracks {
					for track in tracks {
						self.validate(track: track)
					}
				}
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchNewReleaseAlbumsCategories() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchNewReleaseAlbumsCategories")
		_ = try? self.API.fetchNewReleaseAlbumsCategories() { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let categories):
				XCTAssertNotNil(categories)
				XCTAssertTrue(categories.categories.count > 0)
				for category in categories.categories {
					XCTAssertTrue(category.ID.count > 0)
					XCTAssertTrue(category.title.count > 0)
				}
				XCTAssertNotNil(categories.summary)
				XCTAssertNotNil(categories.paging)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchNewReleaseAlbumsUnderCategory() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchNewReleaseAlbumsUnderCategory")
		_ = try? self.API.fetch(newReleasedAlbumsUnderCategory: "0pGAIGDf5SqYh_SyHr") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let category):
				XCTAssertTrue(category.ID.count > 0)
				XCTAssertTrue(category.title.count > 0)
				guard let albums = category.albums else {
					XCTFail()
					return
				}
				XCTAssertNotNil(albums)
				XCTAssertTrue(albums.albums.count > 0)
				for album in albums.albums {
					self.validate(album: album)
				}
				XCTAssertNotNil(albums.summary)
				XCTAssertNotNil(albums.paging)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchCharts() {
		self.testFetchCredential()
		let exp = self.expectation(description: "testFetchCharts")
		_ = try? self.API.fetchCharts() { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let playlists):
				XCTAssertTrue(playlists.playlists.count > 0)
				for playlist in playlists.playlists {
					self.validate(playlist: playlist)
				}
			}
		}
		self.wait(for: [exp], timeout: 3)
	}


	static var allTests = [
		("testFetchCredential", testFetchCredential),
	]
}
