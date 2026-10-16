@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Colors'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKS1016_I_COLOR
as select from zks1016_t_color
{
    key color_id as ColorId,
    color_description as ColorDescription
}
