CLASS lhc_Spacefarer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: gc_initial_credits  TYPE zks1016_t_sfarer-credits VALUE '1000.00',
               gc_default_currency TYPE c LENGTH 5 VALUE 'EUR'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING
      keys REQUEST requested_authorizations FOR Spacefarer RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR Spacefarer RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Spacefarer RESULT result.

    METHODS validateSkillRep FOR VALIDATE ON SAVE
      IMPORTING keys FOR Spacefarer~validateSkillRep.

    METHODS setInitialCredits FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Spacefarer~setInitialCredits.


ENDCLASS.

CLASS lhc_Spacefarer IMPLEMENTATION.

  METHOD get_instance_authorizations.
    "set update, delete, edit action allowed
    result = VALUE #( FOR key IN keys
                      ( %tky    = key-%tky
                        %update      = if_abap_behv=>auth-allowed
                        %delete      = if_abap_behv=>auth-allowed
                        %action-Edit = if_abap_behv=>auth-allowed ) ).
  ENDMETHOD.


  METHOD get_global_authorizations.
    "set create action allowed
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance_features.

    "collections of the requested spacefarers
    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Spacefarer BY \_Collection
        FIELDS ( StardustCollId ) WITH CORRESPONDING #( keys )
        LINK DATA(lt_collection_link).

    "stardusts in these collections
    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY StardustCollection BY \_Stardust
        FIELDS ( StardustId ) WITH VALUE #( FOR ls_link IN lt_collection_link ( %tky = ls_link-target-%tky ) )
        LINK DATA(lt_stardust_link).

    LOOP AT keys INTO DATA(ls_key).

      DATA(lv_has_collection) = abap_false.
      DATA(lv_has_stardust)   = abap_false.

      "check if spacefarer has collection or stardust
      LOOP AT lt_collection_link INTO DATA(ls_collection_link)
           WHERE source-SpacefarerId = ls_key-SpacefarerId
             AND source-%is_draft    = ls_key-%is_draft.
        lv_has_collection = abap_true.
        IF line_exists( lt_stardust_link[ source-StardustCollId = ls_collection_link-target-StardustCollId
                                          source-%is_draft      = ls_collection_link-target-%is_draft ] ).
          lv_has_stardust = abap_true.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #( %tky               = ls_key-%tky
                      "only spacefarers without stardust can be deleted
                      %delete            = COND #( WHEN lv_has_stardust = abap_true
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled )
                      "one spacefarer can have only one stardust collection
                      %assoc-_Collection = COND #( WHEN lv_has_collection = abap_true
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled ) )
        TO result.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateSkillRep.

    "navigation + reputation cannat be more then 99

    "get reputation and navigation skill value
    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Spacefarer
      FIELDS ( WormholeNavSkill Reputation )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_spacefarer).

    LOOP AT lt_spacefarer INTO DATA(ls_spacefarer).
      "clear old messages of this validation
      APPEND VALUE #( %tky = ls_spacefarer-%tky %state_area = 'SKILLREP' )
        TO reported-spacefarer.

      "if reputation is under 0/summery of navigation skill and reputation is over 99 -> error
      DATA(lv_error) = COND string(
        WHEN ls_spacefarer-Reputation < 0
          THEN 'Reputation cannot be negative'
        WHEN ls_spacefarer-WormholeNavSkill + ls_spacefarer-Reputation >= 99
          THEN 'Navigation skill + reputation must stay below 99' ).

      IF lv_error IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_spacefarer-%tky ) TO failed-spacefarer.
        APPEND VALUE #( %tky        = ls_spacefarer-%tky
                        %state_area = 'SKILLREP'
                        %element-WormholeNavSkill = if_abap_behv=>mk-on
                        %element-Reputation       = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = lv_error ) )
          TO reported-spacefarer.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setinitialcredits.

    "every new spacefarer starts with the same amount of credits by defult
    MODIFY ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Spacefarer
        UPDATE FIELDS ( Credits CreditsCurrency )
        WITH VALUE #( FOR ls_key IN keys
                      ( %tky            = ls_key-%tky
                        Credits         = gc_initial_credits
                        CreditsCurrency = gc_default_currency ) ).

  ENDMETHOD.

ENDCLASS.


