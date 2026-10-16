@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stardusts'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_SDUST
  as select from zks1016_t_sdust
  association        to parent ZKS1016_I_SDUSTC as _SdustCollection on $projection.CollectionId = _SdustCollection.StardustCollId
  association [0..1] to ZKS1016_I_COLOR         as _Color           on _Color.ColorId = $projection.ColorId
  association [0..1] to ZKS1016_I_SOM           as _Matter          on _Matter.MatterId = $projection.MatterId
  association [1..1] to ZKS1016_I_SFARER        as _Spacefarer      on $projection.spacefarerid = _Spacefarer.SpacefarerId
{
  key stardust_id    as StardustId,
      collection_id  as CollectionId,
      color_id       as ColorId,
      _SdustCollection.SpacefarerId,
      @Semantics.quantity.unitOfMeasure: 'WeightUom'
      weight         as Weight,
      weight_uom     as WeightUom,
      matter_id      as MatterId,
      @Semantics.amount.currencyCode: 'ValueCurrency'
      value          as Value,
      value_currency as ValueCurrency,

      //Assotiations
      _SdustCollection,
      _Color,
      _Matter,
      _Spacefarer
}
