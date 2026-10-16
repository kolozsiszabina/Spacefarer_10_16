@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Stardust Collection (Projection)'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
  typeName: 'Stardust Collection',
  typeNamePlural: 'Stardust Collections',
  title: { type: #STANDARD, value: 'StardustCollName' }
}
define view entity ZKS1016_C_SDUSTC
  as projection on ZKS1016_I_SDUSTC
{
      @UI.facet: [
        { id: 'Collection', type: #IDENTIFICATION_REFERENCE,
          label: 'Collection', position: 10 },
        { id: 'Stardust',   type: #LINEITEM_REFERENCE,
          targetElement: '_Stardust', label: 'Stardusts', position: 20 }
      ]
      @UI.hidden: true
  key StardustCollId,

      @UI.hidden: true
      SpacefarerId,

      @UI: { lineItem: [{ position: 10 }], identification: [{ position: 10 }] }
      @EndUserText.label: 'Collection Name'
      StardustCollName,

      /* Associations */
      _Spacefarer : redirected to parent ZKS1016_C_SFARER,
      _Stardust   : redirected to composition child ZKS1016_C_SDUST
}
