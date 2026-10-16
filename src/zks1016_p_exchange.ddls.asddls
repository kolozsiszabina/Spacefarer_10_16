@EndUserText.label: 'Parameter for exchange action'
define abstract entity zks1016_p_exchange
{
  @EndUserText.label: 'Other Spacefarer''s Stardust'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZKS1016_I_SDUST_VH', element: 'StardustId' } }]
  OtherStardustId : sysuuid_x16;
}
