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
	public var explicitness: Bool?

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case artist = "artist"
		case images = "images"
		case releaseDate = "release_date"
		case explicitness = "explicitness"
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

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case album = "album"
		case duration = "duration"
		case trackOrderInAlbum = "track_number"
		case explicitness = "explicitness"
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

