@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spacefarer'
@UI.createHidden: false
define root view entity ZKS1016_I_SFARER
  as select from zks1016_t_sfarer
  composition [0..*] of ZKS1016_I_SDUSTC as _Collection
  association [0..1] to ZKS1016_I_SDUSTC as _Collections     on  $projection.SpacefarerId = _Collections.SpacefarerId
  association [0..*] to ZKS1016_I_SDUST  as _Stardust        on  $projection.SpacefarerId = _Stardust.SpacefarerId
  association [0..1] to ZKS1016_I_PLANET as _Planet          on  $projection.OriginPlanet = _Planet.PlanetId
  association [1..1] to ZKS1016_I_FACT   as _Faction         on  $projection.FactionId = _Faction.FactionId
  association [0..1] to ZKS1016_I_FACTP  as _FactionPosition on  $projection.FactionId  = _FactionPosition.FactionId
                                                             and $projection.PositionId = _FactionPosition.PositionId
{
  key spacefarer_id               as SpacefarerId,
      name                        as Name,
      _Collections.StardustCollId as StardustCollId,
      wormhole_nav_skill          as WormholeNavSkill,
      reputation                  as Reputation,
      origin_planet               as OriginPlanet,
      _Planet.SuitColor           as SuitColor,
      faction_id                  as FactionId,
      position_id                 as PositionId,
      @Semantics.amount.currencyCode: 'CreditsCurrency'
      credits                     as Credits,
      credits_currency            as CreditsCurrency,
      @Semantics.systemDateTime.createdAt: true
      created_on                  as CreatedOn,
      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on                  as ChangedOn,
      @Semantics.user.lastChangedBy: true
      changed_by                  as ChangedBy,
      @Semantics.largeObject:{
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #INLINE
      }
      attachment                  as Attachment,
      @Semantics.mimeType: true
      mimetype                    as MimeType,
      filename                    as FileName,

      //Assotiations
      _Collections,
      _Collection,
      _Stardust,
      _Planet,
      _Faction,
      _FactionPosition
}
