@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Faction'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_FACT
  as select from zks1016_t_fact
  composition [0..*] of ZKS1016_I_FACTP as _Position
{
  key faction_id          as FactionId,
      faction_description as FactionDescription,

      _Position
}
