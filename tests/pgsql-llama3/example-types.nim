# ESI asset endpoints
# https://esi.evetech.net/ui/#/Assets

type
  CharacterAssetResp* = ref object
    isBlueprintCopy: Option[bool]
    isSingleton: bool
    itemId: int64
    locationFlag: string
    locationId: int64
    locationType: string
    quantity: int32
    typeId: int32
  CorporateAssetResp* = ref object
    isBlueprintCopy: Option[bool]
    isSingleton: bool
    itemId: int64
    locationFlag: string
    locationId: int64
    locationType: string
    quantity: int32
    typeId: int32