@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Spacefarer Stardust Collection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_C_SFSDUSTC
  as select from ZKS1016_I_SFSDUSTC
{

      @UI.hidden: true
  key SpacefarerId,

      @UI: { lineItem: [{ position: 10 }], identification: [{ position: 10 }] }
      @EndUserText.label: 'Name'
      Name,

      @UI.hidden: true
      StardustCollId,

      @UI: {lineItem: [{ position: 20 }], identification: [{ position: 20 }],
            fieldGroup: [{ qualifier: 'Collection', position: 10 }], selectionField: [{ position: 20 } ] }
      @EndUserText.label: 'Collection Description'
      @EndUserText.quickInfo: 'Collection Description'
      StardustCollName,

      @UI: { lineItem: [{ position: 30 }], identification: [{ position: 30 }] }
      @EndUserText.label: 'Total Weight'
      @Semantics.quantity.unitOfMeasure: 'WeightUom'
      TotalWeight,
      WeightUom,

      @UI: { lineItem: [{ position: 40 }], identification: [{ position: 40 }] }
      @EndUserText.label: 'Total Value'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalValue,
      CurrencyCode,

      /* Associations */
      _Collection
}
