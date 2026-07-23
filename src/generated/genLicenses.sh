#! /bin/sh

command -v "jq" >/dev/null 2>&1 || {
	printf "command \`jq\` missing"
	exit 1
}

spdxLicenses=$(curl -sSf "https://spdx.org/licenses/licenses.json")

jq -r -n '
	[ inputs[] ] as $stream
	| "let "
		+ "h=\"https://\";"
		+ "l=\"License\";"
		+ "s=\"license\";"
		+ "g=\"${h}github.com/\";"
		+ "o=\"${h}opensource.org/\";"
		+ "t=true;"
		+ "f=false;"
		+ "n=null;"
		+ "in["
	| "\(.)\"\($stream[0])\" "
	| "\(.)\"\($stream[2])\" "
	| . + (
	    [
	        $stream[1][] as $item
	        | "{"
	        	+ ($item.isDeprecatedLicenseId | if . == true then "a=t;" elif . == false then "" else "a=n;" end)
	        	+ ($item.isFsfLibre | if . == true then "b=t;" elif . == false then "b=f;" else "" end)
	        	+ ($item.isOsiApproved | if . == true then "c=t;" elif . == false then "" else "c=n;" end)
	        	+ "} "
	        	+ ($item.licenseId | @json) + " "
				+ ($item.name | gsub("License"; "${l}") | @json) + " ["
				+ ([ $item.seeAlso[]?
					| gsub("https://github.com/"; "${g}")
					| gsub("https://opensource.org/"; "${o}")
					| gsub("https://"; "${h}")
					| gsub("license"; "${s}")
					| @json
				] | join(" "))
				+ "]"
	    ]
	    | join(" ")
	)
	| "\(.)]"
' \
	<(printf "%s" "$spdxLicenses")
