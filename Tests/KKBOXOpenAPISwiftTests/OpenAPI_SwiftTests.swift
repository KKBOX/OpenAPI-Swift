//
// OpenAPI_SwiftTests.swift
//
// Copyright (c) 2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import XCTest
@testable import KKBOXOpenAPISwift

class KKBOXOpenAPISwiftTest: XCTestCase {
	var API: KKBOXOpenAPI!

	override func setUp() {
		super.setUp()
		self.API = KKBOXOpenAPI(clientID: "2074348baadf2d445980625652d9a54f", secret: "ac731b44fb2cf1ea766f43b5a65e82b8")
		self.fetchCredential()
	}

	func testFetchWithInvalidCredential() {
		self.API = KKBOXOpenAPI(clientID: "121321223123123", secret: "1231231321213")
		let exp = self.expectation(description: "testFetchWithInvalidCredential")
		_ = try? self.API.fetchAccessTokenByClientCredential { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTAssertTrue((error as NSError).code == 401)
			case .success(_):
				XCTFail("It is not possible.")
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func fetchCredential() {
//		if self.API.isLoggedIn {
//			return
//		}
		let exp = self.expectation(description: "fetchCredential")
		_ = try? self.API.fetchAccessTokenByClientCredential { result in
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let response):
				XCTAssertTrue(response.accessToken.count > 0)
				XCTAssertTrue(response.expiresIn > 0)
				XCTAssertTrue(response.tokenType?.count ?? 0 > 0)
			}
			exp.fulfill()
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
//		XCTAssertTrue(track.trackOrderInAlbum > 0)
//		XCTAssertTrue(track.territoriesThatAvailableAt.count > 0)
//		XCTAssertTrue(track.territoriesThatAvailableAt.contains(.taiwan))
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

	func testFetchInvalidTrack() {

		let exp = self.expectation(description: "testFetchInvalidTrack")
		_ = try? self.API.fetch(track: "11111") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTAssertNotNil(error)
				XCTAssertTrue((error as NSError).code == 404)
			case .success(_):
				XCTFail()
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchAlbum() {
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

	func testFetchInvalidAlbum() {
		let exp = self.expectation(description: "testFetchInvalidAlbum")
		_ = try? self.API.fetch(album: "11111") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTAssertNotNil(error)
				XCTAssertTrue((error as NSError).code == 404)
			case .success(_):
				XCTFail()
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchTracksInAlbum() {
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

	func testFetchTracksInInvalidAlbum() {
		let exp = self.expectation(description: "testFetchTracksInInvalidAlbum")
		_ = try? self.API.fetch(tracksInAlbum: "1111111") { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTAssertNotNil(error)
				XCTAssertTrue((error as NSError).code == 404)
			case .success(_):
				XCTFail()
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testFetchArtist() {
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
		self.wait(for: [exp], timeout: 10)
	}

	func testFetchTracksInPlaylist() {
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
		self.wait(for: [exp], timeout: 10)
	}

	func testFetchFeaturedPlaylists() {
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
		self.wait(for: [exp], timeout: 10)
	}

	func testFetchGenreStations() {
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

	func testSearchAll() {
		let exp = self.expectation(description: "testSearchAll")
		let types: KKSearchType =  [
			KKSearchType.track,
		  	KKSearchType.album,
			KKSearchType.artist,
		  	KKSearchType.playlist
		]
		_ = try? self.API.search(with: "Love", types: types) { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let searchResults):
				XCTAssertNotNil(searchResults)
				XCTAssertNotNil(searchResults.trackResults)
				XCTAssertNotNil(searchResults.albumResults)
				XCTAssertNotNil(searchResults.artistResults)
				XCTAssertNotNil(searchResults.playlistsResults)
			}
		}
		self.wait(for: [exp], timeout: 10)
	}

	func testSearch1() {
		let exp = self.expectation(description: "testSearchAll")
		let types: KKSearchType =  [
			KKSearchType.track,
//			KKSearchType.album,
//			KKSearchType.artist,
//			KKSearchType.playlist
		]
		_ = try? self.API.search(with: "Love", types: types) { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let searchResults):
				XCTAssertNotNil(searchResults)
				XCTAssertNotNil(searchResults.trackResults)
				XCTAssertNil(searchResults.albumResults)
				XCTAssertNil(searchResults.artistResults)
				XCTAssertNil(searchResults.playlistsResults)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testSearch2() {
		let exp = self.expectation(description: "testSearchAll")
		let types: KKSearchType =  [
//			KKSearchType.track,
			KKSearchType.album,
//			KKSearchType.artist,
//			KKSearchType.playlist
		]
		_ = try? self.API.search(with: "Love", types: types) { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let searchResults):
				XCTAssertNotNil(searchResults)
				XCTAssertNil(searchResults.trackResults)
				XCTAssertNotNil(searchResults.albumResults)
				XCTAssertNil(searchResults.artistResults)
				XCTAssertNil(searchResults.playlistsResults)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testSearch3() {
		let exp = self.expectation(description: "testSearchAll")
		let types: KKSearchType =  [
//			KKSearchType.track,
//			KKSearchType.album,
			KKSearchType.artist,
//			KKSearchType.playlist
		]
		_ = try? self.API.search(with: "Love", types: types) { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let searchResults):
				XCTAssertNotNil(searchResults)
				XCTAssertNil(searchResults.trackResults)
				XCTAssertNil(searchResults.albumResults)
				XCTAssertNotNil(searchResults.artistResults)
				XCTAssertNil(searchResults.playlistsResults)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	func testSearch4() {
		let exp = self.expectation(description: "testSearchAll")
		let types: KKSearchType =  [
//			KKSearchType.track,
//			KKSearchType.album,
//			KKSearchType.artist,
			KKSearchType.playlist
		]
		_ = try? self.API.search(with: "Love", types: types) { result in
			exp.fulfill()
			switch result {
			case .error(let error):
				XCTFail(error.localizedDescription)
			case .success(let searchResults):
				XCTAssertNotNil(searchResults)
				XCTAssertNil(searchResults.trackResults)
				XCTAssertNil(searchResults.albumResults)
				XCTAssertNil(searchResults.artistResults)
				XCTAssertNotNil(searchResults.playlistsResults)
			}
		}
		self.wait(for: [exp], timeout: 3)
	}

	static var allTests = [
		("fetchCredential", fetchCredential),
		("testFetchWithInvalidCredential", testFetchWithInvalidCredential),
		("testFetchTrack", testFetchTrack),
		("testFetchAlbum", testFetchAlbum),
		("testFetchArtist", testFetchArtist),
		("testFetchAlbumsOfArtist", testFetchAlbumsOfArtist),
		("testFetchTopTracksOfArtist", testFetchTopTracksOfArtist),
		("testFetchRelatedArtists", testFetchRelatedArtists),
		("testFetchPlaylist", testFetchPlaylist),
		("testFetchTracksInPlaylist", testFetchTracksInPlaylist),
		("testFetchFeaturedPlaylists", testFetchFeaturedPlaylists),
		("testFetchNewHitsPlaylists", testFetchNewHitsPlaylists),
		("testFetchFeaturedPlaylistCategories", testFetchFeaturedPlaylistCategories),
		("testFetchFeaturedPlaylistInCategory", testFetchFeaturedPlaylistInCategory),
		("testFetchMoodStations", testFetchMoodStations),
		("testFetchTracksInMoodStation", testFetchTracksInMoodStation),
		("testFetchGenreStations", testFetchGenreStations),
		("testFetchTracksInGenreStation", testFetchTracksInGenreStation),
		("testFetchNewReleaseAlbumsCategories", testFetchNewReleaseAlbumsCategories),
		("testFetchNewReleaseAlbumsUnderCategory", testFetchNewReleaseAlbumsUnderCategory),
		("testFetchCharts", testFetchCharts),
		("testSearchAll", testSearchAll),
		("testSearch1", testSearch1),
		("testSearch2", testSearch2),
		("testSearch3", testSearch3),
		("testSearch4", testSearch4),
		]
}
