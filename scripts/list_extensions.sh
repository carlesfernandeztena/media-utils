find . -path ./.git -prune -false -o  -type f | sed 's/.*\.//' |  grep -v "gitattributes" | sort | uniq -c
