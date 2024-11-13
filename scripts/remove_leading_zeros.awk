#!/usr/bin/awk -f

function number(x)   { return x+0 }
function is_number(x)   { return number(x) == x }

BEGIN {
    # FS = ","
    OFS = ORS = ""
}

# NR == 1 { print $0 "\n" }

# NR > 1 {}
{
    delim = ""
    for (i = 1; i <= NF; i++) {
        if ($i == "") {
            print delim $i
        }
        else if (is_number($i)) {
            print delim number($i)
        }
        else {
            gsub(/"/, "\"\"", $i)
            print delim "\"" $i "\""
        }
        delim = ","
    }
    print "\n"
}