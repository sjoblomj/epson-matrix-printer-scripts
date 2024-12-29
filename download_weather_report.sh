#!/bin/bash

# Get the weather report, and turn it into a 2x2 grid report rather than a 1x4 grid report.
curl -s wttr.in/Varberg\?TM | awk '
BEGIN{
  FS = "│";
  date = "";
  delete headers[""];
  delete content[""];
  is_reading_header = 0;
}
{
  if ($0 ~ /^Weather report: /) {
    print $0;
  }
  if ($0 ~ /^[ ┌─┐├─┼┤]+$/) {
    next;
  }
  pos = match($0, /^[┌─┬┤ ]+([A-Za-z]{3} [0-9]{2} [a-zA-Z]{3})[ ├─┬┐]+$/, arr);
  if (pos != 0) {
    date = arr[1];
    is_reading_header = 1;
    next;
  }
  if (is_reading_header) {
    gsub(/^│[ ]+/, "");
    gsub(/[ ]+│$/, "");
    gsub(/[└─┬┘]+/, "");
    gsub(/[ │]+/, " ");
    split($0, headers, " ");
    is_reading_header = 0;
    for (i = 1; i <= length(headers); i++) {
      content[i] = "";
    }
    next;
  }
  if (!is_reading_header) {
    content[1] = content[1] $2 "\n";
    content[2] = content[2] $3 "\n";
    content[3] = content[3] $4 "\n";
    content[4] = content[4] $5 "\n";
  }
  if ($0 ~ /^[└─┴┘]+$/) {
    print "                        ┌─────────────┐";
    print "┌───────────────────────┤  "  date  " ├───────────────────────┐";
    print "│            " headers[1] "    └──────┬──────┘      " headers[2] "             │";
    print "├──────────────────────────────┼──────────────────────────────┤";

    len = split(content[1], c1, "\n");
    split(content[2], c2, "\n");
    for (i = 1; i < len - 1; i++) {
      print "│" c1[i] "│" c2[i] "│";
    }

    print "├──────────────────────────────┼──────────────────────────────┤";
    print "│            " headers[3] "           │             " headers[4] "            │";
    print "├──────────────────────────────┼──────────────────────────────┤";

    len = split(content[3], c3, "\n");
    split(content[4], c4, "\n");
    for (i = 1; i < len - 1; i++) {
      print "│" c3[i] "│" c4[i] "│";
    }
    print "└──────────────────────────────┴──────────────────────────────┘";
  }
}
'
