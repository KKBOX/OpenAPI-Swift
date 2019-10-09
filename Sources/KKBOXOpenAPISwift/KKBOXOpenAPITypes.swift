//
// KKBOXOpenAPITypes.swift
//
// Copyright (c) 2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import Foundation

/// A struct represents pagination info of a list.
public struct KKPagingInfo: Codable {
	/// The maximum amount of the items in the list.
	public internal(set) var limit: Int
	/// Where the list begins.
	public internal(set) var offset: Int
	/// The URL for the API call for the previous page.
	public internal(set) var previous: URL?
	/// The URL for the API call for the next page.
	public internal(set) var next: URL?
}

/// An overall summary for a list.
public struct KKSummary: Codable {
	/// The total amount of the items matching to your criteria.
	public internal(set) var total: Int
}

/// A struct that represents an image.
public struct KKImageInfo: Codable {
	/// The width of the image.
	public internal(set) var width: Float
	/// The height of the image.
	public internal(set) var height: Float
	/// The URL of the image.
	public internal(set) var url: URL?
}

//MARK: -

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
	/// The artists.
	public internal(set) var artists: [KKArtistInfo]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case artists = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

/// A struct that represents an album.
public struct KKAlbumInfo: Codable {
	/// The ID of the album.
	public internal(set) var ID: String
	/// The name of the album.
	public internal(set) var name: String
	/// The URL of the webpage of KKBOX for the album.
	public internal(set) var url: URL?
	/// The artist of the album.
	public internal(set) var artist: KKArtistInfo?
	/// The cover images for the album.
	public internal(set) var images: [KKImageInfo]
	/// When was the album released.
	public internal(set) var releaseDate: String?
	/// If the album explicit or not.
	public internal(set) var explicitness: Bool
	/// The territories where the album is available at.
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
	/// The albums.
	public internal(set) var albums: [KKAlbumInfo]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case albums = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

public struct KKTrackInfo: Codable {
	/// ID of the track.
	public internal(set) var ID: String
	/// The name of the track.
	public internal(set) var name: String
	/// The URL of the webpage of KKBOX for the track.
	public internal(set) var url: URL?
	/// The album that contains the track.
	public internal(set) var album: KKAlbumInfo?
	/// The length of the track.
	public internal(set) var duration: TimeInterval
	/// The order index of the track in the album.
	public internal(set) var trackOrderInAlbum: Int
	/// Explicitness.
	public internal(set) var explicitness: Bool
	/// The territories where the track is available at.
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
	/// The tracks.
	public internal(set) var tracks: [KKTrackInfo]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case tracks = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

/// A struct that represents a user.
public struct KKUserInfo: Codable {
	/// The ID of the user.
	public internal(set) var ID: String
	/// The name of the user.
	public internal(set) var name: String
	/// The URL of the webpage of KKBOX for the user.
	public internal(set) var url: URL?
	/// The images for the user.
	public internal(set) var images: [KKImageInfo]
	/// The description of the user.
	public internal(set) var userDescription: String

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case images = "images"
		case userDescription = "description"
	}
}

//MARK: -

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
	public internal(set) var lastUpdateDate: Date
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
	/// The playlists.
	public internal(set) var playlists: [KKPlaylistInfo]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case playlists = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

/// A struct that represents a featured playlist category.
public struct KKFeaturedPlaylistCategory: Codable {
	/// The ID of the category.
	public internal(set) var ID: String
	/// The title of the category.
	public internal(set) var title: String
	/// The images for the category.
	public internal(set) var images: [KKImageInfo]
	/// The playlists
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
	/// The categories.
	public internal(set) var categories: [KKFeaturedPlaylistCategory]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case categories = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

/// A struct that represents a new release albums category.
public struct KKNewReleasedAlbumsCategory: Codable {
	/// The ID of the playlist.
	public internal(set) var ID: String
	/// The title of the playlist.
	public internal(set) var title: String
	/// The albums under the category.
	public internal(set) var albums: KKAlbumList?

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case title = "title"
		case albums = "albums"
	}
}

/// A list of featured play list categories.
public struct KKNewReleasedAlbumsCategoryList: Codable {
	/// The categories.
	public internal(set) var categories: [KKNewReleasedAlbumsCategory]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case categories = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

/// A struct that represents a radio station.
public struct KKRadioStation: Codable {
	/// The ID of the station.
	public internal(set) var ID: String
	/// The name of the station.
	public internal(set) var name: String
	/// The category of the station.
	public internal(set) var category: String?
	/// The images for the name.
	public internal(set) var images: [KKImageInfo]?
	/// The tracks in the station.
	public internal(set) var tracks: KKTrackList?

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case category = "category"
		case images = "images"
		case tracks = "tracks"
	}
}

/// A list of stations.
public struct KKRadioStationList: Codable {
	/// The stations.
	public internal(set) var stations: [KKRadioStation]
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
	public internal(set) var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case stations = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

//MARK: -

/// Represents the search results. See `KKBOXOpenAPI.search(with:types:territory:offset:limit:callback:)`.
public struct KKSearchResults: Codable {
	/// Track search results.
	public internal(set) var trackResults: KKTrackList?
	/// Album search results.
	public internal(set) var albumResults: KKAlbumList?
	/// Artist search results.
	public internal(set) var artistResults: KKArtistList?
	/// Playlist search results.
	public internal(set) var playlistsResults: KKPlaylistList?
	/// The pagination info.
	public internal(set) var paging: KKPagingInfo
	/// The overall summary.
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


