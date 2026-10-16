@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spacefarer Stardust Collection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_SFSDUSTC
  as select from    ZKS1016_I_SFARER as _Spacefarer
    inner join      zks1016_t_sdustc as _Collection on _Spacefarer.SpacefarerId = _Collection.spacefarer_id
    left outer join zks1016_t_sdust  as _Stardust   on _Collection.stardust_coll_id = _Stardust.collection_id

{
  key _Spacefarer.SpacefarerId,
      _Spacefarer.Name,
      _Spacefarer._Collection.StardustCollId   as StardustCollId,
      _Spacefarer._Collection.StardustCollName as StardustCollName,
      @Semantics.quantity.unitOfMeasure: 'WeightUom'
      sum( _Stardust.weight )                  as TotalWeight,
      _Stardust.weight_uom                     as WeightUom,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum( _Stardust.value )                   as TotalValue,
      _Stardust.value_currency                 as CurrencyCode,

      /* Associations */
      _Spacefarer._Collection
}
group by
  _Spacefarer.SpacefarerId,
  _Spacefarer.Name,
  _Spacefarer._Collection.StardustCollId,
  _Spacefarer._Collection.StardustCollName,
  _Stardust.weight_uom,
  _Stardust.value_currency
