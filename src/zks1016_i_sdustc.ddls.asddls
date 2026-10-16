@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stardust Collection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_SDUSTC
  as select from zks1016_t_sdustc
  association to parent ZKS1016_I_SFARER as _Spacefarer on $projection.SpacefarerId = _Spacefarer.SpacefarerId
  composition [0..*] of ZKS1016_I_SDUST  as _Stardust
{
  key stardust_coll_id   as StardustCollId,
      spacefarer_id      as SpacefarerId,
      stardust_coll_name as StardustCollName,

      //Assotiations
      _Stardust,
      _Spacefarer
}
