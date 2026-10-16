@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help: Stardust'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define view entity ZKS1016_I_SDUST_VH
  as select from zks1016_t_sdust  as Stardust
    inner join   zks1016_t_sdustc as Collection on Collection.stardust_coll_id = Stardust.collection_id
    inner join   zks1016_t_sfarer as Owner      on Owner.spacefarer_id         = Collection.spacefarer_id
{
      @UI.hidden: true
  key Stardust.stardust_id    as StardustId,

      @EndUserText.label: 'Owner'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Owner.name              as OwnerName,

      @EndUserText.label: 'Color'
      @Search.defaultSearchElement: true
      Stardust.color_id       as ColorId,

      @EndUserText.label: 'State of Matter'
      Stardust.matter_id      as MatterId,

      @EndUserText.label: 'Value'
      @Semantics.amount.currencyCode: 'ValueCurrency'
      Stardust.value          as Value,

      Stardust.value_currency as ValueCurrency
}
