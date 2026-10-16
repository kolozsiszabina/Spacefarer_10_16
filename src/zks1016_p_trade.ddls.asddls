@EndUserText.label: 'Parameter for trade action'
define abstract entity zks1016_p_trade
{
  @EndUserText.label: 'Buyer'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZKS1016_C_SFARER', element: 'SpacefarerId' } }]
  BuyerId : sysuuid_x16;
}
