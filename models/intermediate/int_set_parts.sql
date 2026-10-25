-- Le modèle le plus lourd du projet : la jointure sur inventory_parts (~1,5 M de lignes).
-- Grain : un set, une pièce, une couleur. Dernière version d'inventaire, sans pièces de rechange.
with ranked_inventories as (
    select
        inventory_id,
        set_num,
        row_number() over (partition by set_num order by inventory_version desc) as version_rank
    from {{ ref('stg_inventories') }}
),

latest_inventories as (
    select inventory_id, set_num
    from ranked_inventories
    where version_rank = 1
),

parts as (
    select inventory_id, part_num, color_id, quantity
    from {{ ref('stg_inventory_parts') }}
    where is_spare = {{ sql_false() }}
)

select
    concat(i.set_num, '|', p.part_num, '|', p.color_id) as set_part_color_key,
    i.set_num,
    p.part_num,
    p.color_id,
    sum(p.quantity) as quantity
from latest_inventories i
inner join parts p on p.inventory_id = i.inventory_id
group by i.set_num, p.part_num, p.color_id
