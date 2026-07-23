_: let

  inherit (builtins)
    elemAt
    genList
    length
    ;

  spdxLicenses = let
    generated = import ./generated;
  in {
    licenseListVersion = elemAt generated 0;
    releaseDate = elemAt generated 1;
    licenses =
      genList (i: let
        licenseIndex = (i * 4) + 2;
        licenseId = elemAt generated (licenseIndex + 1);
        optTable = elemAt generated licenseIndex;
      in {
        reference = "https://spdx.org/licenses/${licenseId}.html";
        isDeprecatedLicenseId = optTable.a or false;
        detailsUrl = "https://spdx.org/licenses/${licenseId}.json";
        referenceNumber = i;
        name = elemAt generated (licenseIndex + 2);
        inherit licenseId;
        seeAlso = elemAt generated (licenseIndex + 3);
        isOsiApproved = optTable.b or false;
        isFsfLibre = optTable.c or null;
      }) ((length generated - 2) / 4);
  };

in {
  inherit
    spdxLicenses
    ;
}
