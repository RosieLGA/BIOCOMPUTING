paste A.txt B.txt > C.txt
paste <(head -n 6 C.txt) <(grep -i "^[B,E]" words.txt | head -n 6)
paste <(head -n 6 A.txt) <(cat story.txt | tr "." "\n" | head -n 6)
