#!/bin/bash

# accepts the name of a fasta file as a positional argument and stores that filename in a variable
fasta_file=${1}

# calculate and stores total number of sequences and nucleotides

total_seq_nuc=$(seqtk size $fasta_file)
total_seq=$(echo "$total_seq_nuc" |cut -f1)
total_nuc=$(echo "$total_seq_nuc" |cut -f2)

# A table of sequence names and lengths (all seqs in file)

table=$(seqtk comp $fasta_file | cut -f1,2)

# output report
echo "Fasta Summary" 
echo "File: $fasta_file"
echo "Total Number of Sequences: $total_seq"
echo "Total Number of Nucleotides: $total_nuc"
echo "$table"
