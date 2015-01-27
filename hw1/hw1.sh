#!/bin/bash
# bash command-line arguments are accessible as $0 (the bash script), $1, etc.
# echo "Running" $0 "on" $1
# echo "Replace the contents of this file with your solution."

#  Test if Two Argument Are given.
if [ $# -ne 1 ]; then
	echo "Miss arguments: Should given 2 arguments"
	exit
fi

source_file=$1

ebook_csv_file=ebook.csv
tokens_csv_file=tokens.csv
token_counts_csv_file=token_counts.csv
name_counts_csv_file=name_counts.csv

popular_name=popular_names.txt
process_ebook_tokens_script=process_ebook_tokens.py
tmp_file=tmp_counts_001

# Test if source file doesn't exist
if [ ! -f ${source_file} ]; then
	echo "File '${source_file}' doesn't exist"
	exit
fi

if [ -f ${ebook_csv_file} ]; then
	rm ${ebook_csv_file}
fi

if [ -f ${tokens_csv_file} ]; then
	rm ${tokens_csv_file}
fi

if [ -f ${token_counts_csv_file} ]; then
	rm ${token_counts_csv_file}
	echo "token,count" > ${token_counts_csv_file}
fi

if [ -f ${name_counts_csv_file} ]; then
	rm ${name_counts_csv_file}
	echo "token,count" > ${name_counts_csv_file}
	touch ${tmp_file}
fi

# Generate ebook.csv tokens.csv
python ${process_ebook_tokens_script} ${source_file}

# Generate token_counts_csv_file
cut -d "," -f 2 ${tokens_csv_file} | sed "1d" | sort | uniq -c | tr -s " " | tr " " "," | sed "s/^,//g" | sed "s/\(.*\),\(.*\)/\2,\1/g" >> ${token_counts_csv_file}

# Generate name_counts.csv
for name in `cat ${popular_name}`; do
	name=`echo "${name}" | sed "s///g" | tr "[A-Z]" "[a-z]"`
	name_line=`grep "^${name}," ${token_counts_csv_file}`
	if [ ${#name_line} -ne 0 ]; then
		echo "${name_line}" >> ${tmp_file}
	fi
done 
sort -nr -t',' -k2,2 ${tmp_file} | head -n 100 | sort -t"," -k1,1 >> ${name_counts_csv_file}
if [ -f ${tmp_file} ]; then
	rm ${tmp_file}
fi

