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

public struct KKImageInfo: Codable {
	public var width: Float
	public var height: Float
	public var url: URL?
}

public struct KKArtistInfo: Codable {
	public var ID: String
	public var name: String
	public var url: URL?
	public var images: [KKImageInfo]

	private enum CodingKeys: String, CodingKey {
		case ID = "id"
		case name = "name"
		case url = "url"
		case images = "images"
	}
}

public struct KKAlbumInfo: Codable {
	public var ID: String
	public var name: String
	public var url: URL?
	public var artist: KKArtistInfo?
	public var images: [KKImageInfo]
	public var releaseDate: String
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
