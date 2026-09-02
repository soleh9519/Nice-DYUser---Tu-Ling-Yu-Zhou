#!/bin/bash

f1="7680031427819244826.mp3"
f2="7680164185061215530.mp3"
f3="7680165065328315690.mp3"
out_name="抖音A 7680031427819244826 7680164185061215530 7680165065328315690"

# 1. Extract individual track durations
d1=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f1")
d2=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f2")
d3=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f3")

# 2. Calculate timeline boundaries using awk for float precision
eval $(awk -v d1="$d1" -v d2="$d2" -v d3="$d3" 'BEGIN {
    t1_start = 0; t1_end = d1;
    t2_start = d1 + 3; t2_end = t2_start + d2;
    t3_start = t2_end + 3; t3_end = t3_start + d3;
    printf "t1_start=%.3f; t1_end=%.3f;\n", t1_start, t1_end;
    printf "t2_start=%.3f; t2_end=%.3f;\n", t2_start, t2_end;
    printf "t3_start=%.3f; t3_end=%.3f;\n", t3_start, t3_end;
}')

# Helper function to format seconds into MM:SS.mmm
format_time() {
    awk -v s="$1" 'BEGIN {
        m = int(s / 60);
        sec = s % 60;
        printf "%02d:%06.3f", m, sec;
    }'
}

# 3. Write metadata to matching .txt file
txt_file="${out_name}.txt"
cat << EOF > "$txt_file"
Track 1: $f1
- Start: $(format_time $t1_start)
- End:   $(format_time $t1_end)
- Duration: ${d1}s

Track 2: $f2
- Start: $(format_time $t2_start)
- End:   $(format_time $t2_end)
- Duration: ${d2}s

Track 3: $f3
- Start: $(format_time $t3_start)
- End:   $(format_time $t3_end)
- Duration: ${d3}s
EOF

# 4. Generate a 3-second silent snippet helper file
ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t 3 silence.mp3 -v error

# 5. Create temporary list file for concatenation
cat << EOF > filelist.txt
file '$f1'
file 'silence.mp3'
file '$f2'
file 'silence.mp3'
file '$f3'
EOF

# 6. Run FFmpeg concat demuxer
ffmpeg -y -f concat -safe 0 -i filelist.txt -c:a libmp3lame -b:a 320k "${out_name}.mp3"

# 7. Clean up temporary files
rm silence.mp3 filelist.txt

echo "Done! Generated '${out_name}.mp3' and '${out_name}.txt'."