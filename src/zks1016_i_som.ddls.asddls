@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'State of Matters'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_SOM
  as select from zks1016_t_som
{
  key matter_id          as MatterId,
      matter_description as MatterDescription
}
