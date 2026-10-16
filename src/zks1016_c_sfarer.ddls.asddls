@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Spacefarer'
@UI.headerInfo: {
  typeName: 'Spacefarer',
  typeNamePlural: 'Spacefarers',
  title:       { type: #STANDARD, value: 'Name' },
  description: { type: #STANDARD, value: 'OriginPlanet' },
    imageUrl: 'Attachment'
}
define root view entity ZKS1016_C_SFARER
  provider contract transactional_query
  as projection on ZKS1016_I_SFARER
{
      @UI.hidden: true
      @UI.facet: [
        { id: 'Details',    type: #IDENTIFICATION_REFERENCE,
          label: 'Spacefarer', position: 10 },
        { id: 'Collection', type: #LINEITEM_REFERENCE,
          targetElement: '_Collection', label: 'Stardust Collection', position: 20 },
        { id: 'CollectionItem', type: #LINEITEM_REFERENCE,
          targetElement: '_Stardust', label: 'Stardusts', position: 30 }
      ]
  key SpacefarerId,

      @UI: {lineItem: [{ position: 10 }], identification: [{ position: 10 }], selectionField: [{ position: 10 } ] }
      @EndUserText: { label: 'Spacefarer Name', quickInfo: 'Spacefarer Name' }
      Name,

      @UI.hidden: true
      StardustCollId,

      @UI: {lineItem: [{ position: 20 }], identification: [{ position: 20 }], selectionField: [{ position: 20 } ] }
      @EndUserText: { label: 'Collection Description', quickInfo: 'Collection Description' }
      _Collections.StardustCollName,

      @UI: {lineItem: [{ position: 30 }], identification: [{ position: 30 }], selectionField: [{ position: 30 } ] }
      @EndUserText: { label: 'Wormhole Navigation Skill', quickInfo: 'Wormhole Navigation Skill' }
      WormholeNavSkill,

      @UI: {lineItem: [{ position: 40 }], identification: [{ position: 40 }], selectionField: [{ position: 40 } ] }
      @EndUserText: { label: 'Reputation', quickInfo: 'Reputation' }
      Reputation,

      @UI: {lineItem: [{ position: 50 }], identification: [{ position: 50 }], selectionField: [{ position: 50 } ] }
      @EndUserText: { label: 'Origin of Planet', quickInfo: 'Origin of Planet' }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZKS1016_I_PLANET', element: 'PlanetId' } }]
      OriginPlanet,

      @UI: {lineItem: [{ position: 60 }], identification: [{ position: 60 }], selectionField: [{ position: 60 } ] }
      @EndUserText: { label: 'Color of Suit', quickInfo: 'Color of Suit' }
      SuitColor,

      @UI: {lineItem: [{ position: 70 }], identification: [{ position: 70 }], selectionField: [{ position: 70 } ] }
      @EndUserText: { label: 'Faction', quickInfo: 'Faction' }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZKS1016_I_FACT', element: 'FactionId' } }]
      FactionId,

      @UI: {lineItem: [{ position: 80 }], identification: [{ position: 80 }], selectionField: [{ position: 80 } ] }
      @EndUserText: { label: 'Position', quickInfo: 'Position' }
      @Consumption.valueHelpDefinition: [{
      entity: { name: 'ZKS1016_I_FACTP', element: 'PositionId' },
      additionalBinding: [{ localElement: 'FactionId',  element: 'FactionId', usage: #FILTER }] }]
      PositionId,

      @Semantics.amount.currencyCode: 'CreditsCurrency'
      @UI: {lineItem: [{ position: 90 }],  identification: [{ position: 90 }],  selectionField: [{ position: 90 } ] }
      @EndUserText: { label: 'Credits', quickInfo: 'Credits' }
      Credits,
      CreditsCurrency,

      @UI.hidden: true
      CreatedOn,

      @UI.hidden: true
      CreatedBy,

      @UI.hidden: true
      ChangedOn,

      @UI.hidden: true
      ChangedBy,

      @UI: {lineItem: [{ position: 100 }], identification: [{ position: 100 }] }
      @EndUserText: { label: 'Picture', quickInfo: 'Picture' }
      Attachment,

      @UI.hidden: true
      MimeType,

      @UI.hidden: true
      FileName,

      /* Associations */
      _Collection : redirected to composition child ZKS1016_C_SDUSTC,
      _Stardust   : redirected to ZKS1016_C_SDUST,
      _Faction,
      _FactionPosition,
      _Planet
}
