-- Évolution de la taille des sets par année.
-- Le "* 1.0" compte : en T-SQL, avg() sur un entier renvoie un entier tronqué.
-- Spark renvoie un double. Sans conversion, les deux moteurs ne donnent pas le même chiffre.
select
    release_year,
    count(*)                                  as num_sets,
    round(avg(num_parts_catalog * 1.0), 1)    as avg_parts,
    max(num_parts_catalog)                    as max_parts,
    sum(num_parts_catalog)                    as total_parts
from {{ ref('mart_sets') }}
where num_parts_catalog > 0
group by release_year
