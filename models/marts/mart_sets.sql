with sets as (
    select * from {{ ref('stg_sets') }}
),

themes as (
    select * from {{ ref('int_themes_flattened') }}
),

set_parts as (
    select
        set_num,
        sum(quantity)            as total_parts_in_inventory,
        count(distinct part_num) as distinct_parts,
        count(distinct color_id) as distinct_colors
    from {{ ref('int_set_parts') }}
    group by set_num
)

select
    s.set_num,
    s.set_name,
    s.release_year,
    -- modulo plutôt que floor(year / 10) * 10 : en Spark, int / int donne un double
    s.release_year - (s.release_year % 10)     as release_decade,
    s.theme_id,
    t.theme_name,
    t.root_theme_id,
    t.root_theme_name,
    s.num_parts                                as num_parts_catalog,
    coalesce(sp.total_parts_in_inventory, 0)   as total_parts_in_inventory,
    coalesce(sp.distinct_parts, 0)             as distinct_parts,
    coalesce(sp.distinct_colors, 0)            as distinct_colors,
    s.img_url
from sets s
left join themes t on s.theme_id = t.theme_id
left join set_parts sp on s.set_num = sp.set_num
