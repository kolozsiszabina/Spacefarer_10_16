@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Planets'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_PLANET
  as select from zks1016_t_planet
{
  key planet_id   as PlanetId,
      planet_name as PlanetName,
      suit_color  as SuitColor
}
