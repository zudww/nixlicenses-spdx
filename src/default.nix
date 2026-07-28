_: let

  inherit (builtins)
    elemAt
    genList
    length
    listToAttrs
    ;

  raw = import ./generated;
  licenseCount = (length raw - 2) / 4;

  licenses = genList (i: let
    licenseIndex = (i * 4) + 2;
    licenseId = elemAt raw (licenseIndex + 1);
    optTable = elemAt raw licenseIndex;
  in {
    reference = "https://spdx.org/licenses/${licenseId}.html";
    isDeprecatedLicenseId = optTable.a or false;
    detailsUrl = "https://spdx.org/licenses/${licenseId}.json";
    referenceNumber = i;
    name = elemAt raw (licenseIndex + 2);
    inherit licenseId;
    seeAlso = elemAt raw (licenseIndex + 3);
    isOsiApproved = optTable.b or false;
    isFsfLibre = optTable.c or null;
  }) licenseCount;

  schema = {
    licenseListVersion = elemAt raw 0;
    releaseDate = elemAt raw 1;
    inherit licenses;
  };

  index.byLicenseId =
    listToAttrs (
      genList (
        i: let
          license = builtins.elemAt licenses i;
        in {
          name = license.licenseId;
          value = license;
        }
      ) licenseCount
    );

  index.byName =
    listToAttrs (
      genList (
        i: let
          license = builtins.elemAt licenses i;
        in {
          name = license.name;
          value = license;
        }
      ) licenseCount
    );

in {
  inherit
    raw
    index
    schema
    licenses
    ;
}
