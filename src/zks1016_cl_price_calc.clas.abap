CLASS zks1016_cl_price_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES ty_amount TYPE zks1016_t_sdust-value.

    CONSTANTS: BEGIN OF gc_role,
                 buyer  TYPE c LENGTH 1 VALUE 'B',
                 seller TYPE c LENGTH 1 VALUE 'S',
               END OF gc_role.

    CONSTANTS: gc_neutral_reputation TYPE i VALUE 30,
               gc_reputation_step    TYPE i VALUE 5.

    CLASS-METHODS calculate
      IMPORTING iv_value        TYPE ty_amount
                iv_reputation   TYPE int2
                iv_role         TYPE c
      RETURNING VALUE(rv_price) TYPE ty_amount
      RAISING   zks1016_cx_trading.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zks1016_cl_price_calc IMPLEMENTATION.

  METHOD calculate.

    "every 5 reputation away from 30 is 1 percent
    DATA(lv_steps) = abs( iv_reputation - gc_neutral_reputation ) DIV gc_reputation_step.
    DATA(lv_above) = xsdbool( iv_reputation > gc_neutral_reputation ).

    "buyer above 30 / seller below 30 -> less, otherwise more
    DATA lv_percent TYPE i.
    CASE iv_role.
      WHEN gc_role-buyer.
        lv_percent = COND #( WHEN lv_above = abap_true THEN 100 - lv_steps ELSE 100 + lv_steps ).
      WHEN gc_role-seller.
        lv_percent = COND #( WHEN lv_above = abap_true THEN 100 + lv_steps ELSE 100 - lv_steps ).
      WHEN OTHERS.
        RAISE EXCEPTION NEW zks1016_cx_trading( iv_text = 'Invalid trading role' ).
    ENDCASE.

    "the price can never become negative
    rv_price = iv_value * nmax( val1 = 0 val2 = lv_percent ) / 100.

  ENDMETHOD.

ENDCLASS.
