import csv
import hashlib
import sys

csv.field_size_limit(sys.maxsize)

# Skip headers
header = sys.stdin.readline()

# Open TSV files for writing in append mode
table_cover = open("data_table_cover.tsv", "w", encoding="utf-8")
table_file = open("data_table_file.tsv", "w", encoding="utf-8")

# Create CSV writers with tab delimiter
tsv_cover = csv.writer(table_cover, delimiter='\t')
tsv_file = csv.writer(table_file, delimiter='\t')

for row in csv.reader(sys.stdin, delimiter='\t'):
    id, created_at, id_thing, id_lang, file_content = row

    # Compute the SHA-256 hash
    hash_file = hashlib.sha256(file_content.encode('utf-8')).hexdigest()

    tsv_cover.writerow([id_thing, id_lang, hash_file])

    tsv_file.writerow([hash_file, file_content])

# Close the files
table_cover.close()
table_file.close()
