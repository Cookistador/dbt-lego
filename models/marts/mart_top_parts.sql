-- Pièces les plus utilisées, tous sets confondus (pièces de rechange exclues).
with part_usage as (
    select
        sp.part_num,
        sum(sp.quantity)          as total_quantity,
        count(distinct sp.set_num) as num_sets
    from {{ ref('int_set_parts') }} sp
    inner join {{ ref('mart_sets') }} s on sp.set_num = s.set_num
    group by sp.part_num
)

select
    pu.part_num,
    p.part_name,
    pc.part_category_name,
    pu.total_quantity,
    pu.num_sets,
    dense_rank() over (order by pu.total_quantity desc) as usage_rank
from part_usage pu
left join {{ ref('stg_parts') }} p on pu.part_num = p.part_num
left join {{ ref('stg_part_categories') }} pc on p.part_category_id = pc.part_category_id
