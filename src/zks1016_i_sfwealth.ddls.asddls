@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spacefarer Wealth'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_SFWEALTH
  as select from    ZKS1016_I_SFARER   as _Spacefarer
    left outer join ZKS1016_I_SFSDUSTC as _SpacefarerCollection on  _Spacefarer.SpacefarerId   = _SpacefarerCollection.SpacefarerId
                                                                and _Spacefarer.StardustCollId = _SpacefarerCollection.StardustCollId
{
  key  _Spacefarer.SpacefarerId,
       _Spacefarer.Name,
       _Spacefarer.FactionId,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       _Spacefarer.Credits,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       _SpacefarerCollection.TotalValue,
       _SpacefarerCollection.CurrencyCode
}
