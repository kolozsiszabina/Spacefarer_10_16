# ZKSZ_SPACEFARER – Spacefarer Adventure (RAP sample)

abapGit repository of the ABAP package `ZKSZ_SPACEFARER` (object prefix `ZKS1016_`):
a managed RAP business object with draft, OData V4 service and Fiori Elements UI annotations.

## Import (SAP BTP ABAP Environment / ADT)

1. Create package `ZKSZ_SPACEFARER` (superpackage `ZLOCAL`).
2. ADT: *Window → Show View → abapGit Repositories* → **Link** this repository to the package → **Pull**.
3. Open service binding `ZKS1016_SB_GAP` → **Publish**.
4. Run class `ZKS1016_CL_TEST_DATA` (F9) to fill the tables.
5. In the service binding select entity `Spacefarer` → **Preview**.
