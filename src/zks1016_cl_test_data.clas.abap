CLASS zks1016_cl_test_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zks1016_cl_test_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    "clean up tables
    DELETE FROM zks1016_t_sdust.
    DELETE FROM zks1016_t_sdustc.
    DELETE FROM zks1016_t_sfarer.
    DELETE FROM zks1016_t_factp.
    DELETE FROM zks1016_t_fact.
    DELETE FROM zks1016_t_som.
    DELETE FROM zks1016_t_color.
    DELETE FROM zks1016_t_planet.
    DELETE FROM zks1016_d_sfarer.
    DELETE FROM zks1016_d_sdust.
    DELETE FROM zks1016_d_sdustc.

    "fixed planet data
    INSERT zks1016_t_planet FROM TABLE @( VALUE #(
      ( planet_id = 'EARTH'  planet_name = 'Earth'  suit_color = 'BLUE'   )
      ( planet_id = 'MARS'   planet_name = 'Mars'   suit_color = 'RED'    )
      ( planet_id = 'VENUS'  planet_name = 'Venus'  suit_color = 'YELLOW' )
      ( planet_id = 'KEPLER' planet_name = 'Kepler' suit_color = 'GREEN'  ) ) ).

    "fixed colors
    INSERT zks1016_t_color FROM TABLE @( VALUE #(
      ( color_id = 'RED'    color_description = 'Red'    )
      ( color_id = 'BLUE'   color_description = 'Blue'   )
      ( color_id = 'GREEN'  color_description = 'Green'  )
      ( color_id = 'VIOLET' color_description = 'Violet' )
      ( color_id = 'GOLD'   color_description = 'Gold'   ) ) ).

    "fixed state of matters
    INSERT zks1016_t_som FROM TABLE @( VALUE #(
      ( matter_id = 'SOLID'  matter_description = 'Solid'  )
      ( matter_id = 'LIQUID' matter_description = 'Liquid' )
      ( matter_id = 'GAS'    matter_description = 'Gas'    )
      ( matter_id = 'PLASMA' matter_description = 'Plasma' ) ) ).

    "fixed faction
    INSERT zks1016_t_fact FROM TABLE @( VALUE #(
      ( faction_id = 'NAV'    faction_description = 'Navigation Guild'   )
      ( faction_id = 'TRADE'  faction_description = 'Stardust Trading'   )
      ( faction_id = 'REFINE' faction_description = 'Refinement Corps'   ) ) ).

    "fixed position
    INSERT zks1016_t_factp FROM TABLE @( VALUE #(
      ( faction_id = 'NAV'    position_id = 'CADET'   position_description = 'Cadet'   )
      ( faction_id = 'NAV'    position_id = 'PILOT'   position_description = 'Pilot'   )
      ( faction_id = 'TRADE'  position_id = 'BROKER'  position_description = 'Broker'  )
      ( faction_id = 'TRADE'  position_id = 'AUDITOR' position_description = 'Auditor' )
      ( faction_id = 'REFINE' position_id = 'SMELTER' position_description = 'Smelter' )
      ( faction_id = 'REFINE' position_id = 'CHIEF'   position_description = 'Chief'   ) ) ).

    "create spacefarer id's
    TRY.
        DATA(lv_luna) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_max)  = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_nova) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_rex)  = cl_system_uuid=>create_uuid_x16_static( ).
        data(lv_syuser) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_coll_luna) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_coll_max)  = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_coll_rex)  = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_coll_syuser)  = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_sd1) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_sd2) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_sd3) = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error INTO DATA(lx).
        out->write( lx->get_text( ) ).
        RETURN.
    ENDTRY.

    "create spacefareres -> skill + reputation is always stay below 99
    INSERT zks1016_t_sfarer FROM TABLE @( VALUE #(
      ( spacefarer_id = lv_luna name = 'Luna' wormhole_nav_skill = 60 reputation = 35
        origin_planet = 'EARTH'  credits = '5000.00'  credits_currency = 'EUR'
        faction_id = 'NAV'   position_id = 'PILOT'   )
      ( spacefarer_id = lv_max  name = 'Max'  wormhole_nav_skill = 40 reputation = 50
        origin_planet = 'MARS'   credits = '3000.00'  credits_currency = 'EUR'
        faction_id = 'TRADE' position_id = 'BROKER'  )
      ( spacefarer_id = lv_nova name = 'Nova' wormhole_nav_skill = 10 reputation = 12
        origin_planet = 'VENUS'  credits = '800.00'   credits_currency = 'EUR'
        faction_id = 'REFINE' position_id = 'SMELTER' )
      ( spacefarer_id = lv_rex  name = 'Rex'  wormhole_nav_skill = 80 reputation = 15
        origin_planet = 'KEPLER' credits = '10000.00' credits_currency = 'EUR'
        faction_id = 'TRADE' position_id = 'AUDITOR' )
        ( spacefarer_id = lv_syuser  name = sy-uname  wormhole_nav_skill = 70 reputation = 15
        origin_planet = 'KEPLER' credits = '100000.00' credits_currency = 'EUR'
        faction_id = 'TRADE' position_id = 'AUDITOR' ) ) ).

    "create stardust collection -> nova and syuser are beginner, they don't own collections
    INSERT zks1016_t_sdustc FROM TABLE @( VALUE #(
      ( stardust_coll_id = lv_coll_luna spacefarer_id = lv_luna stardust_coll_name = 'Luna treasures' )
      ( stardust_coll_id = lv_coll_max  spacefarer_id = lv_max  stardust_coll_name = 'Max stash'      )
      ( stardust_coll_id = lv_coll_rex  spacefarer_id = lv_rex  stardust_coll_name = 'Rex (empty)'    ) ) ).

    "create stardusts
    INSERT zks1016_t_sdust FROM TABLE @( VALUE #(
      ( stardust_id = lv_sd1 collection_id = lv_coll_luna color_id = 'BLUE'
        weight = '2.000' weight_uom = 'KG' matter_id = 'SOLID'
        value = '500.00' value_currency = 'EUR' )
      ( stardust_id = lv_sd2 collection_id = lv_coll_luna color_id = 'GOLD'
        weight = '1.000' weight_uom = 'KG' matter_id = 'PLASMA'
        value = '900.00' value_currency = 'EUR' )
      ( stardust_id = lv_sd3 collection_id = lv_coll_max color_id = 'RED'
        weight = '3.500' weight_uom = 'KG' matter_id = 'LIQUID'
        value = '1000.00' value_currency = 'EUR' ) ) ).

    COMMIT WORK AND WAIT.

*    " ---------- print the UUIDs for later tests ----------
    out->write( |Luna  { lv_luna }| ).
    out->write( |Max   { lv_max }| ).
    out->write( |Nova  { lv_nova }  (beginner, no collection)| ).
    out->write( |Rex   { lv_rex }  (empty collection)| ).
    out->write( |{ sy-uname }  { lv_syuser }  (beginner, no collection)| ).
    out->write( |Stardust 1 (Luna, blue, 500)   { lv_sd1 }| ).
    out->write( |Stardust 2 (Luna, gold, 900)   { lv_sd2 }| ).
    out->write( |Stardust 3 (Max, red, 1000)    { lv_sd3 }| ).
  ENDMETHOD.
ENDCLASS.
