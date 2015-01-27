import re
import sys

# Test if correct arguements pass in
if len(sys.argv) != 2:
	print("ERROR: Require input file")
	sys.exit()

source_file = sys.argv[1]
try:
	test_ptr = open(source_file)
	test_ptr.close()
except:
	print("ERROR: '%s' DOES NOT EXITST" % source_file)
	sys.exit()

NOTFOUND = -1
NON_ALPHABETICAL = '[^a-zA-Z]'
SINGLE_QUOTE = '"'
DOUBLE_QUOTE = '""'
SPACE = ' '
DOUBLE_SPACE = '  '
COMMA = ','
NULL_STR = "null"

# Initialize ebook.csv
ebook_csv_file="ebook.csv"
ebook_csv_header = "title,author,release_date,ebook_id,language,body\r\n"
ebook_csv_ptr = open(ebook_csv_file,"w")
ebook_csv_ptr.write(ebook_csv_header)

# ebook_csv_writer = csv.writer(ebook_csv_ptr, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
# ebook_csv_writer.writerow(['title', 'author', 'release_date', 'ebook_id', 'language', 'body'])

# Initialize tokens.csv
tokens_csv_file="tokens.csv"
tokens_csv_header = "ebook_id,token\r\n"
tokens_csv_ptr = open(tokens_csv_file, "w")
tokens_csv_ptr.write(tokens_csv_header)

title = NULL_STR
author = NULL_STR
release_date = NULL_STR
ebook_id = NULL_STR
language = NULL_STR
isBody = False

def csv_format(input_str):
	tmp = re.sub(SINGLE_QUOTE, DOUBLE_QUOTE,input_str)
	if COMMA in input_str or SINGLE_QUOTE in input_str:
		tmp = ("\"%s\"" % tmp)
	return tmp


with open(source_file) as source_ptr:
	for line in source_ptr:
		match_Obj = re.search(r'^\*\*\* START OF ',line, re.M|re.I)
		if match_Obj:
			ebook_csv_ptr.write('%s,%s,%s,%s,%s,\"' % (title, author, release_date, ebook_id, language))
			isBody = True
			continue

		match_Obj = re.search(r'^\*\*\* END OF ',line, re.M|re.I)
		if match_Obj:
			ebook_csv_ptr.write('\"\r\n')
			title = NULL_STR
			author = NULL_STR
			release_date = NULL_STR
			ebook_id = NULL_STR
			language = NULL_STR
			isBody = False
			continue

		if isBody == False:
			# Parse Title
			title_obj = re.search (r'^Title: (.*)\r\n', line, re.M|re.I)
			if title_obj:
				title = csv_format(title_obj.group(1))
				continue

			author_obj = re.search (r'^Author: (.*)\r\n', line, re.M|re.I)
			if author_obj:
				line = re.sub("Author:  ", "Author: ", line)
				if DOUBLE_SPACE in line:
					line = line.split(DOUBLE_SPACE)[0]
				else:
					line = line.split('\r\n')[0]
				author = csv_format (line.split(": ")[1])
				continue

			release_date_and_ebookID = re.search (r'^Release Date: (.*)\s\[..... #(.*)\]\r\n', line, re.M|re.I)
			if release_date_and_ebookID:
				try:
					line = re.sub(DOUBLE_SPACE, SPACE, line)
					# Parse Release Date
					release_date = csv_format(line.split(': ')[1].split(' [')[0])
					# Parse ebook_id
					ebook_id = csv_format(line.split(' #')[1].split(']\r\n')[0])
				except Exception, e:
					release_date = NULL_STR
					ebook_id = NULL_STR

			language_obj = re.search(r'^Language: (.*)\r\n', line, re.M|re.I)
			if language_obj:
				language = csv_format(language_obj.group(1))
				continue
		else:
			escape_line = re.sub(SINGLE_QUOTE, DOUBLE_QUOTE, line)
			ebook_csv_ptr.write(escape_line)
			# process tokens.csv
			line = re.sub(NON_ALPHABETICAL, SPACE, line).lower()
			# VERSION 1
			# line = ' '.join(line.split())
			# line = re.sub(SPACE, ',%s\r\n' % (ebook_id), line)
			# tokens_csv_ptr.write(line)
			# VERSION 2
			for word in line.split():
				tokens_csv_ptr.write("%s,%s\r\n"% (ebook_id, word))
	source_ptr.close()
