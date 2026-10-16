CLASS zks1016_cl_trading_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zks1016_cl_trading_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

*    MODIFY ENTITIES OF zks1016_i_sfarer
*          ENTITY Spacefarer
*            CREATE FIELDS ( Name WormholeNavSkill Reputation OriginPlanet FactionId )
*            WITH VALUE #( ( %cid = 'C1' Name = 'Test' WormholeNavSkill = 10
*                            Reputation = 10 OriginPlanet = 'EARTH' FactionId = 'NAV' ) )
*          MAPPED   DATA(mapped)
*          FAILED   DATA(failed)
*          REPORTED DATA(reported).
*
*    out->write( |mapped: { lines( mapped-spacefarer ) }, failed: { lines( failed-spacefarer ) }| ).
*
*    COMMIT WORK AND WAIT.

    DATA: lv_seller TYPE sysuuid_x16,
          lv_buyer TYPE sysuuid_x16,
          lv_sd1  TYPE sysuuid_x16.

    " seller
    SELECT SINGLE spacefarer_id
      FROM zks1016_t_sfarer
      WHERE name = 'Luna'
      INTO @lv_seller.

    " buyer
    SELECT SINGLE spacefarer_id
      FROM zks1016_t_sfarer
      WHERE name = 'Szabina'
      INTO @lv_buyer.

    IF lv_seller IS INITIAL OR lv_buyer IS INITIAL.
      out->write( 'ERROR: seller or buyer not found.' ).
      RETURN.
    ENDIF.

    " Find seller's blue Stardust
    SELECT SINGLE s~stardust_id
      FROM zks1016_t_sdust AS s
      INNER JOIN zks1016_t_sdustc AS c
        ON c~stardust_coll_id = s~collection_id
      WHERE "c~spacefarer_id = @lv_seller
*        AND
s~color_id = 'BLUE'
      INTO @lv_sd1.

    IF lv_sd1 IS INITIAL.
      out->write(
        'ERROR: seller no longer owns a blue Stardust. Reset test data first.' ).
      RETURN.
    ENDIF.

    out->write( 'Starting BUY test...' ).
    out->write( |seller: { lv_seller }| ).
    out->write( |buyer: { lv_buyer }| ).
    out->write( |Stardust: { lv_sd1 }| ).

    " Set a breakpoint on the next line
    TRY.
        NEW zks1016_cl_trading( )->buy(
          iv_buyer       = lv_buyer
          iv_seller      = lv_seller
          iv_stardust_id = lv_sd1 ).

        out->write( 'BUY completed without an exception.' ).

      CATCH zks1016_cx_trading INTO DATA(lx_trading).
        out->write(
          |BUY failed: { lx_trading->get_text( ) }| ).
        RETURN.
    ENDTRY.

    " Verify the new owner
    SELECT SINGLE c~spacefarer_id
      FROM zks1016_t_sdust AS s
      INNER JOIN zks1016_t_sdustc AS c
        ON c~stardust_coll_id = s~collection_id
      WHERE s~stardust_id = @lv_sd1
      INTO @DATA(lv_new_owner).

    IF lv_new_owner = lv_buyer.
      out->write( 'PASS: buyer now owns the Stardust.' ).
    ELSE.
      out->write( 'FAIL: Stardust owner was not updated.' ).
    ENDIF.

    COMMIT WORK AND WAIT.

  ENDMETHOD.

ENDCLASS.
