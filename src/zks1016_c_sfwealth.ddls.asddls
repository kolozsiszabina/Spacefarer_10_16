@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Spacefarer Wealth'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_C_SFWEALTH
  as select from ZKS1016_I_SFWEALTH
{
      @UI.hidden: true
  key SpacefarerId,

      @UI: { lineItem: [{ position: 10 }], identification: [{ position: 10 }] }
      @EndUserText.label: 'Name'
      Name,

      @UI: { lineItem: [{ position: 20 }], identification: [{ position: 20 }] }
      @EndUserText.label: 'Faction'
      FactionId,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI: { lineItem: [{ position: 20 }], identification: [{ position: 20 }] }
      @EndUserText.label: 'Credits'
      Credits,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI: { lineItem: [{ position: 30 }], identification: [{ position: 30 }] }
      @EndUserText.label: 'Total Value'
      TotalValue,
      CurrencyCode
}
