start_time=$(date +%s.%3N)
$@
end_time=$(date +%s.%3N)
elapsed=$(echo "scale=3; $end_time - $start_time" | bc)
echo Elapsed time: $elapsed s
