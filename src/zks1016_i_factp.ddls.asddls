@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Faction Position'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_FACTP
  as select from zks1016_t_factp
  association to parent ZKS1016_I_FACT as _Faction on $projection.FactionId = _Faction.FactionId
{
  key faction_id           as FactionId,
  key position_id          as PositionId,
      position_description as PositionDescription,

      //Associations
      _Faction
}
