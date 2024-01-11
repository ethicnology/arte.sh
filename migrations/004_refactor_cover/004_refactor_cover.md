# 004 covers without duplicates

## dump the whole database with data to rollback if anything goes wrong in the following process
```sh
pg_dump -h localhost -U postgres -d postgres -n public > 004_backup_schema_public_with_data.sql
```

### (if needed) restore backup
```sh
psql -h localhost -U postgres -d postgres < 004_backup_schema_public_with_data.sql
```

## rename `cover` table `old_cover`
```sh
psql -h localhost -U postgres -d postgres -c "ALTER TABLE public.cover RENAME TO old_cover"
```

## dump `old_cover`
```sh
TABLE=old_cover; psql -h localhost -U postgres -d postgres -c "\COPY public.$TABLE TO data_table_$TABLE.tsv WITH DELIMITER E'\t' CSV HEADER;"
```

## create table `file`
```sh
psql -h localhost -U postgres -d postgres < 004_table_file.sql
```

## create new table `cover`
```sh
psql -h localhost -U postgres -d postgres < 004_table_cover.sql
```

## generate new datasets from the `old_cover` dump
```sh
cat data_table_old_cover.tsv | python 004_main.py 
```
this will generate `data_table_cover.tsv` and `data_table_file.tsv`

## pre-process data using `bash`
**Using these command you can pre-process the data to keep continuous id increment.**
```sh
cat data_table_file.tsv | sort -u > sorted_data_table_file.tsv
```

```sh
awk '!seen[$1,$3]++' data_table_cover.tsv > sorted_data_table_cover.tsv
```

## insert preprocessed data using `psql`
```sh
psql -h localhost -U postgres -c "\copy public.file (hash, data) FROM 'sorted_data_table_file.tsv' DELIMITER E'\t'"
```

```sh
psql -h localhost -U postgres -c "\copy public.cover (id_thing, id_lang, hash_file) FROM 'sorted_data_table_cover.tsv' DELIMITER E'\t'"
```


<!-- ## OR… insert the data using `dbeaver` to skip errors (lazy)

### using dbeaver import `data_table_file` into `file` table using mapping:
- first value with column `hash`
- second value with column `data`

### using dbeaver import `data_table_cover` into `cover` table using mapping:
- first value with column `id_thing`
- second value with column `id_lang`
- last value with column `hash_file` -->

## verify!

### file
The `row count` (dbeaver) in table `file` should be equal to number lines in `data_table_file.tsv` without duplicates.
```sh
cat data_table_file.tsv | sort -u | wc -l
```

```sh
psql -h localhost -U postgres -c "SELECT COUNT(id) FROM public.file"
```

### cover
The `row count` (dbeaver) in table `cover` should be equal to number lines in `data_table_cover.tsv` without duplicates `hash_file` for the same `id_thing`
```sh
sort -t$'\t' -k1,1 -k3,3 -u data_table_cover.tsv | wc -l
```

```sh
psql -h localhost -U postgres -c "SELECT COUNT(id) FROM public.cover"
```

## deploy the new code version

**connect to the prod**

```sh
git pull
dart compile exe bin/arte.dart  -o ~/ARTE/arte.sh
```

## clean if verification succeed
```sh
psql -h localhost -U postgres -c "DROP TABLE public.old_cover"
```

```sh
rm data_table_cover.tsv
rm data_table_file.tsv
rm data_table_old_cover.tsv
rm sorted_data_table_cover.tsv
rm sorted_data_table_file.tsv
```