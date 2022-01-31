import Foundation
import GRDB

class NftAssetRecord: Record {
    let accountId: String

    let contract: NftCollection.Contract
    let collectionSlug: String
    let tokenId: String
    let name: String?
    let imageUrl: String?
    let imagePreviewUrl: String?
    let description: String?
    let externalLink: String?
    let permalink: String?
    let traits: [NftAsset.Trait]
    let lastSalePrice: NftPriceRecord?

    init(accountId: String, asset: NftAsset) {
        self.accountId = accountId
        contract = asset.contract
        collectionSlug = asset.collectionSlug
        tokenId = asset.tokenId
        name = asset.name
        imageUrl = asset.imageUrl
        imagePreviewUrl = asset.imagePreviewUrl
        description = asset.description
        externalLink = asset.externalLink
        permalink = asset.permalink
        traits = asset.traits
        lastSalePrice = asset.lastSalePrice.map { NftPriceRecord(price: $0) }

        super.init()
    }

    override class var databaseTableName: String {
        "nftAssetRecord"
    }

    enum Columns: String, ColumnExpression {
        case accountId
        case contractAddress
        case contractSchemaName
        case collectionSlug
        case tokenId
        case name
        case imageUrl
        case imagePreviewUrl
        case description
        case externalLink
        case permalink
        case traits
        case lastSalePriceCoinTypeId
        case lastSalePriceValue
    }

    required init(row: Row) {
        accountId = row[Columns.accountId]
        contract = NftCollection.Contract(address: row[Columns.contractAddress], schemaName: row[Columns.contractSchemaName])
        collectionSlug = row[Columns.collectionSlug]
        tokenId = row[Columns.tokenId]
        name = row[Columns.name]
        imageUrl = row[Columns.imageUrl]
        imagePreviewUrl = row[Columns.imagePreviewUrl]
        description = row[Columns.description]
        externalLink = row[Columns.externalLink]
        permalink = row[Columns.permalink]
        traits = [NftAsset.Trait](JSONString: row[Columns.traits]) ?? []
        lastSalePrice = NftPriceRecord(coinTypeId: row[Columns.lastSalePriceCoinTypeId], value: row[Columns.lastSalePriceValue])

        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.accountId] = accountId
        container[Columns.contractAddress] = contract.address
        container[Columns.contractSchemaName] = contract.schemaName
        container[Columns.collectionSlug] = collectionSlug
        container[Columns.tokenId] = tokenId
        container[Columns.name] = name
        container[Columns.imageUrl] = imageUrl
        container[Columns.imagePreviewUrl] = imagePreviewUrl
        container[Columns.description] = description
        container[Columns.externalLink] = externalLink
        container[Columns.permalink] = permalink
        container[Columns.traits] = traits.toJSONString()
        container[Columns.lastSalePriceCoinTypeId] = lastSalePrice?.coinTypeId
        container[Columns.lastSalePriceValue] = lastSalePrice?.value
    }

}