CLASS lhc_Stardust DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Stardust RESULT result.

    METHODS buyStardust FOR MODIFY
      IMPORTING keys FOR ACTION Stardust~buyStardust RESULT result.

    METHODS sellStardust FOR MODIFY
      IMPORTING keys FOR ACTION Stardust~sellStardust RESULT result.

    METHODS exchangeStardust FOR MODIFY
      IMPORTING keys FOR ACTION Stardust~exchangeStardust RESULT result.

    METHODS transfer
      IMPORTING iv_stardust_id  TYPE sysuuid_x16
                iv_buyer_id     TYPE sysuuid_x16
      RETURNING VALUE(rv_error) TYPE string.

    METHODS get_or_create_collection
      IMPORTING iv_spacefarer_id        TYPE sysuuid_x16
      RETURNING VALUE(rv_collection_id) TYPE sysuuid_x16.

ENDCLASS.

CLASS lhc_Stardust IMPLEMENTATION.

  METHOD get_instance_features.

    result = VALUE #( FOR ls_key IN keys
                      LET lv_fc = COND #( WHEN ls_key-%is_draft = if_abap_behv=>mk-on
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled ) IN
                      ( %tky                     = ls_key-%tky
                        %action-buyStardust      = lv_fc
                        %action-sellStardust     = lv_fc
                        %action-exchangeStardust = lv_fc ) ).

  ENDMETHOD.


  METHOD buyStardust.

    "the selected stardust is bought by the given buyer from its current owner
    LOOP AT keys INTO DATA(ls_key).

      DATA(lv_error) = transfer( iv_stardust_id = ls_key-StardustId
                                 iv_buyer_id    = ls_key-%param-BuyerId ).

      IF lv_error IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-stardust.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_error ) )
          TO reported-stardust.
      ENDIF.

    ENDLOOP.

    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Stardust
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky %param = ls_result ) ).

  ENDMETHOD.


  METHOD sellStardust.

    "the owner sells the selected stardust to the given buyer
    LOOP AT keys INTO DATA(ls_key).

      DATA(lv_error) = transfer( iv_stardust_id = ls_key-StardustId
                                 iv_buyer_id    = ls_key-%param-BuyerId ).

      IF lv_error IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-stardust.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_error ) )
          TO reported-stardust.
      ENDIF.

    ENDLOOP.

    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Stardust
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky %param = ls_result ) ).

  ENDMETHOD.


  METHOD exchangeStardust.

    "the selected stardust is swapped with another spacefarer's stardust
    LOOP AT keys INTO DATA(ls_key).

      READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
        ENTITY Stardust
          FIELDS ( CollectionId SpacefarerId )
          WITH VALUE #( ( StardustId = ls_key-StardustId                %is_draft = if_abap_behv=>mk-off )
                        ( StardustId = ls_key-%param-OtherStardustId    %is_draft = if_abap_behv=>mk-off ) )
          RESULT DATA(lt_stardust).

      "get owners of the exchanged stardusts
      DATA(ls_own)   = VALUE #( lt_stardust[ StardustId = ls_key-StardustId ] OPTIONAL ).
      DATA(ls_other) = VALUE #( lt_stardust[ StardustId = ls_key-%param-OtherStardustId ] OPTIONAL ).

      "get error message if exist
      DATA(lv_error) = COND string(
        WHEN ls_own-CollectionId IS INITIAL OR ls_other-CollectionId IS INITIAL
          THEN 'Stardust not found'
        WHEN ls_own-SpacefarerId = ls_other-SpacefarerId
          THEN 'Both Stardusts belong to the same Spacefarer' ).

      IF lv_error IS INITIAL.
        "change owners
        MODIFY ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
          ENTITY Stardust
            UPDATE FIELDS ( CollectionId )
            WITH VALUE #( ( StardustId   = ls_own-StardustId
                            %is_draft    = if_abap_behv=>mk-off
                            CollectionId = ls_other-CollectionId )
                          ( StardustId   = ls_other-StardustId
                            %is_draft    = if_abap_behv=>mk-off
                            CollectionId = ls_own-CollectionId ) )
          FAILED DATA(ls_failed).

        IF ls_failed IS NOT INITIAL.
          lv_error = 'Exchange failed - the other Spacefarer is probably being edited'.
        ENDIF.
      ENDIF.

      IF lv_error IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-stardust.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_error ) )
          TO reported-stardust.
      ENDIF.

    ENDLOOP.

    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Stardust
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky %param = ls_result ) ).

  ENDMETHOD.


  METHOD transfer.

    "the stardust and its current owner
    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Stardust
        FIELDS ( CollectionId SpacefarerId Value ValueCurrency )
        WITH VALUE #( ( StardustId = iv_stardust_id %is_draft = if_abap_behv=>mk-off ) )
        RESULT DATA(lt_stardust).

    IF lt_stardust IS INITIAL.
      rv_error = 'Stardust not found'.
      RETURN.
    ENDIF.

    DATA(ls_stardust)  = lt_stardust[ 1 ].
    DATA(lv_seller_id) = ls_stardust-SpacefarerId.

    "if buyer is empty or the buyer and the seller is the same -> error
    IF iv_buyer_id IS INITIAL OR iv_buyer_id = lv_seller_id.
      rv_error = 'Invalid buyer'.
      RETURN.
    ENDIF.

    "get reputation, credit and uom information of spacefarers
    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Spacefarer
        FIELDS ( Reputation Credits CreditsCurrency )
        WITH VALUE #( ( SpacefarerId = iv_buyer_id  %is_draft = if_abap_behv=>mk-off )
                      ( SpacefarerId = lv_seller_id %is_draft = if_abap_behv=>mk-off ) )
        RESULT DATA(lt_spacefarer).

    READ TABLE lt_spacefarer INTO DATA(ls_buyer) WITH KEY SpacefarerId = iv_buyer_id.
    IF sy-subrc <> 0.
      rv_error = 'Buyer not found'.
      RETURN.
    ENDIF.

    READ TABLE lt_spacefarer INTO DATA(ls_seller) WITH KEY SpacefarerId = lv_seller_id.
    IF sy-subrc <> 0.
      rv_error = 'Seller not found'.
      RETURN.
    ENDIF.

    "price calculation
    TRY.
        DATA(lv_to_pay) = zks1016_cl_price_calc=>calculate( iv_value      = ls_stardust-Value
                                                            iv_reputation = ls_buyer-Reputation
                                                            iv_role       = zks1016_cl_price_calc=>gc_role-buyer ).

        DATA(lv_to_receive) = zks1016_cl_price_calc=>calculate( iv_value      = ls_stardust-Value
                                                                iv_reputation = ls_seller-Reputation
                                                                iv_role       = zks1016_cl_price_calc=>gc_role-seller ).
      CATCH zks1016_cx_trading INTO DATA(lx_trading).
        rv_error = lx_trading->get_text( ).
        RETURN.
    ENDTRY.

    "check if buyer has enough credits
    IF ls_buyer-Credits < lv_to_pay.
      rv_error = |Not enough Credits (price: { lv_to_pay })|.
      RETURN.
    ENDIF.

    "get buyer collection ID, if buyer is a beginner -> create collection
    DATA(lv_buyer_collection) = get_or_create_collection( iv_buyer_id ).
    IF lv_buyer_collection IS INITIAL.
      rv_error = 'Stardust Collection of the buyer could not be created'.
      RETURN.
    ENDIF.

    "owner change of stardust + update credits balance for seller and buyer
    MODIFY ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Stardust
        UPDATE FIELDS ( CollectionId )
        WITH VALUE #( ( StardustId   = iv_stardust_id
                        %is_draft    = if_abap_behv=>mk-off
                        CollectionId = lv_buyer_collection ) )
      ENTITY Spacefarer
        UPDATE FIELDS ( Credits )
        WITH VALUE #( ( SpacefarerId = iv_buyer_id
                        %is_draft    = if_abap_behv=>mk-off
                        Credits      = ls_buyer-Credits - lv_to_pay )
                      ( SpacefarerId = lv_seller_id
                        %is_draft    = if_abap_behv=>mk-off
                        Credits      = ls_seller-Credits + lv_to_receive ) )
      FAILED DATA(ls_failed).

    IF ls_failed IS NOT INITIAL.
      rv_error = 'Trade failed'.
    ENDIF.

  ENDMETHOD.


  METHOD get_or_create_collection.

    "get spacefarer collection ID
    READ ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Spacefarer BY \_Collection
        FIELDS ( StardustCollId )
        WITH VALUE #( ( SpacefarerId = iv_spacefarer_id %is_draft = if_abap_behv=>mk-off ) )
        RESULT DATA(lt_collection).

    IF lt_collection IS NOT INITIAL.
      rv_collection_id = lt_collection[ 1 ]-StardustCollId.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zks1016_i_sfarer IN LOCAL MODE
      ENTITY Spacefarer
        CREATE BY \_Collection
        FIELDS ( StardustCollName )
        WITH VALUE #( ( SpacefarerId = iv_spacefarer_id
                        %is_draft    = if_abap_behv=>mk-off
                        %target      = VALUE #( ( %cid             = 'NEW_COLLECTION'
                                                  %is_draft        = if_abap_behv=>mk-off
                                                  StardustCollName = 'Stardust collection' ) ) ) )
      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed).

    IF ls_failed IS INITIAL AND ls_mapped-stardustcollection IS NOT INITIAL.
      rv_collection_id = ls_mapped-stardustcollection[ 1 ]-StardustCollId.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
