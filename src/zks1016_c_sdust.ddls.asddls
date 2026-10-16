@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stardusts (Projection)'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
  typeName: 'Stardust',
  typeNamePlural: 'Stardusts',
  title: { type: #STANDARD, value: 'ColorId' }
}
define view entity ZKS1016_C_SDUST
  as projection on ZKS1016_I_SDUST
{
      @UI.facet: [
        { id: 'Stardust', type: #IDENTIFICATION_REFERENCE,
          label: 'Stardust', position: 10 }
      ]
      @UI.hidden: true
  key StardustId,
      @UI.hidden: true
      CollectionId,

      @UI: { lineItem:       [{ position: 10 },
                                    { type: #FOR_ACTION, dataAction: 'buyStardust',      label: 'Buy'      },
                                    { type: #FOR_ACTION, dataAction: 'sellStardust',     label: 'Sell'     },
                                    { type: #FOR_ACTION, dataAction: 'exchangeStardust', label: 'Exchange' }],
                   identification: [{ position: 10 },
                                    { type: #FOR_ACTION, dataAction: 'buyStardust',      label: 'Buy'      },
                                    { type: #FOR_ACTION, dataAction: 'sellStardust',     label: 'Sell'     },
                                    { type: #FOR_ACTION, dataAction: 'exchangeStardust', label: 'Exchange' }] }
      @EndUserText.label: 'Color'
      ColorId,

      @UI.hidden: true
      SpacefarerId,

      @UI: { lineItem: [{ position: 20 }], identification: [{ position: 20 }] }
      @EndUserText.label: 'Weight'
      @Semantics.quantity.unitOfMeasure: 'WeightUom'
      Weight,
      WeightUom,

      @UI: { lineItem: [{ position: 30 }], identification: [{ position: 30 }] }
      @EndUserText.label: 'State of Matter'
      MatterId,

      @UI: { lineItem: [{ position: 40 }], identification: [{ position: 40 }] }
      @EndUserText.label: 'Value'
      @Semantics.amount.currencyCode: 'ValueCurrency'
      Value,
      ValueCurrency,

      /* Associations */
      _SdustCollection : redirected to parent ZKS1016_C_SDUSTC,
      _Spacefarer      : redirected to ZKS1016_C_SFARER,
      _Color,
      _Matter
}
