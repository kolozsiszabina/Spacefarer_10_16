CLASS zks1016_cl_trading DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES ty_amount TYPE zks1016_t_sdust-value.

    CONSTANTS: BEGIN OF gc_role,
                 buyer  TYPE c LENGTH 1 VALUE 'B',
                 seller TYPE c LENGTH 1 VALUE 'S',
               END OF gc_role.

    METHODS:
      buy IMPORTING iv_buyer       TYPE sysuuid_x16
                    iv_seller      TYPE sysuuid_x16
                    iv_stardust_id TYPE sysuuid_x16
          RAISING   zks1016_cx_trading,

      sell IMPORTING iv_seller      TYPE sysuuid_x16
                     iv_buyer       TYPE sysuuid_x16
                     iv_stardust_id TYPE sysuuid_x16
           RAISING   zks1016_cx_trading,

      exchange IMPORTING iv_spacefarer1  TYPE sysuuid_x16
                         iv_spacefarer2  TYPE sysuuid_x16
                         iv_stardust_id1 TYPE sysuuid_x16
                         iv_stardust_id2 TYPE sysuuid_x16
               RAISING   zks1016_cx_trading,

      calculate_price IMPORTING iv_stardust_id      TYPE sysuuid_x16
                                iv_spacefarer       TYPE sysuuid_x16
                                iv_role             TYPE c
                      RETURNING VALUE(rv_new_price) TYPE ty_amount
                      RAISING   zks1016_cx_trading.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES tt_uuid TYPE STANDARD TABLE OF sysuuid_x16 WITH EMPTY KEY.

    DATA mt_locks TYPE STANDARD TABLE OF REF TO if_abap_lock_object WITH EMPTY KEY.

    METHODS:
      get_owner IMPORTING iv_stardust_id  TYPE sysuuid_x16
                RETURNING VALUE(rv_owner) TYPE sysuuid_x16,

      get_collection IMPORTING iv_stardust_id          TYPE sysuuid_x16
                     RETURNING VALUE(rv_collection_id) TYPE sysuuid_x16,

      update_stardust IMPORTING iv_new_owner   TYPE sysuuid_x16
                                iv_stardust_id TYPE sysuuid_x16
                      RAISING   zks1016_cx_trading,

      transfer_transactions IMPORTING iv_buyer       TYPE sysuuid_x16
                                      iv_seller      TYPE sysuuid_x16
                                      iv_stardust_id TYPE sysuuid_x16
                            RAISING   zks1016_cx_trading,

      get_or_create_stcollection IMPORTING iv_spacefarer          TYPE sysuuid_x16
                                 RETURNING VALUE(rv_stcollection) TYPE sysuuid_x16
                                 RAISING   zks1016_cx_trading,

      lock_spacefarers IMPORTING iv_spacefarer1 TYPE sysuuid_x16
                                 iv_spacefarer2 TYPE sysuuid_x16
                       RAISING   zks1016_cx_trading,
      release_locks.

ENDCLASS.



