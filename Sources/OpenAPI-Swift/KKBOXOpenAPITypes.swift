import Foundation

public struct KKPagingInfo: Codable {
	public var limit: Int
	public var offset: Int
	public var previous: String?
	public var next: String?
}

public struct KKSummary: Codable {
	public var total: Int
}

/// A struct that represents an image.
public struct KKImageInfo: Codable {
	public var width: Float
	public var height: Float
	public var url: URL?
}

/// A struct that represents an artist.
public struct KKArtistInfo: Codable {
	/// ID of the artist.
	public var ID: String
	/// Name of the artist.
	public var name: String
	/// URL of the webpage of KKBOX for the artist.
	public var url: URL?
	/// Images of the artist.
	public var images: [KKImageInfo]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case images = "images"
	}
}

/// A list of artists.
public struct KKArtistList: Codable {
	public var artists: [KKArtistInfo]
	public var paging: KKPagingInfo
	public var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case artists = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

/// A struct that represents an album.
public struct KKAlbumInfo: Codable {
	/// ID of the album.
	public var ID: String
	/// Name of the album.
	public var name: String
	/// URL of the webpage of KKBOX for the album.
	public var url: URL?
	/// Artist of the album.
	public var artist: KKArtistInfo?
	/// Cover images for the album.
	public var images: [KKImageInfo]
	/// When was the album released.
	public var releaseDate: String
	/// explicitness
	public var explicitness: Bool
	public var territoriesThatAvailanbleAt: [KKTerritory]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case artist = "artist"
		case images = "images"
		case releaseDate = "release_date"
		case explicitness = "explicitness"
		case territoriesThatAvailanbleAt = "available_territories"
	}
}

/// A list of albums.
public struct KKAlbumList: Codable {
	public var albums: [KKAlbumInfo]
	public var paging: KKPagingInfo
	public var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case albums = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

public struct KKTrackInfo: Codable {
	public var ID: String
	public var name: String
	public var url: URL?
	public var album: KKAlbumInfo?
	public var duration: TimeInterval
	public var trackOrderInAlbum: Int
	public var explicitness: Bool
	public var territoriesThatAvailanbleAt: [KKTerritory]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case album = "album"
		case duration = "duration"
		case trackOrderInAlbum = "track_number"
		case explicitness = "explicitness"
		case territoriesThatAvailanbleAt = "available_territories"
	}
}

/// A list of tracks.
public struct KKTrackList: Codable {
	public var tracks: [KKTrackInfo]
	public var paging: KKPagingInfo
	public var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case tracks = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

/// A struct that represents a user.
public struct KKUserInfo: Codable {
	/// ID of the user.
	public var ID: String
	/// Name of the user.
	public var name: String
	/// URL of the webpage of KKBOX for the user.
	public var url: URL?
	/// Cover images for the user.
	public var images: [KKImageInfo]
	/// Description of the user.
	public var userDescription: String

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
	public var ID: String
	/// Name of the playlist.
	public var name: String
	/// URL of the webpage of KKBOX for the playlist.
	public var url: URL?
	/// Cover images for the playlist.
	public var images: [KKImageInfo]
	/// Description of the playlist.
	public var playlistDescription: String
	/// Owner of the playlist.
	public var owner: KKUserInfo
	public var lastUpdateDate: String

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case images = "images"
		case playlistDescription = "description"
		case owner = "owner"
		case lastUpdateDate = "updated_at"
	}
}

/// A list of tracks.
public struct KKPlaylistList: Codable {
	public var playlists: [KKPlaylistInfo]
	public var paging: KKPagingInfo
	public var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case playlists = "data"
		case paging = "paging"
		case summary = "summary"
	}
}

public struct KKFeaturedPlaylistCategory: Codable {
	/// ID of the playlist.
	public var ID: String
	/// Title of the playlist.
	public var title: String
	/// Images for the category.
	public var images: [KKImageInfo]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case title = "title"
		case images = "images"
	}
}

public struct KKNewReleasedAlbumsCategory: Codable {
	/// ID of the playlist.
	public var ID: String
	/// Title of the playlist.
	public var title: String

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case title = "title"
	}
}

public struct KKRadioStation: Codable {
	/// ID of the station.
	public var ID: String
	/// Name of the station.
	public var name: String
	/// Category of the station.
	public var category: String
	/// Images for the name.
	public var images: [KKImageInfo]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case category = "category"
		case images = "images"
	}
}

public struct KKSearchResults: Codable {
	public var trackResults: [KKTrackList]?
	public var albumResults: [KKAlbumList]?
	public var artistResults: [KKArtistList]?
	public var playlistsResults: [KKPlaylistInfo]?

	public var paging: KKPagingInfo
	public var summary: KKSummary

	private enum CodingKeys: String, CodingKey {
		case trackResults = "tracks"
		case albumResults = "albums"
		case artistResults = "artists"
		case playlistsResults = "playlists"
		case paging = "paging"
		case summary = "summary"
	}

}


