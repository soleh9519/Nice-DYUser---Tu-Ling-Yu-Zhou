#!/bin/bash

# Array of all 9 files
files=(
    "7508576300370595099.mp3"
    "7512397212559740169.mp3"
    "7521693621129645321.mp3"
    "7680165065328315690.mp3"
    "7680164185061215530.mp3"
    "7680031427819244826.mp3"
    "7680030547673910582.mp3"
    "7679391932635827475.mp3"
    "7679389777891691776.mp3"
)

# Helper function to format seconds into MM:SS.mmm
format_time() {
    awk -v s="$1" 'BEGIN {
        m = int(s / 60);
        sec = s % 60;
        printf "%02d:%06.3f", m, sec;
    }'
}

# Generate a 3-second silent snippet helper file once
ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t 3 silence.mp3 -v error

# Loop through the files in chunks of 3
for ((i=0; i<${#files[@]}; i+=3)); do
    f1="${files[i]}"
    f2="${files[i+1]}"
    f3="${files[i+2]}"
    
    out_name="抖音A_${f1%.mp3}_${f2%.mp3}_${f3%.mp3}"
    echo "Processing Group $(( (i/3) + 1 )): ${out_name}"

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

    # 4. Create temporary list file for concatenation
    cat << EOF > filelist.txt
file '$f1'
file 'silence.mp3'
file '$f2'
file 'silence.mp3'
file '$f3'
EOF

    # 5. Run FFmpeg concat demuxer
    ffmpeg -y -f concat -safe 0 -i filelist.txt -c:a libmp3lame -b:a 320k "${out_name}.mp3" -v error

    # 6. Clean up temporary list file for this loop
    rm filelist.txt
done

# Clean up global silence helper
rm silence.mp3

echo "All 3 groups processed successfully!"


# https://github.com/soleh9519/Nice-DYUser---Tu-Ling-Yu-Zhou/raw/refs/heads/TurboScribe-1/抖音A_7508576300370595099_7512397212559740169_7521693621129645321.mp3
# https://github.com/soleh9519/Nice-DYUser---Tu-Ling-Yu-Zhou/raw/refs/heads/TurboScribe-1/抖音A_7680030547673910582_7679391932635827475_7679389777891691776.mp3
# https://github.com/soleh9519/Nice-DYUser---Tu-Ling-Yu-Zhou/raw/refs/heads/TurboScribe-1/抖音A_7680165065328315690_7680164185061215530_7680031427819244826.mp3