CLASS zks1016_cl_trading IMPLEMENTATION.

  METHOD buy.

    "get the current owner of the stardust
    DATA(lv_owner) = get_owner( iv_stardust_id ).

    IF lv_owner IS INITIAL.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Stardust not found or has no owner' ).
    ENDIF.

    "buyer is initial/buyer and owner is the same -> exception
    IF iv_buyer IS INITIAL OR iv_buyer = lv_owner.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Invalid buyer' ).
    ENDIF.

    "if all condition matched -> trade the stardust
    transfer_transactions( iv_buyer = iv_buyer iv_seller = iv_seller iv_stardust_id = iv_stardust_id ).

  ENDMETHOD.


  METHOD sell.

    "get the current owner of the stardust
    DATA(lv_owner) = get_owner( iv_stardust_id ).

    IF lv_owner IS INITIAL OR lv_owner <> iv_seller. "seller is initial/seller and owner is the same -> exception
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'The seller does not own this Stardust' ).
    ENDIF.

    "if all condition matched -> trade the stardust
    transfer_transactions( iv_buyer = iv_buyer iv_seller = iv_seller iv_stardust_id = iv_stardust_id ).

  ENDMETHOD.


  METHOD exchange.

    "if exchanger spacerares are the same or starusts are the same -> exeption
    IF iv_spacefarer1 = iv_spacefarer2 OR iv_stardust_id1 = iv_stardust_id2.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Invalid exchange' ).
    ENDIF.

    "lock spacefarers to prevent paralell action
    lock_spacefarers( iv_spacefarer1 = iv_spacefarer1 iv_spacefarer2 = iv_spacefarer2 ).

    TRY.

        "get the current owner of the stardust
        DATA(lv_owner1) = get_owner( iv_stardust_id1 ).
        DATA(lv_owner2) = get_owner( iv_stardust_id2 ).

        "chack owners match
        IF lv_owner1 <> iv_spacefarer1 OR lv_owner2 <> iv_spacefarer2.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Owner does not match, exchange not possible' ).
        ENDIF.

        "validate if stardust has collection
        IF get_collection( iv_stardust_id1 ) IS INITIAL OR get_collection( iv_stardust_id2 ) IS INITIAL.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Stardust has no collection' ).
        ENDIF.

        "if all condition matched -> swap the owners of the two stardusts
        update_stardust( iv_stardust_id = iv_stardust_id1
                         iv_new_owner   = iv_spacefarer2 ).

        update_stardust( iv_stardust_id = iv_stardust_id2
                         iv_new_owner   = iv_spacefarer1 ).

      CLEANUP.
        "release lock
        release_locks( ).
    ENDTRY.

    CLEAR mt_locks.

  ENDMETHOD.


  METHOD get_collection.

    " the collection ID of the Stardust
    SELECT SINGLE collection_id FROM zks1016_t_sdust
      WHERE stardust_id = @iv_stardust_id
      INTO @rv_collection_id.

  ENDMETHOD.


  METHOD get_owner.

    "get the spacefarer of the collection
    SELECT SINGLE collection~spacefarer_id
      FROM zks1016_t_sdust AS stardust
      INNER JOIN zks1016_t_sdustc AS collection ON collection~stardust_coll_id = stardust~collection_id
      WHERE stardust~stardust_id = @iv_stardust_id
      INTO @rv_owner.

  ENDMETHOD.


  METHOD update_stardust.

    "the new owner's collection -> create collection if owner is beginner
    DATA(lv_new_collection) = get_or_create_stcollection( iv_new_owner ).

    "update owner of the collection
    UPDATE zks1016_t_sdust SET collection_id = @lv_new_collection
      WHERE stardust_id = @iv_stardust_id.

    "if update failed -> exeption
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Stardust could not be updated' ).
    ENDIF.

  ENDMETHOD.


  METHOD calculate_price.

    "get original price
    SELECT SINGLE value FROM zks1016_t_sdust
      WHERE stardust_id = @iv_stardust_id
      INTO @DATA(lv_original_price).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Stardust not found' ).
    ENDIF.

    "get reputation
    SELECT SINGLE reputation FROM zks1016_t_sfarer
      WHERE spacefarer_id = @iv_spacefarer
      INTO @DATA(lv_reputation).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Spacefarer not found' ).
    ENDIF.

    "every 5 reputation away from 30 is 1%
    DATA(lv_steps) = abs( lv_reputation - 30 ) DIV 5.
    DATA(lv_above) = xsdbool( lv_reputation > 30 ).

    "calculate percentage based on role
    DATA lv_percent TYPE i.
    CASE iv_role.
      WHEN gc_role-buyer.
        lv_percent = COND #( WHEN lv_above = abap_true THEN 100 - lv_steps ELSE 100 + lv_steps ).
      WHEN gc_role-seller.
        lv_percent = COND #( WHEN lv_above = abap_true THEN 100 + lv_steps ELSE 100 - lv_steps ).
      WHEN OTHERS.
        RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Invalid role' ).
    ENDCASE.

    "the price can never become negative
    rv_new_price = lv_original_price * nmax( val1 = 0 val2 = lv_percent ) / 100.

  ENDMETHOD.


  METHOD transfer_transactions.

    "buyer is initial/buyer and seller is the same -> exception
    IF iv_buyer IS INITIAL OR iv_buyer = iv_seller.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Invalid buyer' ).
    ENDIF.

    "lock
    lock_spacefarers( iv_spacefarer1 = iv_buyer iv_spacefarer2 = iv_seller ).

    TRY.

        "if seller does not own stardust -> exeption
        IF get_owner( iv_stardust_id ) <> iv_seller.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'The seller does not own this Stardust' ).
        ENDIF.

        "get buyer credits
        SELECT SINGLE credits FROM zks1016_t_sfarer
          WHERE spacefarer_id = @iv_buyer
          INTO @DATA(lv_buyer_credits).
        IF sy-subrc <> 0.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Buyer not found' ).
        ENDIF.

        "calculate buyer and seller credits
        DATA(lv_to_pay) = calculate_price( iv_stardust_id = iv_stardust_id
                                           iv_spacefarer  = iv_buyer
                                           iv_role        = gc_role-buyer ).

        DATA(lv_to_receive) = calculate_price( iv_stardust_id = iv_stardust_id
                                               iv_spacefarer  = iv_seller
                                               iv_role        = gc_role-seller ).

        "check if buyer has enough credits, if not -> exeption
        IF lv_buyer_credits < lv_to_pay.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Not enough Credits' ).
        ENDIF.

        "change owner of the stardust
        update_stardust( iv_stardust_id = iv_stardust_id
                         iv_new_owner   = iv_buyer ).

        "update buyer credits based on transaction
        UPDATE zks1016_t_sfarer SET credits = credits - @lv_to_pay WHERE spacefarer_id = @iv_buyer.
        IF sy-subrc <> 0.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Buyer credits could not be updated' ).
        ENDIF.

        "update seller credits based on transaction
        UPDATE zks1016_t_sfarer SET credits = credits + @lv_to_receive WHERE spacefarer_id = @iv_seller.
        IF sy-subrc <> 0.
          RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Seller credits could not be updated' ).
        ENDIF.

      CLEANUP.
        "unlock
        release_locks( ).
    ENDTRY.

    CLEAR mt_locks.

  ENDMETHOD.


  METHOD get_or_create_stcollection.

    "get the collection ID by spacefarer
    SELECT SINGLE stardust_coll_id FROM zks1016_t_sdustc
      WHERE spacefarer_id = @iv_spacefarer
      INTO @rv_stcollection.

    "if found -> return
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    "create collection if collection is not exist
    TRY.
        rv_stcollection = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'UUID generation failed' ).
    ENDTRY.

    INSERT zks1016_t_sdustc FROM @( VALUE #( stardust_coll_id   = rv_stcollection
                                            spacefarer_id      = iv_spacefarer
                                            stardust_coll_name = 'Stardust collection' ) ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Stardust collection could not be created' ).
    ENDIF.

  ENDMETHOD.


  METHOD lock_spacefarers.

    "ascending UUID order prevents deadlocks
    DATA(lt_uuids) = VALUE tt_uuid( ( iv_spacefarer1 ) ( iv_spacefarer2 ) ).

    SORT lt_uuids.
    DELETE ADJACENT DUPLICATES FROM lt_uuids.

    TRY.
        LOOP AT lt_uuids INTO DATA(lv_uuid).
          DATA(lo_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZKS1016_SFARER' ).
          " default scope: the lock is released by COMMIT WORK / ROLLBACK WORK
          lo_lock->enqueue( it_parameter = VALUE #( ( name  = 'SPACEFARER_ID'
                                                      value = REF #( lv_uuid ) ) ) ).
          APPEND lo_lock TO mt_locks.
        ENDLOOP.
      CATCH cx_abap_foreign_lock cx_abap_lock_failure.
        release_locks( ).
        RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Spacefarer is being used by someone else, try again later' ).
    ENDTRY.

  ENDMETHOD.


  METHOD release_locks.

    LOOP AT mt_locks INTO DATA(lo_lock).
      TRY.
          lo_lock->dequeue( ).
        CATCH cx_abap_lock_failure.
      ENDTRY.
    ENDLOOP.
    CLEAR mt_locks.

  ENDMETHOD.

ENDCLASS.
