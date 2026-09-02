217900 wget -O 7508576300370595099.mp3 https://sf6-cdn-tos.douyinstatic.com/obj/ies-music/7508576433149725459.mp3
177834 wget -O 7512397212559740169.mp3 https://sf11-cdn-tos.douyinstatic.com/obj/ies-music/7512397676344822565.mp3
342800 wget -O 7521693621129645321.mp3 https://sf6-cdn-tos.douyinstatic.com/obj/ies-music/7521693789488974619.mp3
605206 wget -O 7680165065328315690.mp3 https://sf11-cdn-tos.douyinstatic.com/obj/ies-music/7680165380207151918.mp3
551638 wget -O 7680164185061215530.mp3 https://sf11-cdn-tos.douyinstatic.com/obj/ies-music/7680164450250279743.mp3
549483 wget -O 7680031427819244826.mp3 https://sf11-cdn-tos.douyinstatic.com/obj/ies-music/7680031736192895786.mp3
595478 wget -O 7680030547673910582.mp3 https://sf6-cdn-tos.douyinstatic.com/obj/ies-music/7680030828478778131.mp3
572843 wget -O 7679391932635827475.mp3 https://sf6-cdn-tos.douyinstatic.com/obj/ies-music/7679392217257216810.mp3
554134 wget -O 7679389777891691776.mp3 https://sf6-cdn-tos.douyinstatic.com/obj/ies-music/7679390012558920489.mp3

sudo apt-get update && sudo apt-get install -y ffmpeg

ffmpeg  -i 7680031427819244826.mp3 -i 7680164185061215530.mp3 -i 7680165065328315690.mp3 \
-f lavfi -i anullsrc=r=44100:cl=stereo \
-filter_complex "[3:a]atrim=duration=3[s];[0:a][s][1:a][s][2:a]concat=n=5:v=0:a=1[outa]" \
-map "[outa]" "抖音A 7680031427819244826 7680164185061215530 7680165065328315690"