CLASS zks1016_cx_trading DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_text  TYPE string OPTIONAL
                previous LIKE previous OPTIONAL.

    METHODS get_text REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_text TYPE string.
ENDCLASS.



CLASS zks1016_cx_trading IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).

    mv_text = iv_text.

  ENDMETHOD.

  METHOD get_text.

    result = mv_text.

  ENDMETHOD.

ENDCLASS.
