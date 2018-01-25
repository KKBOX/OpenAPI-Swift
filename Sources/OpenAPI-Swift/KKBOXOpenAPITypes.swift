//
// KKBOXOpenAPITypes.swift
//
// Copyright (c) 2018 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import Foundation

public struct KKPagingInfo: Codable {
	public internal(set) var limit: Int
	public internal(set) var offset: Int
	public internal(set) var previous: String?
	public internal(set) var next: String?
}

public struct KKSummary: Codable {
	public internal(set) var total: Int
}

/// A struct that represents an image.
public struct KKImageInfo: Codable {
	public internal(set) var width: Float
	public internal(set) var height: Float
	public internal(set) var url: URL?
}

/// A struct that represents an artist.
public struct KKArtistInfo: Codable {
	/// ID of the artist.
	public internal(set) var ID: String
	/// Name of the artist.
	public internal(set) var name: String
	/// URL of the webpage of KKBOX for the artist.
	public internal(set) var url: URL?
	/// Images of the artist.
	public internal(set) var images: [KKImageInfo]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case images = "images"
	}
}

/// A list of artists.
public struct KKArtistList: Codable {
	public internal(set) var artists: [KKArtistInfo]
	public internal(set) var paging: KKPagingInfo
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case artists = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

/// A struct that represents an album.
public struct KKAlbumInfo: Codable {
	/// ID of the album.
	public internal(set) var ID: String
	/// Name of the album.
	public internal(set) var name: String
	/// URL of the webpage of KKBOX for the album.
	public internal(set) var url: URL?
	/// Artist of the album.
	public internal(set) var artist: KKArtistInfo?
	/// Cover images for the album.
	public internal(set) var images: [KKImageInfo]
	/// When was the album released.
	public internal(set) var releaseDate: String
	/// explicitness
	public internal(set) var explicitness: Bool
	public internal(set) var territoriesThatAvailableAt: [KKTerritory]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case artist = "artist"
		case images = "images"
		case releaseDate = "release_date"
		case explicitness = "explicitness"
		case territoriesThatAvailableAt = "available_territories"
	}
}

/// A list of albums.
public struct KKAlbumList: Codable {
	public internal(set) var albums: [KKAlbumInfo]
	public internal(set) var paging: KKPagingInfo
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case albums = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

public struct KKTrackInfo: Codable {
	public internal(set) var ID: String
	public internal(set) var name: String
	public internal(set) var url: URL?
	public internal(set) var album: KKAlbumInfo?
	public internal(set) var duration: TimeInterval
	public internal(set) var trackOrderInAlbum: Int
	public internal(set) var explicitness: Bool
	public internal(set) var territoriesThatAvailableAt: [KKTerritory]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case album = "album"
		case duration = "duration"
		case trackOrderInAlbum = "track_number"
		case explicitness = "explicitness"
		case territoriesThatAvailableAt = "available_territories"
	}
}

/// A list of tracks.
public struct KKTrackList: Codable {
	public internal(set) var tracks: [KKTrackInfo]
	public internal(set) var paging: KKPagingInfo
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case tracks = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

/// A struct that represents a user.
public struct KKUserInfo: Codable {
	/// ID of the user.
	public internal(set) var ID: String
	/// Name of the user.
	public internal(set) var name: String
	/// URL of the webpage of KKBOX for the user.
	public internal(set) var url: URL?
	/// Cover images for the user.
	public internal(set) var images: [KKImageInfo]
	/// Description of the user.
	public internal(set) var userDescription: String

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case images = "images"
		case userDescription = "description"
	}
}

/// A struct that represents a playlist.
public struct KKPlaylistInfo: Codable {
	/// ID of the playlist.
	public internal(set) var ID: String
	/// Title of the playlist.
	public internal(set) var title: String
	/// URL of the webpage of KKBOX for the playlist.
	public internal(set) var url: URL?
	/// Cover images for the playlist.
	public internal(set) var images: [KKImageInfo]
	/// Description of the playlist.
	public internal(set) var playlistDescription: String
	/// Owner of the playlist.
	public internal(set) var owner: KKUserInfo
	/// When is the playlist updated
	public internal(set) var lastUpdateDate: String
	/// Tracks contained in the playlist.
	public internal(set) var tracks: KKTrackList?

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case title = "title"
		case url = "url"
		case images = "images"
		case playlistDescription = "description"
		case owner = "owner"
		case lastUpdateDate = "updated_at"
		case tracks = "tracks"
	}
}

/// A list of tracks.
public struct KKPlaylistList: Codable {
	public internal(set) var playlists: [KKPlaylistInfo]
	public internal(set) var paging: KKPagingInfo
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case playlists = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

/// A struct that represents a featured playlist category.
public struct KKFeaturedPlaylistCategory: Codable {
	/// ID of the category.
	public internal(set) var ID: String
	/// Title of the category.
	public internal(set) var title: String
	/// Images for the category.
	public internal(set) var images: [KKImageInfo]
	/// Playlists
	public internal(set) var playlists: KKPlaylistList?

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case title = "title"
		case images = "images"
		case playlists = "playlists"
	}
}

/// A list of featured play list categories.
public struct KKFeaturedPlaylistCategoryList: Codable {
	public internal(set) var categories: [KKFeaturedPlaylistCategory]
	public internal(set) var paging: KKPagingInfo
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case categories = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

public struct KKNewReleasedAlbumsCategory: Codable {
	/// ID of the playlist.
	public internal(set) var ID: String
	/// Title of the playlist.
	public internal(set) var title: String

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case title = "title"
	}
}

public struct KKRadioStation: Codable {
	/// ID of the station.
	public internal(set) var ID: String
	/// Name of the station.
	public internal(set) var name: String
	/// Category of the station.
	public internal(set) var category: String
	/// Images for the name.
	public internal(set) var images: [KKImageInfo]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case category = "category"
		case images = "images"
	}
}

public struct KKSearchResults: Codable {
	public internal(set) var trackResults: [KKTrackList]?
	public internal(set) var albumResults: [KKAlbumList]?
	public internal(set) var artistResults: [KKArtistList]?
	public internal(set) var playlistsResults: [KKPlaylistInfo]?

	public internal(set) var paging: KKPagingInfo
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case trackResults = "tracks"
		case albumResults = "albums"
		case artistResults = "artists"
		case playlistsResults = "playlists"
		case paging = "paging"
		case summary = "summary"
	}
}


