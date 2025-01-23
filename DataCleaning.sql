SELECT 'column_name' AS column_name, 
'table_name' AS table_name,
SUM(column_name IS NULL) AS null_count, 
SUM(column_name IS NULL) * 100.0 / COUNT(*) AS null_freq 
FROM business
UNION ALL
…;

--For every column & table (temporary table for each table of original dataset)
--Selected output of null_count > 0 

--Finding database completeness 
create temporary table table_sum1 as
select sum(null_count) as null_count,
(select count(*) from business) as row_count,
(SELECT COUNT(*) FROM pragma_table_info('table_name')) as col_count
from table_nulls;
…

--For each table from dataset, table_nulls as temporary table from first part 

select 'table_name' as table_name, *, (1 - CAST(null_count as REAL)/(row_count*col_count)) *100 as percent_fill
from table_sum1
UNION ALL
… ;
--Union each of the temporary tables (SQLite wouldn’t allow operations w/ new columns)
